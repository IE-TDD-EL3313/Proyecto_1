









## 6. Implementación de los módulos de control de partida y visualización — Subsistema FPGA

Como se describió en las secciones 3.2.2, 4.3 y 5.1, el Subsistema FPGA es el encargado de coordinar la secuencia general del juego, evaluar las acciones del jugador y presentar los resultados. Habiendo cubierto ya el Subsistema Discreto en su totalidad, esta sección detalla la implementación en SystemVerilog de los cuatro bloques del Subsistema FPGA asignados para este informe: el **contador de fallos consecutivos**, la **FSM principal del juego**, el **temporizador de Game Over** y el **control de displays de 7 segmentos**. Para cada bloque se presenta su función, su interfaz, el código correspondiente, su funcionamiento y las diferencias respecto a lo planteado en el diseño inicial.

---

### 6.1 Contador de fallos consecutivos

#### 6.1.1 Correspondencia con el diseño inicial

Este bloque implementa la función descrita en la sección **4.3.8 (Contador de fallos consecutivos)** del diseño inicial.

#### 6.1.2 Función

El módulo `consecutive_misses` lleva la cuenta de los fallos consecutivos cometidos por el jugador. A diferencia del contador de fallos acumulados de toda la partida, este contador se reinicia a cero cada vez que ocurre un acierto. Cuando el jugador acumula tres fallos consecutivos, el bloque genera un pulso de alerta de un ciclo de duración que es utilizado por la FSM principal para finalizar la partida.

#### 6.1.3 Interfaz

| Señal | Dirección | Descripción |
|---|---|---|
| `clk` | Entrada | Reloj principal del sistema. |
| `reset` | Entrada | Reinicio síncrono del contador. |
| `hit_pulse` | Entrada | Pulso de un ciclo generado ante un acierto; reinicia el contador. |
| `miss_pulse` | Entrada | Pulso de un ciclo generado ante un fallo; incrementa el contador. |
| `miss_count[1:0]` | Salida | Valor actual del contador de fallos consecutivos (0 a 3). |
| `three_misses` | Salida | Señal combinacional que indica de forma permanente que ya se alcanzaron 3 fallos consecutivos. |
| `third_miss_pulse` | Salida | Pulso de un ciclo que indica el instante exacto en que se completa el tercer fallo consecutivo. |

#### 6.1.4 Implementación

El código completo del módulo se encuentra en [`consecutive_misses.sv`](./consecutive_misses.sv). El núcleo de la lógica es el siguiente fragmento, donde se decide el incremento del contador y la generación del pulso de tercer fallo:

```systemverilog
if (hit_pulse) begin
    miss_count <= 2'd0;
end else if (miss_pulse) begin
    if (miss_count < 2'd3)
        miss_count <= miss_count + 1'b1;

    if (miss_count == 2'd2)
        third_miss_pulse <= 1'b1;
end
```

#### 6.1.5 Funcionamiento

El registro `miss_count` se actualiza de forma síncrona. Un acierto (`hit_pulse`) tiene prioridad sobre un fallo y reinicia el contador a cero. Ante un fallo (`miss_pulse`), el contador se incrementa mientras no haya alcanzado el valor 3. Adicionalmente, si en el momento de recibir el fallo el contador se encontraba en 2, se activa `third_miss_pulse` durante exactamente un ciclo de reloj, coincidiendo con el ciclo en que `miss_count` pasa a valer 3. La salida `three_misses` es puramente combinacional y permanece en alto mientras el contador se mantenga en 3, sin necesidad de un reinicio de partida para volver a bajar (esto ocurre naturalmente cuando `reset` se activa o cuando el sistema vuelve a arrancar una nueva partida).

#### 6.1.6 Comparación con el diseño inicial

| Aspecto | Diseño inicial (sección 4.3.8) | Implementación final |
|---|---|---|
| Nombre de señales | `REGISTRAR_FALLO`, `REGISTRAR_ACIERTO`, `RESET_PARTIDA`, `FIN_3_FALLOS` | `miss_pulse`, `hit_pulse`, `reset`, `three_misses` / `third_miss_pulse` |
| Salida de fin de partida | Una sola señal `FIN_3_FALLOS` | Se separaron dos salidas: `three_misses` (nivel, persistente) y `third_miss_pulse` (pulso de un ciclo). Esta separación fue necesaria porque la FSM principal requiere un **evento de un solo ciclo** para disparar la transición de estado, mientras que una señal de nivel podría causar transiciones repetidas o ambigüedad de temporización. |
| Reinicio del contador | Se contemplaba una señal específica `RESET_PARTIDA`, independiente del reset general | En la implementación final esta función se consolidó dentro de la señal `reset` del módulo, simplificando la interfaz; el manejo de "nueva partida" se resuelve a nivel superior. |

---

### 6.2 FSM principal del juego

#### 6.2.1 Correspondencia con el diseño inicial

Este bloque corresponde a la **FSM del juego**, mencionada en la sección 3.2.2 como parte del Subsistema FPGA y referenciada de forma transversal en las secciones 4.3.4 a 4.3.8 (como la entidad que genera `INICIAR_TURNO`, `REGISTRAR_ACIERTO`, `REGISTRAR_FALLO` y consume `FIN_3_FALLOS`). En el diseño inicial este bloque no contaba con una subsección propia ni con un diagrama de estados detallado; dicho detalle se desarrolla por primera vez en esta sección.

#### 6.2.2 Función

El módulo `game_controller_fsm` es el controlador central del juego. Coordina la secuencia completa de un turno —solicitud de una nueva posición, espera de la posición válida, inicio del turno, resolución de acierto o fallo— y gestiona la transición hacia la secuencia de fin de partida (Game Over) cuando se acumulan tres fallos consecutivos, incluyendo el reinicio automático de los datos de la partida.

#### 6.2.3 Interfaz

| Señal | Dirección | Descripción |
|---|---|---|
| `clk`, `reset` | Entrada | Reloj y reinicio síncrono del sistema. |
| `position_valid` | Entrada | Indica que ya se recibió una posición válida del topo (proveniente del receptor UART). |
| `hit_pulse` | Entrada | Pulso de acierto proveniente del evaluador de golpe. |
| `miss_pulse` | Entrada | Pulso de fallo proveniente del evaluador de golpe. |
| `timeout_pulse` | Entrada | Pulso generado por el temporizador del turno al agotarse el tiempo. |
| `third_miss_pulse` | Entrada | Pulso proveniente del contador de fallos consecutivos (sección 6.1). |
| `game_over_done` | Entrada | Pulso proveniente del temporizador de Game Over (sección 6.3) que indica que finalizó la pantalla de fin de partida. |
| `request_start` | Salida | Solicita al Subsistema Discreto una nueva posición del topo. |
| `turn_start` | Salida | Indica el inicio de un nuevo turno (habilita el temporizador del turno). |
| `turn_cancel` | Salida | Cancela/cierra la ventana activa del turno tras un acierto o fallo. |
| `game_over_start` | Salida | Arranca el temporizador de Game Over. |
| `game_data_reset` | Salida | Solicita el reinicio de los contadores de la partida (aciertos, fallos, fallos consecutivos). |
| `game_active` | Salida | Indica que la partida se encuentra en curso. |
| `game_over` | Salida | Indica que el sistema se encuentra en la secuencia de fin de partida. |
| `state_debug[3:0]` | Salida | Código del estado actual, expuesto únicamente con fines de depuración. |

#### 6.2.4 Diagrama de estados

| Estado | Función |
|---|---|
| `ST_REQUEST_START` | Solicita una nueva posición del topo. |
| `ST_WAIT_POSITION` | Espera a que la posición recibida sea válida. |
| `ST_START_TURN` | Da inicio al turno (habilita el temporizador). |
| `ST_PLAY` | Turno en curso; espera acierto, fallo o agotamiento del tiempo. |
| `ST_RESOLVE_HIT` | Resuelve un acierto y regresa a solicitar una nueva posición. |
| `ST_RESOLVE_MISS` | Resuelve un fallo; decide si continúa la partida o si se alcanzaron 3 fallos consecutivos. |
| `ST_GAME_OVER_START` | Arranca la secuencia de fin de partida. |
| `ST_GAME_OVER_WAIT` | Mantiene la condición de Game Over mientras corre el temporizador correspondiente. |
| `ST_AUTO_RESET` | Reinicia los datos de la partida y regresa automáticamente al inicio. |

Secuencia general:

```text
ST_REQUEST_START → ST_WAIT_POSITION → ST_START_TURN → ST_PLAY
                                                          │
                                   ┌──────────────────────┼───────────────────────┐
                                   ▼                                              ▼
                            ST_RESOLVE_HIT                                 ST_RESOLVE_MISS
                                   │                                              │
                                   │                              ┌───────────────┴───────────────┐
                                   │                              ▼                                ▼
                                   │                    (< 3 fallos consec.)          (3 fallos consec.)
                                   │                     ST_REQUEST_START             ST_GAME_OVER_START
                                   │                                                          │
                                   │                                                          ▼
                                   │                                                  ST_GAME_OVER_WAIT
                                   │                                                          │
                                   │                                                          ▼
                                   │                                                   ST_AUTO_RESET
                                   │                                                          │
                                   └──────────────────────────────────────────────────────────┘
                                                    (regresa a ST_REQUEST_START)
```

#### 6.2.5 Implementación

El código completo del módulo se encuentra en [`game_controller_fsm.sv`](./game_controller_fsm.sv). La definición de los 9 estados es:

```systemverilog
typedef enum logic [3:0] {
    ST_REQUEST_START  = 4'd0,
    ST_WAIT_POSITION  = 4'd1,
    ST_START_TURN     = 4'd2,
    ST_PLAY           = 4'd3,
    ST_RESOLVE_HIT    = 4'd4,
    ST_RESOLVE_MISS   = 4'd5,
    ST_GAME_OVER_START= 4'd6,
    ST_GAME_OVER_WAIT = 4'd7,
    ST_AUTO_RESET     = 4'd8
} state_t;
```

Y la bifurcación que decide entre continuar la partida o pasar a la secuencia de Game Over es:

```systemverilog
ST_RESOLVE_MISS:
    if (third_miss_pulse) next_state = ST_GAME_OVER_START;
    else next_state = ST_REQUEST_START;
```

#### 6.2.6 Funcionamiento

La FSM se implementa con dos bloques combinacionales (siguiente estado y salidas de Moore) y un registro de estado. Un turno normal recorre `ST_REQUEST_START → ST_WAIT_POSITION → ST_START_TURN → ST_PLAY`. Desde `ST_PLAY`, un acierto lleva a `ST_RESOLVE_HIT` (que siempre regresa a solicitar una nueva posición), mientras que un fallo o un agotamiento de tiempo llevan a `ST_RESOLVE_MISS`. En `ST_RESOLVE_MISS` se evalúa `third_miss_pulse`: si aún no se han acumulado tres fallos consecutivos, la partida continúa; si se cumple la condición, la FSM entra en la secuencia de Game Over (`ST_GAME_OVER_START → ST_GAME_OVER_WAIT`), donde permanece hasta que el temporizador de Game Over (sección 6.3) indique su finalización mediante `game_over_done`. Finalmente, `ST_AUTO_RESET` limpia los datos de la partida (`game_data_reset`) antes de reiniciar el ciclo automáticamente, sin requerir intervención del jugador.

#### 6.2.7 Comparación con el diseño inicial

| Aspecto | Diseño inicial | Implementación final |
|---|---|---|
| Nivel de detalle | La FSM se mencionaba únicamente como bloque coordinador, sin diagrama de estados propio. | Se definió explícitamente como una máquina de Moore de 9 estados, con diagrama de estados y tabla de transición completos. |
| Nomenclatura de señales | Español y orientada a la función (`SOLICITUD_TOPO`, `INICIAR_TURNO`, `REGISTRAR_ACIERTO`, `REGISTRAR_FALLO`, `FIN_3_FALLOS`) | Inglés, alineada a la convención del código RTL (`request_start`, `turn_start`, `hit_pulse`, `miss_pulse`, `third_miss_pulse`). |
| Secuencia de fin de partida | Solo se indicaba que `FIN_3_FALLOS` debía "finalizar la partida", sin especificar el mecanismo. | Se agregaron dos estados dedicados (`ST_GAME_OVER_START`, `ST_GAME_OVER_WAIT`) y un estado de reinicio automático (`ST_AUTO_RESET`), que no existían como tales en el diseño inicial. |
| Reinicio de la partida | No se especificaba un mecanismo automático de reinicio tras el Game Over. | Se incorporó `game_data_reset` y el estado `ST_AUTO_RESET`, que permite reiniciar la partida sin depender de una acción externa del jugador. |

---

### 6.3 Temporizador de Game Over

#### 6.3.1 Correspondencia con el diseño inicial

Este bloque **no fue contemplado como un módulo independiente en el diseño inicial**. Surge como una necesidad identificada durante la implementación de la FSM principal (sección 6.2): al alcanzar tres fallos consecutivos, el sistema requiere mantener la condición de "Game Over" visible durante un intervalo definido antes de reiniciar automáticamente la partida. Su estructura interna sigue el mismo principio de diseño ya utilizado en el **temporizador del turno** (sección 4.3.4): un contador impulsado por una habilitación temporal (*clock enable*) de 1 ms, en lugar de un reloj independiente.

#### 6.3.2 Función

El módulo `game_over_timer` mide un intervalo fijo, configurable mediante el parámetro `GAME_OVER_MS`, durante el cual el sistema permanece en el estado de fin de partida. Al cumplirse el tiempo, genera un pulso de un ciclo que la FSM principal utiliza para avanzar hacia el reinicio automático.

#### 6.3.3 Interfaz

| Señal | Dirección | Descripción |
|---|---|---|
| `GAME_OVER_MS` | Parámetro | Duración del temporizador en milisegundos (valor por defecto: 2000 ms). |
| `clk`, `reset` | Entrada | Reloj principal y reinicio síncrono. |
| `ce_1ms` | Entrada | Habilitación temporal de 1 ms, generada por la referencia de tiempo del sistema. |
| `start` | Entrada | Pulso que arranca el temporizador (`game_over_start` de la FSM). |
| `active` | Salida | Indica que el temporizador se encuentra en curso. |
| `done_pulse` | Salida | Pulso de un ciclo que indica que se cumplió el tiempo configurado. |

#### 6.3.4 Implementación

El código completo del módulo se encuentra en [`game_over_timer.sv`](./game_over_timer.sv). El ancho del contador se dimensiona automáticamente según el parámetro:

```systemverilog
localparam integer COUNTER_WIDTH =
    (GAME_OVER_MS <= 1) ? 1 : $clog2(GAME_OVER_MS);
```

Y la condición de finalización del conteo es:

```systemverilog
end else if (active && ce_1ms) begin
    if ((GAME_OVER_MS <= 1) ||
        (elapsed_ms == GAME_OVER_MS - 1)) begin
        elapsed_ms <= '0;
        active     <= 1'b0;
        done_pulse <= 1'b1;
    end else begin
        elapsed_ms <= elapsed_ms + 1'b1;
    end
end
```

#### 6.3.5 Funcionamiento

El ancho del contador `elapsed_ms` se calcula automáticamente mediante `$clog2(GAME_OVER_MS)`, de forma que el módulo sea reutilizable ante distintos valores del parámetro sin desperdiciar bits. Al recibir `start`, el contador se reinicia y `active` se activa. Mientras `active` esté en alto, cada pulso de `ce_1ms` incrementa `elapsed_ms`; al alcanzar `GAME_OVER_MS - 1`, el contador se reinicia, `active` se desactiva y se genera `done_pulse` durante un ciclo, señal que la FSM principal utiliza como `game_over_done`.

#### 6.3.6 Justificación de la adición

Aunque este bloque no figuraba en el diseño inicial, su incorporación es consistente con la metodología de diseño declarada en la sección 6 del documento original (diseño modular, uso de bloques reutilizables y correspondencia con la implementación en HDL): en lugar de resolver la temporización del Game Over dentro de la propia FSM —lo cual habría mezclado control y temporización en un mismo bloque—, se optó por aislar esta función en un módulo independiente y parametrizable, replicando el patrón ya validado en el temporizador del turno.

---

### 6.4 Control de displays de 7 segmentos

#### 6.4.1 Correspondencia con el diseño inicial

Este bloque implementa la función descrita en la sección **4.3.9 (Control de displays)** del diseño inicial, adaptándola a las características físicas reales de los displays de 7 segmentos de la tarjeta Nexys 4.

#### 6.4.2 Función

El módulo `seven_segment_controller` multiplexa en el tiempo los cuatro dígitos utilizados para mostrar, simultáneamente a la vista del usuario, los aciertos (`hits`) y los fallos (`misses`) acumulados durante la partida, cada uno representado con dos dígitos decimales (unidades y decenas).

#### 6.4.3 Interfaz

| Señal | Dirección | Descripción |
|---|---|---|
| `clk`, `reset` | Entrada | Reloj principal y reinicio síncrono. |
| `ce_1ms` | Entrada | Habilitación temporal de 1 ms utilizada como base de la multiplexación. |
| `hits[6:0]` | Entrada | Cantidad acumulada de aciertos (0–99). |
| `misses[6:0]` | Entrada | Cantidad acumulada de fallos (0–99). |
| `seg[6:0]` | Salida | Segmentos activos en bajo, compartidos por los ocho dígitos del display. |
| `dp` | Salida | Punto decimal (fijo en apagado). |
| `an[7:0]` | Salida | Selección de ánodo activo en bajo; solo se controlan los primeros cuatro dígitos. |

#### 6.4.4 Implementación

El código completo del módulo se encuentra en [`seven_segment_controller.sv`](./seven_segment_controller.sv). La selección del dígito activo y del valor a mostrar se resuelve así:

```systemverilog
case (scan_index)
    2'd0: begin an[0] = 1'b0; digit_value = hits % 10;   end
    2'd1: begin an[1] = 1'b0; digit_value = hits / 10;   end
    2'd2: begin an[2] = 1'b0; digit_value = misses % 10; end
    default: begin an[3] = 1'b0; digit_value = misses / 10; end
endcase
```

y la decodificación a segmentos (activa en bajo) sigue la tabla estándar de 7 segmentos para dígitos 0–9, con `seg = 7'b1111111` como valor por defecto.

#### 6.4.5 Funcionamiento

Un contador de 2 bits (`scan_index`), incrementado a razón de 1 kHz mediante `ce_1ms`, selecciona cíclicamente cuál de los cuatro dígitos se encuentra activo en un instante dado (barrido o *multiplexado*). Según el dígito seleccionado, se calcula `digit_value` a partir de las operaciones de módulo y división entera por 10 sobre `hits` o `misses`, obteniendo así la unidad o la decena correspondiente. El resultado se traduce a los patrones de segmentos mediante una tabla de decodificación con lógica activa en bajo, propia del hardware de la Nexys 4 (`seg[0]=A` … `seg[6]=G`). El punto decimal (`dp`) permanece apagado de forma permanente, ya que no se requiere para esta visualización.

#### 6.4.6 Comparación con el diseño inicial

| Aspecto | Diseño inicial (sección 4.3.9) | Implementación final |
|---|---|---|
| Nivel de detalle | Se describía únicamente el resultado esperado (2 dígitos para aciertos, 2 para fallos), sin especificar el mecanismo de multiplexación. | Se definió explícitamente el barrido temporal mediante `scan_index` y `ce_1ms`, junto con la tabla de decodificación de 7 segmentos. |
| Ancho de la señal de selección de dígito | El diagrama de segundo nivel especificaba `AN[3:0]`. | Se implementó como `an[7:0]` para ajustarse al ancho real del bus de ánodos de los ocho dígitos físicos de la Nexys 4, aunque únicamente se controlan activamente los cuatro primeros (`an[4]` a `an[7]` permanecen apagados). |
| Cálculo de dígitos | No se especificaba el método de separación en unidades y decenas. | Se utilizan directamente los operadores de módulo (`%`) y división entera (`/`) por 10 sobre las señales `hits` y `misses`. |

---

Con la descripción de estos cuatro módulos se completa el detalle de implementación del Subsistema FPGA correspondiente a esta sección del informe, complementando lo ya expuesto para el Subsistema Discreto y los bloques descritos en las secciones 4.3.1 a 4.3.7 y 5.1.
