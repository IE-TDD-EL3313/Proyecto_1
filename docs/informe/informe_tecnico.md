
# Informe técnico: Whack-a-Mole con lógica discreta y FPGA

## Resumen
Este proyecto presenta el diseño e implementación de un juego electrónico Whack-a-Mole mediante la integración de lógica discreta y una FPGA Nexys 4. El subsistema discreto, construido con integrados de la familia 74LS, utiliza un registro de desplazamiento con realimentación lineal (LFSR) para generar la posición pseudoaleatoria del topo y un decodificador 74LS138 para representarla en uno de ocho LEDs. La FPGA concentra el control del juego mediante una arquitectura modular desarrollada en SystemVerilog, incluyendo sincronización y antirrebote de ocho botones externos, temporización de los turnos, evaluación de golpes, dificultad progresiva, conteo de aciertos y fallos, control de vidas y visualización en displays de siete segmentos.
Aunque el planteamiento original especificaba una comunicación UART 8N1, las dificultades encontradas durante su integración llevaron a implementar temporalmente un enlace paralelo de tres bits para transmitir la posición. Las diferencias de voltaje entre ambos subsistemas se resolvieron mediante divisores resistivos y un transistor 2N2222 para la señal de solicitud. Los módulos de la FPGA fueron verificados mediante testbenches autoverificables, y la integración superó las pruebas de aciertos, fallos, timeout, dificultad, fin de partida y reinicio automático. La implementación demostró el funcionamiento general del juego, aunque se identificaron limitaciones en el LFSR discreto y en la confiabilidad de algunas solicitudes.

---

## 1. Introducción

### 1.1 Contexto

Whack-a-Mole es un juego en el que se activa aleatoriamente una de varias posiciones y el jugador debe presionar el botón correspondiente antes de que finalice un tiempo determinado. El proyecto solicita dividir el sistema en dos subsistemas: un circuito discreto encargado de generar y mostrar la posición pseudoaleatoria del topo, y una FPGA responsable del control de turnos, botones, puntajes, dificultad y visualización. La comunicación especificada originalmente entre ambos subsistemas corresponde a un enlace UART asíncrono 8N1.

### 1.2 Solución desarrollada

El circuito discreto utiliza un LFSR para generar una posición de tres bits y un 74LS138 para activar uno de ocho LEDs. La FPGA recibe la posición, solicita nuevos topos, filtra las señales de ocho botones externos y controla el juego mediante una máquina de estados. Además, implementa la ventana temporal, dificultad progresiva, conteo de aciertos y fallos, tres oportunidades consecutivas, estado de fin de partida y cuatro displays de siete segmentos.

### 1.3 Alcance y limitaciones
Se implementaron y verificaron completamente los módulos principales de control de la FPGA mediante testbenches autoverificables. Debido a problemas de estabilidad durante la integración UART, la posición se transmitió finalmente mediante el bus paralelo `Q[2:0]`. Esta modificación permitió obtener una integración funcional, pero no cumple el enlace serial solicitado originalmente. También se observaron bloqueos en ciertas posiciones del LFSR, especialmente en el estado 000, que requiere una semilla no nula o una corrección de la lógica de realimentación. Asimismo, algunas solicitudes no fueron reconocidas correctamente por el circuito discreto, por lo que se incorporaron mecanismos de diagnóstico y control de pulsos.

---

## 2. Objetivos

### 2.1 Objetivo general

Diseñar e implementar un juego Whack-a-Mole utilizando un subsistema de lógica discreta para generar la posición pseudoaleatoria y una FPGA Nexys 4 para controlar la dinámica del juego, las entradas del usuario, la temporización y la visualización de resultados.

### 2.2 Objetivos específicos

- Diseñar un generador pseudoaleatorio mediante un LFSR discreto.
- Decodificar la posición mediante un 74LS138.
- Generar una posición ante cada solicitud de la FPGA.
- Implementar ocho botones externos con sincronización y antirrebote.
- Controlar el juego mediante una máquina de estados finitos.
- Implementar dificultad progresiva entre 1500 ms y 500 ms.
- Contabilizar aciertos, fallos acumulados y fallos consecutivos.
- Mostrar los resultados en cuatro displays de siete segmentos.
- Implementar el estado de fin de partida y el reinicio.
- Verificar los módulos mediante testbenches autoverificables.
- Comparar los resultados teóricos, simulados y experimentales.

---

## 3. Especificaciones

### 3.1 Requisitos funcionales

La siguiente tabla compara los requisitos establecidos en el instructivo con la implementación final del sistema.

| Requisito | Valor especificado | Implementación final |
|---|---:|---|
| Posiciones del topo | 8 | Ocho posiciones codificadas mediante `Q[2:0]` y representadas en los LEDs `LD0–LD7` |
| Botones externos | 8 | Ocho pulsadores conectados al Pmod JB, sincronizados y filtrados contra rebotes |
| Tiempo inicial | 1500 ms | Ventana inicial de 1500 ms controlada por `turn_window_timer` |
| Reducción por acierto | 100 ms | Reducción de 100 ms después de cada acierto |
| Tiempo mínimo | 500 ms | Saturación de la ventana temporal en 500 ms |
| Fallos consecutivos | 3 | La partida termina después del tercer fallo consecutivo |
| Game over | 2000 ms | Estado de fin de partida durante 2000 ms, seguido de reinicio automático |
| Aciertos | 00–99 | Contador acumulado saturado en 99 y mostrado en dos dígitos |
| Fallos acumulados | 00–99 | Contador acumulado saturado en 99 y mostrado en dos dígitos |
| Reloj de la FPGA | 100 MHz | Reloj principal de 100 MHz de la Nexys 4 |
| Base temporal | 1 ms | Clock enable de un ciclo cada 100 000 ciclos de reloj |
| Indicador de estado | Partida activa/finalizada | `LD15` fijo durante la partida y parpadeante durante game over |
| Comunicación requerida | UART asíncrono 8N1 | Sustituida durante la integración por un enlace paralelo `Q[2:0]` |
| Solicitud de nuevo topo | Un pulso por turno | Pulso de 500 ms enviado por JA4 mediante un transistor 2N2222 |
| Reset general | Botón central | `BTNC` reinicia puntajes, fallos consecutivos, dificultad y secuencia de control |

La comunicación paralela fue utilizada debido a problemas de estabilidad encontrados durante la integración del enlace UART. Esta adaptación permitió verificar el funcionamiento del subsistema de control, pero representa una desviación respecto al protocolo exigido originalmente.

### 3.2 Requisitos eléctricos

El circuito discreto utiliza integrados de la familia 74LS alimentados con 5 V, mientras que las entradas y salidas Pmod de la Nexys 4 trabajan con lógica de 3.3 V. Por esta razón, fue necesario adaptar los niveles eléctricos entre ambos subsistemas.

- La lógica discreta se alimenta con una fuente regulada de 5 V.
- La FPGA utiliza niveles lógicos LVCMOS de 3.3 V.
- La FPGA y la protoboard comparten una misma referencia de tierra.
- Las señales `Q0`, `Q1` y `Q2` pasan por divisores resistivos antes de ingresar a JA1, JA2 y JA3.
- El voltaje aplicado a una entrada Pmod no debe superar 3.3 V.
- La señal discreta `SOLICITUD_TOPO` posee una resistencia pull-up de 10 kΩ hacia 5 V.
- `SOLICITUD_TOPO` es una señal activa en bajo.
- La salida JA4 no se conecta directamente al nodo de 5 V.
- Se utiliza un transistor NPN 2N2222 para aislar los niveles eléctricos e invertir la solicitud.

La conexión utilizada para generar la solicitud es:

```text
JA4 de la FPGA ── resistencia de 10 kΩ ── base del 2N2222
GND común ─────────────────────────────── emisor del 2N2222
SOLICITUD_TOPO ────────────────────────── colector del 2N2222
5 V ── resistencia pull-up de 10 kΩ ───── SOLICITUD_TOPO
```
---

## 4. Fundamentación teórica

### 4.1 Lógica combinacional y secuencial

Los sistemas digitales se construyen mediante lógica combinacional y lógica secuencial. En la lógica combinacional, las salidas dependen únicamente de las entradas presentes. Algunos ejemplos son las compuertas AND, OR, NOT y XOR, así como los multiplexores, comparadores y decodificadores.

En la lógica secuencial, las salidas también dependen del estado almacenado previamente. Los flip-flops permiten almacenar un bit, mientras que varios flip-flops conectados forman registros y contadores. En este proyecto se utilizan registros para almacenar los estados de la FSM, posiciones, puntajes, tiempos y niveles anteriores de los botones.

Toda la lógica secuencial de la FPGA trabaja con el reloj principal de 100 MHz de la Nexys 4. Para implementar eventos lentos no se generan relojes adicionales, sino una señal `ce_1ms` que habilita los registros una vez por milisegundo. Este enfoque mantiene un único dominio de reloj y facilita el análisis temporal.

El reset utilizado en los módulos es síncrono, ya que se evalúa dentro de bloques:

```systemverilog
always_ff @(posedge clk)
```

Los registros utilizan asignaciones no bloqueantes (`<=`), las cuales representan que todos los flip-flops actualizan sus salidas simultáneamente después del flanco activo del reloj. Por otra parte, la lógica combinacional se describe mediante `always_comb` y debe asignar valores en todos los caminos posibles para evitar la inferencia de latches no intencionados.

---

### 4.2 Linear Feedback Shift Register (LFSR)

Un Linear Feedback Shift Register es un registro de desplazamiento cuya entrada se calcula mediante una combinación XOR de algunos de sus bits internos. Los bits utilizados para calcular la realimentación reciben el nombre de *taps*.

En cada pulso de reloj, el contenido del registro se desplaza y el bit calculado mediante XOR se introduce en uno de sus extremos. Si se selecciona un polinomio primitivo, un LFSR de \(n\) bits puede producir una secuencia de periodo máximo:

\[
T_{\text{máximo}} = 2^n-1
\]

Para un LFSR de tres bits:

\[
T_{\text{máximo}} = 2^3-1 = 7
\]

Esto significa que un LFSR lineal convencional de tres bits puede recorrer como máximo siete estados no nulos antes de repetir la secuencia.

#### Polinomio utilizado

> **Importante:** sustituir esta expresión si los taps físicos utilizados por el equipo son diferentes.

Para una realimentación formada por `Q2 XOR Q1`, el polinomio puede representarse como:

\[
P(x)=x^3+x^2+1
\]

La ecuación de realimentación correspondiente es:

\[
f = Q_2 \oplus Q_1
\]

Suponiendo que el desplazamiento se realiza como:

```text
Q2_siguiente = Q1
Q1_siguiente = Q0
Q0_siguiente = Q2 XOR Q1
```

y que la semilla inicial es `001`, se obtiene la siguiente secuencia:

| Pulso | Estado actual | Realimentación `Q2 XOR Q1` | Estado siguiente | LED |
|---:|:---:|:---:|:---:|:---:|
| 0 | `001` | `0` | `010` | LED1 |
| 1 | `010` | `1` | `101` | LED2 |
| 2 | `101` | `1` | `011` | LED5 |
| 3 | `011` | `1` | `111` | LED3 |
| 4 | `111` | `0` | `110` | LED7 |
| 5 | `110` | `0` | `100` | LED6 |
| 6 | `100` | `1` | `001` | LED4 |

La tabla debe compararse con la secuencia medida en la protoboard. Si el orden real de desplazamiento o los taps son diferentes, debe modificarse para representar el circuito construido.

#### Estado absorbente `000`

El estado `000` es un estado prohibido para un LFSR basado únicamente en XOR. Si todos los bits son cero, la realimentación también será cero:

\[
0 \oplus 0 = 0
\]

Después del desplazamiento, el estado siguiente vuelve a ser `000`. Por lo tanto, el sistema queda bloqueado y no puede salir de ese estado mediante pulsos normales de reloj.

```text
Estado actual:    000
Realimentación:     0
Estado siguiente: 000
```

Por esta razón se utiliza un reset que carga una semilla diferente de cero, como `001`. Sin embargo, un LFSR de tres bits continúa teniendo solamente siete estados útiles. Para observar las ocho combinaciones en el 74LS138 sin utilizar un estado interno bloqueado, una alternativa consiste en implementar un LFSR de cuatro bits y utilizar tres de sus bits como posición visible.

---

### 4.3 Decodificador 74LS138

El 74LS138 es un decodificador de tres entradas y ocho salidas. Las entradas binarias A, B y C seleccionan una de las ocho salidas disponibles. El integrado también posee entradas de habilitación que deben colocarse en los niveles apropiados para activar su funcionamiento.

Las salidas del 74LS138 son activas en bajo. Esto significa que la salida seleccionada toma un valor cercano a 0 V, mientras que las demás permanecen en nivel alto. Los LEDs deben conectarse considerando que el integrado absorbe corriente cuando selecciona una posición.

| Q2 | Q1 | Q0 | Salida activa | Posición |
|:---:|:---:|:---:|---|---|
| 0 | 0 | 0 | Y0 | LED0 |
| 0 | 0 | 1 | Y1 | LED1 |
| 0 | 1 | 0 | Y2 | LED2 |
| 0 | 1 | 1 | Y3 | LED3 |
| 1 | 0 | 0 | Y4 | LED4 |
| 1 | 0 | 1 | Y5 | LED5 |
| 1 | 1 | 0 | Y6 | LED6 |
| 1 | 1 | 1 | Y7 | LED7 |

De esta manera, la palabra de tres bits generada por el LFSR se convierte en una representación one-hot, en la que solamente uno de los ocho LEDs se encuentra activo.

---

### 4.4 UART asíncrono

UART es un protocolo de comunicación serial asíncrono. Los dispositivos transmisor y receptor no comparten una señal de reloj, por lo que ambos deben utilizar una velocidad previamente acordada, denominada *baud rate*.

El formato solicitado para el proyecto fue UART 8N1:

- Un bit de inicio en nivel bajo.
- Ocho bits de datos.
- Sin bit de paridad.
- Un bit de parada en nivel alto.
- Transmisión del bit menos significativo primero.

```text
Reposo | START | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | STOP
   1   |   0   |             8 bits              |  1
```

La cantidad de ciclos del reloj de la FPGA contenidos en cada bit se calcula mediante:

\[
CLKS\_PER\_BIT =
\frac{CLK\_FREQ}{BAUD\_RATE}
\]

Para un reloj de 100 MHz y una velocidad de 2400 baudios:

\[
CLKS\_PER\_BIT =
\frac{100\,000\,000}{2400}
\approx 41666
\]

El receptor espera aproximadamente medio periodo después de detectar el bit de inicio. Esto permite comprobar el inicio cerca del centro del bit, donde la señal presenta mayor estabilidad. Posteriormente, cada bit de datos se muestrea una vez por periodo UART.

#### Módulo `uart_synchronizer`

La entrada UART proviene de un circuito con un reloj independiente, por lo que es asíncrona respecto al reloj de la FPGA. El módulo `uart_synchronizer` utiliza dos flip-flops en cascada:

```systemverilog
serial_meta <= serial_async;
serial_sync <= serial_meta;
```

La primera etapa puede experimentar metastabilidad. La segunda reduce la probabilidad de que ese estado se propague hacia la lógica del receptor. Después del reset, ambas etapas se inicializan en uno, correspondiente al estado de reposo de UART.

#### Módulo `uart_rx`

El módulo `uart_rx` implementa el receptor mediante una FSM con cuatro estados:

| Estado | Función |
|---|---|
| `IDLE` | Espera que la línea cambie de uno a cero |
| `START` | Espera medio bit y confirma el inicio |
| `DATA` | Captura los ocho bits, comenzando por D0 |
| `STOP` | Verifica el bit de parada y genera `data_valid` |

El parámetro `CLKS_PER_BIT` establece la cantidad de ciclos de 100 MHz por bit, mientras que `HALF_BIT` permite verificar el bit de inicio aproximadamente en su centro.

Los bits recibidos se almacenan mediante:

```systemverilog
rx_data[bit_index] <= serial_sync;
```

Al recibir correctamente el bit de parada, `data_valid` se activa durante un solo ciclo de reloj. Esto indica que `rx_data` contiene un byte completo y válido.

El receptor utiliza por defecto:

```systemverilog
CLK_FREQ  = 100_000_000
BAUD_RATE = 2400
```

Ambos valores son parametrizables.

#### Módulo `uart_test_led`

El módulo `uart_test_led` integra:

- Un sincronizador de dos etapas.
- Una instancia de `uart_rx`.
- Un decodificador de los tres bits menos significativos.
- Ocho LEDs de salida.

En esta prueba se configuró el receptor a 9600 baudios:

```systemverilog
uart_rx #(
    .CLK_FREQ  (100_000_000),
    .BAUD_RATE (9600)
)
```

Cuando `data_valid` se activa, los tres bits menos significativos se convierten a una representación one-hot:

```systemverilog
case (rx_data[2:0])
    3'd0: led <= 8'b00000001;
    3'd1: led <= 8'b00000010;
    3'd2: led <= 8'b00000100;
    3'd3: led <= 8'b00001000;
    3'd4: led <= 8'b00010000;
    3'd5: led <= 8'b00100000;
    3'd6: led <= 8'b01000000;
    3'd7: led <= 8'b10000000;
endcase
```

Esto permitió verificar que un byte UART podía transformarse en la posición correspondiente.

#### Resultado de simulación UART

La simulación integrada utilizó:

```text
Frecuencia de reloj: 100 MHz
Baud rate:           2400 baudios
Formato:             UART 8N1
CLKS_PER_BIT:        41666 ciclos
```

Durante la prueba se transmitieron los siguientes bytes:

| Byte transmitido | Bits menos significativos | Posición esperada | Resultado |
|---:|:---:|---:|---|
| `0x05` | `101` | 5 | Correcto |
| `0x03` | `011` | 3 | Correcto |
| `0x07` | `111` | 7 | Correcto |
| `0x00` | `000` | 0 | Correcto |

![Simulación integrada del receptor UART](figuras/uart_integrado.png)

En la forma de onda se observa que `serial_async` contiene las tramas generadas por el testbench. La señal `serial_sync` reproduce la entrada después de atravesar el sincronizador de dos etapas.

Durante la recepción, `rx_data` cambia conforme se almacenan los bits. Por esta razón, su contenido solamente debe interpretarse cuando `data_valid` se activa. Después de cada trama válida, la posición registrada sigue la secuencia:

```text
0 → 5 → 3 → 7 → 0
```

El resultado demuestra que el sincronizador, la FSM del receptor, el registro de datos y la extracción de `rx_data[2:0]` funcionaron correctamente en simulación con señales UART ideales.

Durante la integración física se presentaron problemas de estabilidad relacionados con la generación discreta del baud rate y la comunicación entre dos relojes independientes. Por esta razón, la versión final utilizó temporalmente el bus paralelo `Q[2:0]`. La simulación se conserva como evidencia de que el receptor UART descrito en HDL funcionó bajo las condiciones temporales establecidas.

---

### 4.5 Comunicación paralela implementada

La integración final transmite la posición mediante tres señales independientes:

```text
Q0 → JA1
Q1 → JA2
Q2 → JA3
```

Estas señales representan directamente un valor binario entre cero y siete. Debido a que provienen de un circuito discreto de 5 V, se utilizan divisores resistivos para reducir su nivel antes de conectarlas a la FPGA.

Dentro de la FPGA, `Q[2:0]` atraviesa un sincronizador de dos etapas. Posteriormente, el módulo `parallel_position_receiver` exige que la palabra permanezca estable durante un tiempo configurable antes de aceptarla.

La salida `position_valid` se activa durante un ciclo cuando se acepta la primera posición o cuando se detecta una posición distinta de la anterior.

Las principales ventajas del enlace paralelo son:

- Menor complejidad de integración.
- No requiere recuperación de baud rate.
- Permite observar directamente la posición.
- Facilitó la verificación del control del juego.

Sus principales limitaciones son:

- Utiliza tres líneas en lugar de una.
- No corresponde al protocolo UART exigido.
- No contiene bits de inicio o parada.
- No diferencia dos recepciones consecutivas con el mismo valor sin una señal adicional de dato válido.
- La coherencia del bus depende del filtro de estabilidad.

---

### 4.6 Metastabilidad

La metastabilidad puede ocurrir cuando una entrada cambia muy cerca del flanco activo del reloj. En esta condición, un flip-flop puede tardar un tiempo indeterminado en establecer un cero o un uno válido.

Los botones, la entrada UART y las señales `Q0`, `Q1` y `Q2` son asíncronas respecto al reloj de 100 MHz. Para reducir el riesgo se utilizan dos flip-flops en cascada:

```text
Entrada asíncrona → primera etapa → segunda etapa → lógica interna
```

El sincronizador no elimina matemáticamente la metastabilidad, pero aumenta significativamente el tiempo disponible para que la primera etapa se estabilice antes de que la señal sea utilizada por el resto del diseño.

Para el bus paralelo, la sincronización se complementa con una validación temporal. Esto evita aceptar inmediatamente palabras transitorias causadas por diferencias en el tiempo de propagación de los tres bits.

---

### 4.7 Rebote de botones

Los contactos mecánicos de un pulsador no cambian una sola vez entre cero y uno. Durante algunos milisegundos pueden producir varias transiciones rápidas conocidas como rebote.

Sin un filtro, una sola pulsación podría interpretarse como múltiples golpes. El diseño realiza primero la sincronización de cada botón y después muestrea su nivel cada milisegundo.

Un nuevo estado solamente se acepta si permanece estable durante 10 ms consecutivos. Cuando el nivel filtrado cambia de cero a uno, se genera un pulso de un ciclo:

```systemverilog
buttons_pulse = buttons_level & ~previous_level;
```

`buttons_level` permanece alto mientras el botón está presionado, mientras que `buttons_pulse` dura únicamente un ciclo de 100 MHz. Los contadores y la FSM utilizan el pulso para registrar un solo evento por pulsación.

---

### 4.8 Máquinas de estados

Una máquina de estados finitos controla el comportamiento de un sistema secuencial mediante un conjunto definido de estados y condiciones de transición.

La FSM principal utiliza una arquitectura Moore, porque sus salidas dependen principalmente del estado actual. El diseño se divide en tres partes:

1. Registro del estado actual.
2. Lógica combinacional de estado siguiente.
3. Lógica combinacional de salidas.

El registro se actualiza mediante:

```systemverilog
always_ff @(posedge clk)
```

La lógica de transición utiliza un valor predeterminado:

```systemverilog
next_state = current_state;
```

La lógica de salidas también asigna valores por defecto antes del bloque `case`. Esto garantiza que todas las señales tengan un valor en cualquier condición y evita inferir latches.

Los estados principales controlan:

- Solicitud de una nueva posición.
- Espera de una posición válida.
- Inicio de la ventana temporal.
- Evaluación del golpe.
- Resolución de acierto o fallo.
- Inicio y espera de game over.
- Reinicio automático.

---

### 4.9 Displays de siete segmentos

La Nexys 4 posee displays cuyos segmentos y ánodos son activos en bajo. Un segmento se enciende al colocar cero en su señal, y un dígito se habilita al colocar cero en su ánodo.

El diseño utiliza multiplexación temporal. Solamente un dígito se encuentra activo en cada instante, pero el barrido ocurre suficientemente rápido para que el observador perciba los cuatro dígitos encendidos simultáneamente.

El índice de barrido cambia cada 1 ms:

```text
AN0 → unidades de aciertos
AN1 → decenas de aciertos
AN2 → unidades de fallos
AN3 → decenas de fallos
```

Como existen cuatro dígitos, cada uno se actualiza una vez cada 4 ms:

\[
f_{\text{dígito}} =
\frac{1}{4\text{ ms}} = 250\text{ Hz}
\]

Los valores binarios de los contadores se convierten a decimal mediante división y módulo por diez:

```systemverilog
unidades = valor % 10;
decenas  = valor / 10;
```

Posteriormente, un bloque `case` transforma cada dígito decimal en el patrón correspondiente de los segmentos A a G. El punto decimal permanece apagado y los cuatro displays no utilizados permanecen deshabilitados.
---

## 5. Metodología

### 5.1 Diseño modular

[Explicar por qué se dividió el sistema en módulos independientes.]

### 5.2 Flujo de desarrollo

1. Análisis de requisitos.
2. Diagrama de bloques.
3. Desarrollo de módulos.
4. Creación de testbenches.
5. Integración.
6. Síntesis.
7. Implementación.
8. Generación del bitstream.
9. Prueba física.
10. Diagnóstico y correcciones.

### 5.3 Herramientas

- Vivado 2026.1.
- SystemVerilog y XSim.
- Git y GitHub.
- Nexys 4.
- Protoboard e integrados 74LS.
- Multímetro.
- Transistor 2N2222.

---

## 6. Arquitectura general

### 6.1 Diagrama de bloques

![Diagrama general](figuras/diagrama_general.png)

[Explicar el diagrama y el flujo de las señales.]

### 6.2 Flujo de una jugada

1. La FPGA activa `SOLICITUD_TOPO`.
2. El LFSR genera una posición.
3. El 74LS138 enciende un LED.
4. La FPGA recibe `Q[2:0]`.
5. Se valida la posición.
6. Se abre la ventana temporal.
7. Se espera un botón o timeout.
8. Se registra acierto o fallo.
9. Se actualizan puntajes, dificultad y vidas.
10. Se solicita otra posición o se inicia game over.

### 6.3 Diagrama temporal

![Diagrama temporal](figuras/diagrama_temporal.png)

---

## 7. Subsistema discreto

### 7.1 LFSR

- Integrados utilizados: [COMPLETAR].
- Número de bits: [COMPLETAR].
- Taps: [COMPLETAR].
- Semilla: [COMPLETAR].
- Periodo teórico: [COMPLETAR].
- Periodo medido: [COMPLETAR].

![Esquemático del LFSR](figuras/circuito_lfsr.png)

### 7.2 Decodificador y LEDs

![Circuito del 74LS138](figuras/decoder_74ls138.png)

### 7.3 Entrada de solicitud

```text
JA4 ── 10 kΩ ── base del 2N2222
GND ─────────── emisor
SOLICITUD ───── colector
5 V ── 10 kΩ ── SOLICITUD
```

### 7.4 Problemas observados

- Bloqueo en LED0.
- Bloqueo observado en LED1.
- Recuperación mediante reset o pulso manual.
- Solicitudes no reconocidas.
- [Agregar diagnóstico y solución definitiva.]

---

## 8. Subsistema FPGA

### 8.1 `ce_1ms_generator`

[Función, entradas, salidas, ecuación del divisor y decisiones.]

### 8.2 `sync_2ff`

[Función, metastabilidad y latencia.]

### 8.3 `button_debouncer`

[Función y validación temporal.]

### 8.4 `button_bank`

El módulo `button_bank` se encarga de acondicionar las señales provenientes de los ocho pulsadores externos utilizados por el jugador.

Debido a que los pulsadores son dispositivos físicos externos a la FPGA, sus señales pueden cambiar de forma independiente al reloj interno y además pueden presentar rebote mecánico. Por esta razón, antes de utilizar las pulsaciones en la lógica del juego se realiza un proceso de sincronización, antirrebote y detección de pulsaciones válidas.

El módulo realiza tres funciones principales:

- Sincronizar las entradas de los ocho pulsadores con el reloj de la FPGA.
- Filtrar el rebote mecánico de cada pulsador.
- Generar un único pulso por cada nueva pulsación válida.

#### Entradas y salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `clk` | Entrada | Reloj principal del sistema |
| `reset` | Entrada | Reinicio del módulo |
| `ce_1ms` | Entrada | Habilitación periódica utilizada como referencia temporal |
| `buttons_async[7:0]` | Entrada | Señales provenientes de los ocho pulsadores externos |
| `buttons_level[7:0]` | Salida | Estado estable y filtrado de cada pulsador |
| `buttons_pulse[7:0]` | Salida | Pulso generado cuando se detecta una nueva pulsación válida |

#### Funcionamiento

La primera etapa corresponde a la sincronización de las entradas. Los ocho bits de `buttons_async` pasan por un sincronizador de dos etapas antes de ser utilizados por la lógica interna.

Una vez sincronizadas, las señales son procesadas individualmente mediante bloques de antirrebote. Cada pulsador posee su propio filtro, lo que permite que los ocho botones sean evaluados de forma independiente.

En la implementación utilizada se estableció un tiempo de antirrebote de:

```text
DEBOUNCE_MS = 10 ms
```

Para aceptar un cambio, el nuevo estado del pulsador debe permanecer estable durante el intervalo configurado. Si la entrada cambia nuevamente antes de completar este tiempo, el cambio no se considera válido.

Después del proceso de antirrebote se obtiene `buttons_level`, que representa el estado estable de cada pulsador.

Sin embargo, para el funcionamiento del juego no se desea mantener una señal activa durante todo el tiempo que el jugador mantiene presionado el botón. Se requiere únicamente un evento por cada pulsación.

Para esto se almacena el nivel anterior de los botones y se realiza una detección de flanco ascendente mediante:

```systemverilog
assign buttons_pulse = buttons_level & ~previous_level;
```

De esta manera, cuando un botón cambia de `0` a `1`, se genera un único pulso en el bit correspondiente de `buttons_pulse`.

La secuencia de funcionamiento es:

1. Se recibe el estado físico de los ocho pulsadores.
2. Las señales son sincronizadas con el reloj de la FPGA.
3. Cada pulsador pasa por su propio filtro de antirrebote.
4. Se obtiene el estado estable mediante `buttons_level`.
5. Se compara el estado actual con el estado anterior.
6. Si se detecta un flanco ascendente, se genera un pulso en `buttons_pulse`.
7. La lógica del juego utiliza este pulso como una única acción del jugador.

#### Relación con el sistema

La salida `buttons_pulse` es utilizada por el módulo encargado de evaluar la jugada. Cada bit representa uno de los ocho botones asociados a las posibles posiciones del topo.

El uso de este módulo evita que el rebote mecánico o una pulsación prolongada produzcan múltiples aciertos o fallos.

Además, mantener el acondicionamiento de los botones en un módulo independiente permite separar el manejo de las entradas físicas de la lógica principal del juego.

### 8.5 `parallel_position_receiver`

El módulo `parallel_position_receiver` se encarga de recibir la posición generada por el subsistema de lógica discreta mediante un bus paralelo de tres bits.

La posición recibida no se utiliza directamente, debido a que las señales provenientes del circuito externo pueden cambiar de forma independiente al reloj de la FPGA. Por esta razón, el módulo realiza una sincronización del bus y posteriormente comprueba que el valor permanezca estable antes de aceptarlo como una nueva posición válida.

#### Entradas y salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `clk` | Entrada | Reloj principal del sistema |
| `reset` | Entrada | Reinicio del módulo |
| `ce_1ms` | Entrada | Habilitación utilizada como referencia temporal |
| `position_async[2:0]` | Entrada | Posición proveniente del circuito discreto |
| `position[2:0]` | Salida | Posición sincronizada y validada |
| `position_valid` | Salida | Pulso que indica que existe una nueva posición válida |

#### Funcionamiento

El bus `position_async[2:0]` contiene la posición generada por el circuito discreto. Como estas señales provienen de un sistema externo a la FPGA, primero pasan por un sincronizador de dos etapas.

Después de la sincronización, el valor recibido se almacena temporalmente como una posición candidata.

El módulo utiliza `ce_1ms` para comprobar durante cuánto tiempo permanece estable este valor. En la implementación utilizada se estableció:

```text
POSITION_STABLE_MS = 2 ms
```

Por lo tanto, un cambio momentáneo en el bus no se acepta inmediatamente. La posición debe permanecer estable durante el intervalo configurado antes de ser utilizada por el resto del sistema.

Si el valor cambia antes de completar el tiempo de estabilidad, el conteo comienza nuevamente para la nueva posición.

Cuando el valor permanece estable durante el tiempo requerido, ocurren dos acciones:

- `position[2:0]` se actualiza con la nueva posición.
- `position_valid` genera un pulso indicando que el dato está disponible.

La secuencia de funcionamiento es:

1. Se recibe `position_async[2:0]` desde el circuito discreto.
2. Los tres bits son sincronizados con el reloj interno de la FPGA.
3. El nuevo valor se almacena como posición candidata.
4. Se comprueba su estabilidad utilizando `ce_1ms`.
5. Si el valor cambia, se reinicia la comprobación.
6. Si permanece estable durante el tiempo establecido, se actualiza `position`.
7. Se genera un pulso en `position_valid`.

#### Codificación de la posición

Al utilizar un bus de tres bits es posible representar las ocho posiciones del juego.

| `position[2]` | `position[1]` | `position[0]` | Posición |
|:---:|:---:|:---:|---:|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 |
| 0 | 1 | 0 | 2 |
| 0 | 1 | 1 | 3 |
| 1 | 0 | 0 | 4 |
| 1 | 0 | 1 | 5 |
| 1 | 1 | 0 | 6 |
| 1 | 1 | 1 | 7 |

#### Relación con el sistema

La salida `position` representa la posición que será utilizada durante el turno, mientras que `position_valid` informa a la máquina de estados principal que una nueva posición ha sido recibida correctamente.

La máquina de estados utiliza `position_valid` para continuar con el inicio de la ventana de juego.

Este módulo permite que el enlace paralelo con el circuito discreto sea utilizado de forma más confiable, evitando que cambios transitorios o inestables sean interpretados como posiciones válidas.

### 8.6 `mole_request_generator`

El módulo `mole_request_generator` se encarga de generar la señal `solicitud_topo`, utilizada para indicar al subsistema de lógica discreta que debe generar una nueva posición para el siguiente turno del juego.

La máquina de estados principal determina cuándo es necesario solicitar una nueva posición y genera un pulso mediante la señal `start`. A partir de este evento, `mole_request_generator` controla la duración de la señal enviada al circuito externo y administra posibles solicitudes recibidas mientras el módulo todavía se encuentra ocupado.

#### Entradas y salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `clk` | Entrada | Reloj principal del sistema |
| `reset` | Entrada | Reinicio del módulo |
| `ce_1ms` | Entrada | Habilitación utilizada como referencia temporal |
| `start` | Entrada | Orden proveniente del controlador para generar una nueva solicitud |
| `solicitud_topo` | Salida | Señal enviada al subsistema de lógica discreta |
| `busy` | Salida | Indica que actualmente se está generando una solicitud |
| `done` | Salida | Pulso que indica que la solicitud ha finalizado |

#### Funcionamiento

Cuando se recibe un pulso en `start` y el módulo no se encuentra ocupado, la señal `solicitud_topo` se activa. Al mismo tiempo, `busy` pasa a nivel alto para indicar que existe una solicitud en proceso.

La duración de `solicitud_topo` se controla mediante un contador interno que avanza utilizando `ce_1ms`. De esta manera, el tiempo de activación puede definirse directamente en milisegundos.

En la implementación final se configuró:

```text
REQUEST_PULSE_MS = 500 ms
```

Por lo tanto, cada solicitud permanece activa durante aproximadamente 500 ms. Una vez finalizado este intervalo, `solicitud_topo` y `busy` regresan a nivel bajo y se genera un pulso en `done`.

La secuencia de funcionamiento se resume en la siguiente tabla:

| Condición | `solicitud_topo` | `busy` | `done` | Acción |
|---|:---:|:---:|:---:|---|
| Estado inicial | 0 | 0 | 0 | El módulo espera una solicitud |
| `start = 1` | 1 | 1 | 0 | Inicia una nueva solicitud |
| Durante el intervalo configurado | 1 | 1 | 0 | La solicitud permanece activa |
| Final del intervalo | 0 | 0 | 1 | Finaliza la solicitud |
| Después de finalizar | 0 | 0 | 0 | El módulo vuelve a estar disponible |

#### Manejo de solicitudes pendientes

El módulo también contempla la posibilidad de recibir una nueva orden mientras una solicitud anterior todavía se encuentra activa.

Si `start` se activa mientras `busy = 1`, la nueva petición se almacena internamente como una solicitud pendiente. Esto permite evitar que una orden proveniente de la máquina de estados se pierda por encontrarse el generador ocupado.

Al finalizar la solicitud actual, el módulo procesa posteriormente la solicitud almacenada. Entre ambas solicitudes se mantiene un intervalo en nivel bajo, permitiendo que el circuito discreto pueda distinguir el final de una solicitud y el comienzo de la siguiente.

Este comportamiento mejora la confiabilidad de la comunicación entre la FPGA y el subsistema discreto, especialmente cuando las órdenes se producen con poca separación temporal.

#### Relación con el sistema

`mole_request_generator` sirve como interfaz entre la máquina de estados principal y el circuito de lógica discreta.

La máquina de estados determina **cuándo** debe solicitarse una nueva posición, mientras que este módulo determina **cómo y durante cuánto tiempo** debe mantenerse activa la señal física `solicitud_topo`.

La secuencia general es:

1. La máquina de estados genera `start`.
2. `mole_request_generator` activa `solicitud_topo`.
3. El circuito discreto recibe la solicitud.
4. El circuito discreto genera una nueva posición.
5. Al finalizar el tiempo configurado, el generador desactiva `solicitud_topo`.
6. `done` indica que el proceso de solicitud terminó.

Esta separación permite mantener independiente la lógica de control del juego de la temporización necesaria para comunicarse con el circuito externo.

### 8.7 `game_hit_evaluator`

## Entradas

| Señal | Tipo | Descripción |
|---|---|---|
| `turn_active` | `logic` | Bandera que indica si el sistema debe evaluar entradas en ese momento (turno de juego en curso). |
| `active_position` | `logic [2:0]` | Índice binario (0–7) que indica cuál de los 8 topos está activo actualmente. |
| `buttons_pulse` | `logic [7:0]` | Vector de 8 bits donde cada bit representa el pulso de un botón físico; se espera que solo un bit esté en 1 cuando el jugador presiona. |

## Salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `active_mole_onehot` | `logic [7:0]` | Representación one-hot de `active_position`; tiene un único bit en 1 correspondiente a la posición del topo activo. |
| `any_press` | `logic` | Se activa (`1`) cuando al menos un bit de `buttons_pulse` está en 1, es decir, hubo alguna pulsación. |
| `hit_pulse` | `logic` | Se activa cuando el botón presionado coincide exactamente con la posición del topo activo. |
| `miss_pulse` | `logic` | Se activa cuando hubo una pulsación pero no coincide con la posición del topo activo. |

## Funcionamiento 

La señal `active_position` llega como un número binario de 3 bits (0 a 7), pero para compararla directamente contra `buttons_pulse` (que es un vector de 8 bits, uno por botón), se necesita convertirla a formato **one-hot**. Esto se logra con: `active_mole_onehot = 8'b0000_0001 << active_position`
Esta operación desplaza un único bit en 1 hacia la izquierda tantas posiciones como indique `active_position`. Por ejemplo, si `active_position = 3`, el resultado es `8'b0000_1000`, es decir, el bit correspondiente al topo #3 queda en 1 y todos los demás en 0.

Una vez obtenida esta representación, el módulo evalúa el resultado de la jugada solo si `turn_active` está activo y `any_press` detectó una pulsación:

- **Acierto (`hit_pulse`)**: ocurre cuando `buttons_pulse` es **exactamente igual** a `active_mole_onehot`, es decir, el jugador presionó el único botón correspondiente a la posición del topo activo.
- **Fallo (`miss_pulse`)**: ocurre cuando hubo pulsación (`any_press = 1`) pero `buttons_pulse` **no coincide** con `active_mole_onehot`, ya sea porque se presionó un botón incorrecto o porque se presionó más de un botón simultáneamente.

Esta comparación exacta (`==`) es lo que garantiza que solo se considere acierto cuando el botón presionado corresponde precisamente a la posición activa, descartando cualquier otra combinación como fallo.

## Relación con el sistema

Este módulo actúa como el **evaluador de jugadas** dentro del sistema "Whack-a-mole": recibe la posición del topo activo (generada por la lógica de control/secuenciador del juego) y las pulsaciones físicas de los botones (ya sincronizadas/depuradas como pulsos), y produce las señales `hit_pulse` / `miss_pulse` que la lógica de control superior (contador de puntaje, máquina de estados del juego, temporizador de ronda) utiliza para actualizar el marcador, avanzar de ronda o determinar el fin del juego. Al ser puramente combinacional (`always_comb`), no introduce retardo de reloj adicional: su salida depende únicamente del estado actual de sus entradas en cada ciclo.

### 8.8 `turn_window_timer`

## Entradas

| Señal | Tipo | Descripción |
|---|---|---|
| `clk` | `logic` | Señal de reloj del sistema; el bloque secuencial se actualiza en cada flanco de subida. |
| `reset` | `logic` | Reset síncrono; al activarse, limpia el contador y desactiva la ventana de turno. |
| `ce_1ms` | `logic` | Pulso habilitador que ocurre cada 1 ms; actúa como base de tiempo para incrementar el contador. |
| `start` | `logic` | Señal que inicia una nueva ventana de turno, reiniciando el contador y activando `active`. |
| `cancel` | `logic` | Señal que cancela la ventana activa antes de que expire (ej. cuando el jugador ya acertó). |
| `duration_ms` | `logic [10:0]` | Duración total de la ventana de turno, expresada en milisegundos. |

## Salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `active` | `logic` | Indica si la ventana de turno está actualmente en curso (contando tiempo). |
| `timeout_pulse` | `logic` | Pulso de un solo ciclo de reloj que se activa cuando el tiempo de la ventana se agota sin cancelación. |

## Funcionamiento (Conteo de ventana de tiempo y prioridad de cancelación)

El módulo implementa un temporizador descendente basado en un contador ascendente interno (`elapsed_ms`) que se compara contra `duration_ms`. La base de tiempo la da `ce_1ms`, un pulso externo de 1 ms, de modo que `elapsed_ms` solo avanza un conteo por cada milisegundo real transcurrido, y no en cada flanco de `clk`.

La lógica evalúa las condiciones en el siguiente orden de prioridad:

1. **`reset`**: limpia todo el estado (mayor prioridad, síncrono).
2. **`cancel`**: cierra la ventana (`active = 0`) y reinicia el contador **sin** generar `timeout_pulse`. Esto evita que, si el jugador ya golpeó el topo correcto (evento externo que dispara `cancel`), el temporizador genere un timeout tardío e inválido.
3. **`start`**: reinicia el contador y activa la ventana, dando inicio a una nueva medición.
4. **Conteo normal** (`active && ce_1ms`): en cada pulso de 1 ms, se compara `elapsed_ms` contra `duration_ms - 1`. Se usa `duration_ms - 1` porque el conteo empieza en 0, así que al llegar a `duration_ms - 1` ya transcurrieron `duration_ms` milisegundos completos. También se contempla el caso borde `duration_ms <= 1`, generando el timeout inmediatamente en el primer pulso para evitar desbordes o comparaciones inválidas.
   - Si se cumple la condición de expiración: se reinicia el contador, se desactiva `active` y se emite `timeout_pulse` por un ciclo.
   - Si no, simplemente se incrementa `elapsed_ms`.

## Relación con el sistema

Este módulo funciona como el **reloj de la ventana de reacción** dentro del sistema "Whack-a-mole": mide cuánto tiempo tiene el jugador para golpear el topo activo antes de que se considere un turno perdido. La señal `start` normalmente la genera la máquina de estados principal al activar un nuevo topo; `cancel` se dispara desde la lógica de evaluación de aciertos (`game_hit_evaluator`) cuando ocurre un `hit_pulse`, evitando un timeout espurio tras un golpe exitoso. La salida `timeout_pulse` alimenta a la máquina de estados de control para registrar el fallo por tiempo agotado y avanzar a la siguiente ronda, mientras que `active` puede usarse para habilitar otras señales (como indicadores visuales) mientras el turno está en curso.

### 8.9 `difficulty_controller`

## Entradas

| Señal | Tipo | Descripción |
|---|---|---|
| `clk` | `logic` | Señal de reloj del sistema; la duración se actualiza en cada flanco de subida. |
| `reset` | `logic` | Reset síncrono; al activarse, restaura `duration_ms` a `INITIAL_MS` (1500 ms). |
| `hit_pulse` | `logic` | Pulso de acierto; cada vez que se activa, reduce la duración de la ventana en `STEP_MS`. |
| `miss_pulse` | `logic` | Pulso de fallo; al activarse, la duración actual se mantiene sin cambios. |

### Parámetros

| Parámetro | Valor por defecto | Descripción |
|---|---|---|
| `INITIAL_MS` | 1500 ms | Duración de la ventana antes de cualquier acierto. |
| `MINIMUM_MS` | 500 ms | Duración mínima a la que puede llegar la ventana (piso de dificultad). |
| `STEP_MS` | 100 ms | Cantidad en que se reduce la duración por cada acierto acumulado. |

## Salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `duration_ms` | `logic [10:0]` | Duración vigente de la ventana de reacción, en milisegundos; se recalcula con cada acierto y se conserva en cada fallo. |

## Funcionamiento (Escalado de dificultad por aciertos)

El módulo ajusta la dificultad del juego reduciendo progresivamente `duration_ms` (la duración de la ventana de reacción) a medida que el jugador acumula aciertos, según la siguiente relación:

| Aciertos que reducen | Duración |
|---|---|
| 0 | 1500 ms |
| 1 | 1400 ms |
| 2 | 1300 ms |
| 3 | 1200 ms |
| 4 | 1100 ms |
| 5 | 1000 ms |
| 6 | 900 ms |
| 7 | 800 ms |
| 8 | 700 ms |
| 9 | 600 ms |
| 10 o más | 500 ms |

Cada vez que ocurre `hit_pulse`, la duración se reduce en `STEP_MS` (100 ms), siempre que quede por encima de `MINIMUM_MS + STEP_MS`; en caso contrario, se satura directamente en `MINIMUM_MS` (500 ms) para evitar que el resultado de la resta sea menor al piso definido. Esto reproduce exactamente la tabla: después de 10 aciertos consecutivos, la duración llega a su valor mínimo de 500 ms y ya no sigue bajando.

Cuando ocurre `miss_pulse`, la duración **no cambia** — el comentario del código lo indica explícitamente ("la dificultad alcanzada se conserva después de un fallo"), es decir, un fallo no facilita el juego ni retrocede la dificultad ya ganada; solo los aciertos la modifican.

## Relación con el sistema

Este módulo es el **controlador de dificultad adaptativa** del sistema "Whack-a-mole": recibe directamente `hit_pulse` y `miss_pulse` desde `game_hit_evaluator`, y su salida `duration_ms` alimenta a `turn_window_timer` como el parámetro `duration_ms` de cada nueva ventana de turno (vía la señal `start`). De esta forma, cada vez que el jugador acierta, el siguiente topo tendrá una ventana de tiempo más corta, incrementando la dificultad del juego de forma dinámica y acumulativa, mientras que los fallos no alteran el nivel de dificultad ya alcanzado.

### 8.10 `score_counters`

## Entradas

| Señal | Tipo | Descripción |
|---|---|---|
| `clk` | `logic` | Señal de reloj del sistema; los contadores se actualizan en cada flanco de subida. |
| `reset` | `logic` | Reset síncrono; al activarse, ambos contadores (`hits` y `misses`) vuelven a 0. |
| `hit_pulse` | `logic` | Pulso de acierto; cada vez que se activa, incrementa el contador `hits` en 1. |
| `miss_pulse` | `logic` | Pulso de fallo; cada vez que se activa, incrementa el contador `misses` en 1. |

### Parámetros

| Parámetro | Valor por defecto | Descripción |
|---|---|---|
| `MAX_SCORE` | 99 | Valor máximo que puede alcanzar cada contador antes de dejar de incrementarse. |

## Salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `hits` | `logic [6:0]` | Cantidad acumulada de aciertos del jugador durante la partida. |
| `misses` | `logic [6:0]` | Cantidad acumulada de fallos del jugador durante la partida. |

## Funcionamiento (Conteo saturado de aciertos y fallos)

El módulo mantiene dos contadores independientes de 7 bits (`hits` y `misses`), cada uno incrementándose de forma exclusiva según el pulso correspondiente. Ambos contadores pueden incrementarse en el mismo ciclo si, por alguna razón, llegaran a activarse `hit_pulse` y `miss_pulse` simultáneamente, ya que las dos condiciones se evalúan de forma independiente (no son `else if`).

Cada incremento está protegido por una **condición de saturación**: `hits` solo aumenta si `hits < MAX_SCORE`, y `misses` solo aumenta si `misses < MAX_SCORE`. Esto evita el desbordamiento (overflow) del contador de 7 bits una vez alcanzado el valor máximo definido (99 por defecto), dejando el contador fijo en ese tope en lugar de reiniciarse a 0.

## Relación con el sistema

Este módulo actúa como el **marcador de la partida** dentro del sistema "Whack-a-mole": recibe las mismas señales `hit_pulse` y `miss_pulse` generadas por `game_hit_evaluator` (las mismas que también alimentan a `difficulty_controller`), y lleva el conteo total de aciertos y fallos a lo largo del juego. Sus salidas `hits` y `misses` normalmente se envían a un módulo de visualización (display de 7 segmentos, LEDs, etc.) para mostrarle al jugador su desempeño, y también pueden usarse por la lógica de control superior para determinar condiciones de fin de partida (por ejemplo, un número máximo de rondas o de fallos permitidos).

### 8.11 `consecutive_misses`
 
Lleva la cuenta de los fallos consecutivos del jugador, a diferencia del contador de fallos acumulados (8.10), que nunca se reinicia durante la partida. Un acierto (`hit_pulse`) tiene prioridad y reinicia el contador `miss_count` a cero; un fallo (`miss_pulse`) lo incrementa mientras no haya alcanzado 3. El módulo entrega dos salidas distintas: `three_misses`, una señal de nivel combinacional que permanece en alto mientras el contador esté en 3, y `third_miss_pulse`, un pulso registrado de un solo ciclo generado exactamente en el instante en que se completa el tercer fallo. Esta separación es necesaria porque `game_controller_fsm` (8.13) requiere un evento de un ciclo para disparar la transición hacia el estado de game over, evitando ambigüedades que produciría una señal de nivel.
 
| Señal | Dirección | Descripción |
|---|---|---|
| `clk`, `reset` | Entrada | Reloj y reinicio síncrono. |
| `hit_pulse` | Entrada | Pulso de acierto; reinicia el contador. |
| `miss_pulse` | Entrada | Pulso de fallo; incrementa el contador. |
| `miss_count[1:0]` | Salida | Valor actual del contador (0–3). |
| `three_misses` | Salida | Nivel alto mientras el contador esté en 3. |
| `third_miss_pulse` | Salida | Pulso de un ciclo al completarse el tercer fallo. |
 
Ver [`consecutive_misses.sv`](./consecutive_misses.sv).
 
---
 
### 8.12 `game_over_timer`
 
Mide el intervalo de 2000 ms (parámetro `GAME_OVER_MS`) durante el cual el sistema permanece en la pantalla de fin de partida antes de reiniciarse automáticamente. Su estructura reutiliza el mismo principio que `turn_window_timer` (8.8): un contador impulsado por la habilitación temporal `ce_1ms` en lugar de un reloj independiente, con ancho dimensionado automáticamente mediante `$clog2(GAME_OVER_MS)` para que el módulo sea reutilizable ante otros valores del parámetro. Al recibir `start` (proveniente de `game_over_start` en la FSM), el contador arranca y `active` se activa; al cumplirse el tiempo configurado, se genera `done_pulse` durante un ciclo, que la FSM utiliza como `game_over_done` para avanzar hacia el reinicio automático.
 
| Señal | Dirección | Descripción |
|---|---|---|
| `GAME_OVER_MS` | Parámetro | Duración en milisegundos (2000 por defecto). |
| `clk`, `reset` | Entrada | Reloj y reinicio síncrono. |
| `ce_1ms` | Entrada | Habilitación temporal de 1 ms. |
| `start` | Entrada | Arranca el temporizador. |
| `active` | Salida | Indica que el temporizador está en curso. |
| `done_pulse` | Salida | Pulso de un ciclo al cumplirse el tiempo. |
 
Ver [`game_over_timer.sv`](./game_over_timer.sv).
 
---

### 8.13 `game_controller_fsm`

![FSM principal](figuras/fsm_principal.png)
 
Es el controlador central del juego: coordina la secuencia de un turno completo (solicitud de posición, espera de posición válida, inicio del turno, resolución de acierto o fallo) y gestiona la transición hacia la secuencia de fin de partida y el reinicio automático. Se implementa como una FSM de Moore de 9 estados, con un registro de estado y dos bloques combinacionales (siguiente estado y salidas):

| Estado | Función |
|---|---|
| `ST_REQUEST_START` | Inicia solicitud |
| `ST_WAIT_POSITION` | Espera posición válida |
| `ST_START_TURN` | Inicia la ventana |
| `ST_PLAY` | Espera golpe o timeout |
| `ST_RESOLVE_HIT` | Resuelve acierto |
| `ST_RESOLVE_MISS` | Resuelve fallo |
| `ST_GAME_OVER_START` | Inicia game over |
| `ST_GAME_OVER_WAIT` | Espera dos segundos |
| `ST_AUTO_RESET` | Reinicia datos |

Desde `ST_PLAY`, un acierto (`hit_pulse`) lleva a `ST_RESOLVE_HIT`, que siempre regresa a `ST_REQUEST_START`; un fallo o un `timeout_pulse` llevan a `ST_RESOLVE_MISS`. Ahí se evalúa `third_miss_pulse` (proveniente de 8.11): si no se han acumulado tres fallos consecutivos, la partida continúa; si se cumple la condición, la FSM entra en `ST_GAME_OVER_START → ST_GAME_OVER_WAIT`, donde permanece hasta que `game_over_done` (proveniente de 8.12) indique su finalización. `ST_AUTO_RESET` activa `game_data_reset` para limpiar los contadores de la partida antes de reiniciar el ciclo automáticamente, sin intervención del jugador. La salida `state_debug[3:0]` expone el estado actual únicamente con fines de depuración.
 
Ver [`game_controller_fsm.sv`](./game_controller_fsm.sv).
 
---
### 8.14 `seven_segment_controller`
 
Multiplexa en el tiempo los cuatro dígitos que muestran, de forma simultánea a la vista del usuario, los aciertos y los fallos acumulados (dos dígitos decimales cada uno). Un contador de 2 bits (`scan_index`), incrementado a 1 kHz mediante `ce_1ms`, selecciona cíclicamente el dígito activo; según el dígito, se calcula la unidad o decena correspondiente mediante módulo (`%`) y división entera (`/`) por 10 sobre `hits` o `misses`. El resultado se traduce a los patrones de segmentos mediante una tabla de decodificación activa en bajo, propia del hardware de la Nexys 4 (`seg[0]=A` … `seg[6]=G`). La salida `an[7:0]` se dimensionó según el ancho real del bus de ánodos de los ocho dígitos físicos de la tarjeta, aunque solo se controlan activamente los cuatro primeros; el punto decimal (`dp`) permanece apagado de forma permanente.
 
Ver [`seven_segment_controller.sv`](./seven_segment_controller.sv).
 

### 8.15 `status_indicator`

[LED fijo durante juego y parpadeante durante game over.]

### 8.16 `whack_a_mole_top`

El módulo `whack_a_mole_top` corresponde al nivel superior del subsistema implementado en la FPGA. Su función principal es integrar los diferentes módulos desarrollados y establecer las conexiones necesarias para ejecutar la lógica completa del juego.

En este módulo se reciben las señales provenientes del circuito discreto y de los pulsadores externos, mientras que internamente se coordinan la recepción de la posición, la evaluación de la jugada, la temporización, los contadores, la dificultad, el control de Game Over y la visualización de resultados.

#### Parámetros principales

| Parámetro | Valor utilizado | Descripción |
|---|---:|---|
| `CLK_FREQ_HZ` | 100 MHz | Frecuencia del reloj principal de la FPGA |
| `BUTTON_DEBOUNCE_MS` | 10 ms | Tiempo de antirrebote de los pulsadores |
| `POSITION_STABLE_MS` | 2 ms | Tiempo requerido para validar una posición |
| `REQUEST_PULSE_MS` | 500 ms | Duración de la señal `solicitud_topo` |
| `INITIAL_MS` | 1500 ms | Duración inicial de la ventana de juego |
| `MINIMUM_MS` | 500 ms | Duración mínima de la ventana |
| `STEP_MS` | 100 ms | Reducción de tiempo producida por cada acierto |
| `GAME_OVER_MS` | 2000 ms | Duración del estado de fin de juego |
| `STATUS_BLINK_MS` | 250 ms | Periodo utilizado para el parpadeo del LED de estado |

#### Entradas y salidas

| Señal | Tipo | Descripción |
|---|---|---|
| `clk` | Entrada | Reloj principal de 100 MHz |
| `reset_button` | Entrada | Pulsador utilizado para reiniciar el sistema |
| `position_async[2:0]` | Entrada | Posición generada por el circuito discreto |
| `buttons_async[7:0]` | Entrada | Ocho pulsadores externos del jugador |
| `solicitud_topo` | Salida | Solicitud enviada al circuito discreto para generar una nueva posición |
| `mole_leds[7:0]` | Salida | Representación one-hot de la posición activa |
| `status_led` | Salida | Indicador del estado general del juego |
| `seg[6:0]` | Salida | Control de los segmentos del display |
| `dp` | Salida | Control del punto decimal |
| `an[7:0]` | Salida | Selección de los dígitos del display |

#### Funcionamiento

El módulo principal coordina el funcionamiento de los diferentes bloques del sistema. Todos los módulos trabajan utilizando el mismo reloj principal de 100 MHz, mientras que `ce_1ms_generator` produce una habilitación periódica utilizada por los bloques que requieren medición de tiempo en milisegundos.

El pulsador de reset es una señal externa y se sincroniza antes de utilizarse dentro del sistema. Posteriormente, las señales externas correspondientes a los botones y a la posición del topo son procesadas por `button_bank` y `parallel_position_receiver`, respectivamente.

La posición recibida es validada antes de iniciar un nuevo turno. Al mismo tiempo, `mole_request_generator` se encarga de generar la señal `solicitud_topo` cuando la máquina de estados solicita una nueva posición.

Durante un turno, `game_hit_evaluator` compara la posición activa con los pulsos producidos por los botones. De esta comparación se determina si el jugador realizó un acierto o un fallo.

El módulo `turn_window_timer` controla el tiempo disponible para realizar cada golpe. Si el jugador no presiona un botón antes de terminar la ventana, se genera un evento de timeout.

Los resultados de cada turno son utilizados por los módulos encargados de la dificultad, los puntajes y los fallos consecutivos. Cuando se producen tres fallos consecutivos, la máquina de estados inicia el proceso de Game Over.

Finalmente, `seven_segment_controller` muestra los aciertos y fallos acumulados en los displays, mientras que `status_indicator` controla el LED utilizado para indicar el estado del juego.

#### Módulos integrados

El módulo `whack_a_mole_top` instancia los siguientes bloques:

| Módulo | Función |
|---|---|
| `ce_1ms_generator` | Genera la habilitación temporal de 1 ms |
| `button_bank` | Sincroniza y filtra los ocho pulsadores |
| `parallel_position_receiver` | Sincroniza y valida la posición recibida |
| `mole_request_generator` | Genera la solicitud de una nueva posición |
| `game_hit_evaluator` | Determina si una pulsación corresponde a acierto o fallo |
| `turn_window_timer` | Controla la duración de cada turno |
| `difficulty_controller` | Reduce progresivamente la duración de la ventana |
| `score_counters` | Almacena los aciertos y fallos acumulados |
| `consecutive_misses` | Detecta tres fallos consecutivos |
| `game_over_timer` | Controla la duración del estado Game Over |
| `game_controller_fsm` | Coordina la secuencia principal del juego |
| `seven_segment_controller` | Controla los displays de siete segmentos |
| `status_indicator` | Controla el LED indicador del estado |

#### Señal `data_reset`

El sistema puede reiniciarse de dos formas diferentes. La primera corresponde al reset manual generado mediante `reset_button`, mientras que la segunda corresponde al reinicio automático generado por la máquina de estados después de finalizar una partida.

Para combinar ambos eventos se utiliza:

```systemverilog
assign data_reset = reset | game_data_reset;
```

La señal `data_reset` es utilizada por los módulos que almacenan información propia de una partida, como el temporizador del turno, el controlador de dificultad, los contadores de puntaje y el contador de fallos consecutivos.

De esta manera, cuando se produce un Game Over y finaliza el tiempo correspondiente, la máquina de estados puede reiniciar los datos del juego sin necesidad de que el jugador presione nuevamente el botón de reset.

#### Señal `effective_miss_pulse`

Dentro del juego un fallo puede producirse de dos maneras diferentes:

- El jugador presiona un botón que no corresponde con la posición activa.
- Se agota el tiempo disponible sin que se produzca un acierto.

El primer caso produce `button_miss_pulse`, mientras que el segundo genera `timeout_pulse`.

Para que los módulos encargados de puntajes, dificultad y fallos consecutivos no tengan que manejar ambos eventos de forma independiente, se genera:

```systemverilog
assign effective_miss_pulse = button_miss_pulse | timeout_pulse;
```

Por lo tanto, `effective_miss_pulse` representa cualquier evento que deba ser considerado como un fallo dentro del juego.

Esta señal es utilizada por `difficulty_controller`, `score_counters` y `consecutive_misses`, permitiendo que un fallo por botón incorrecto y un fallo por tiempo agotado produzcan el mismo efecto sobre los datos de la partida.

#### Flujo general de una jugada

El funcionamiento integrado del módulo principal puede resumirse en los siguientes pasos:

1. La máquina de estados solicita una nueva posición.
2. `mole_request_generator` activa `solicitud_topo`.
3. El circuito discreto genera una nueva posición.
4. `parallel_position_receiver` sincroniza y valida la posición recibida.
5. La máquina de estados inicia un nuevo turno.
6. `turn_window_timer` abre la ventana temporal correspondiente.
7. `button_bank` detecta las pulsaciones válidas realizadas por el jugador.
8. `game_hit_evaluator` determina si la pulsación corresponde a un acierto o a un fallo.
9. Si se agota el tiempo, el evento también es considerado como un fallo.
10. Los contadores y el controlador de dificultad se actualizan según el resultado.
11. `consecutive_misses` determina si se alcanzaron tres fallos consecutivos.
12. Si la partida puede continuar, se solicita una nueva posición.
13. Si se alcanzan tres fallos consecutivos, se inicia el estado de Game Over.
14. Al finalizar Game Over, se genera `game_data_reset` y comienza automáticamente una nueva partida.

La integración de estas funciones dentro de `whack_a_mole_top` permite mantener una estructura modular, donde cada bloque realiza una tarea específica y el módulo principal se encarga de establecer las conexiones entre todos ellos.

---

## 9. Asignación de pines

### 9.1 Posición y solicitud

| Señal | Conector | Pin FPGA |
|---|---|---|
| Q0 | JA1 | B13 |
| Q1 | JA2 | F14 |
| Q2 | JA3 | D17 |
| `solicitud_topo` | JA4 | E17 |

### 9.2 Botones

| Botón | Conector | Pin FPGA |
|---:|---|---|
| 0 | JB1 | G14 |
| 1 | JB2 | P15 |
| 2 | JB3 | V11 |
| 3 | JB4 | V15 |
| 4 | JB7 | K16 |
| 5 | JB8 | R16 |
| 6 | JB9 | T9 |
| 7 | JB10 | U11 |

![Conexiones](figuras/conexiones.png)

---

## 10. Verificación por simulación

### 10.1 Metodología

[Explicar testbenches autoverificables, estímulos, comparaciones, `PASS`, `$error`, `$fatal` y parámetros reducidos.]

### 10.2 Resultados

| Testbench | Cobertura | Resultado |
|---|---|---|
| `tb_ce_1ms_generator` | Periodo, ancho y reset | [ ] |
| `tb_button_bank` | Rebote y botones simultáneos | [ ] |
| `tb_parallel_position_receiver` | Estabilidad y validación | [ ] |
| `tb_mole_request_generator` | Pulso, `busy` y pendiente | [ ] |
| `tb_game_hit_evaluator` | Acierto, fallo y simultaneidad | [ ] |
| `tb_turn_window_timer` | Inicio, cancelación y timeout | [ ] |
| `tb_difficulty_controller` | Reducción y saturación | [ ] |
| `tb_score_counters` | Incrementos y saturación | [ ] |
| `tb_consecutive_misses` | Tres fallos y reinicio | [ ] |
| `tb_game_over_timer` | Duración y finalización | [ ] |
| `tb_game_controller_fsm` | Recorrido de estados | [ ] |
| `tb_seven_segment_controller` | Dígitos y patrones | [ ] |
| `tb_status_indicator` | Juego y game over | [ ] |
| `tb_whack_a_mole_top` | Integración completa | [ ] |

### 10.3 Evidencias

![Simulación del temporizador](figuras/simulaciones/turn_timer.png)

![Simulación de la FSM](figuras/simulaciones/fsm.png)

![Simulación integral](figuras/simulaciones/top.png)

Para cada figura explicar estímulo, señales observadas, resultado esperado, resultado obtenido e interpretación.

---

## 11. Síntesis e implementación

### 11.1 Utilización de recursos

| Recurso | Utilizado | Disponible | Porcentaje |
|---|---:|---:|---:|
| LUT | [ ] | [ ] | [ ] |
| Flip-flops | [ ] | [ ] | [ ] |
| I/O | [ ] | [ ] | [ ] |
| BUFG | [ ] | [ ] | [ ] |

### 11.2 Análisis temporal

| Parámetro | Resultado |
|---|---:|
| Frecuencia objetivo | 100 MHz |
| Periodo objetivo | 10 ns |
| Worst Negative Slack | [COMPLETAR] |
| Timing constraints met | [Sí/No] |

### 11.3 Advertencias

[Documentar warnings y explicar cómo se resolvieron o por qué son aceptables.]

### 11.4 Jerarquía RTL

![Jerarquía RTL](figuras/rtl_hierarchy.png)

---

## 12. Implementación experimental

### 12.1 Montaje

![Montaje final](figuras/montaje_final/montaje_general.png)

### 12.2 Procedimiento de prueba

1. Verificar alimentación y tierra común.
2. Medir `Q0`, `Q1` y `Q2`.
3. Reiniciar el LFSR.
4. Programar la FPGA.
5. Verificar `SOLICITUD_TOPO`.
6. Probar los ocho botones.
7. Probar aciertos y fallos.
8. Probar timeout.
9. Probar game over.

### 12.3 Mediciones

| Señal | Teórico | Medido | Instrumento | Observación |
|---|---:|---:|---|---|
| Alimentación TTL | 5 V | [ ] | Multímetro | [ ] |
| Alimentación FPGA | 3.3 V | [ ] | Multímetro | [ ] |
| Q alto antes del divisor | [ ] | [ ] | Multímetro | [ ] |
| Q alto después del divisor | [ ] | [ ] | Multímetro | [ ] |
| Solicitud inactiva | 5 V | [ ] | Multímetro | [ ] |
| Solicitud activa | ~0 V | [ ] | Multímetro | [ ] |

### 12.4 Pruebas funcionales

| Prueba | Esperado | Obtenido | Estado |
|---|---|---|---|
| Botón correcto | Incrementa aciertos | [ ] | [ ] |
| Botón incorrecto | Incrementa fallos | [ ] | [ ] |
| Timeout | Incrementa fallos | [ ] | [ ] |
| Acierto tras fallos | Reinicia vidas | [ ] | [ ] |
| Tres fallos | Game over | [ ] | [ ] |
| Auto-reset | Puntajes en cero | [ ] | [ ] |
| Dificultad | Reduce la ventana | [ ] | [ ] |
| Solicitud | Avanza el LFSR | [ ] | [ ] |

---

## 13. Análisis e interpretación de resultados

### 13.1 Comparación teórica, simulada y experimental

| Característica | Teórico | Simulado | Experimental | Diferencia |
|---|---:|---:|---:|---|
| `ce_1ms` | 1 ms | [ ] | [ ] | [ ] |
| Antirrebote | 10 ms | [ ] | [ ] | [ ] |
| Ventana inicial | 1500 ms | [ ] | [ ] | [ ] |
| Ventana mínima | 500 ms | [ ] | [ ] | [ ] |
| Game over | 2000 ms | [ ] | [ ] | [ ] |
| Solicitud | 500 ms | [ ] | [ ] | [ ] |
| Separación de solicitudes | 100 ms | [ ] | [ ] | [ ] |

### 13.2 Análisis del LFSR

Comparar secuencia teórica y medida, periodo, estados ausentes, bloqueo en `000`, comportamiento de LED1, causa y solución recomendada.

### 13.3 Análisis de comunicación

Explicar:

- Problemas encontrados con UART.
- Pruebas UART que sí funcionaron.
- Motivo para usar el bus paralelo.
- Ventajas y limitaciones del cambio.
- Consecuencias sobre la rúbrica.

### 13.4 Análisis de la FPGA

[Analizar simulación, síntesis, timing, clock enable, ausencia de latches y comportamiento físico.]

### 13.5 Problemas y soluciones

| Problema | Causa | Diagnóstico | Solución |
|---|---|---|---|
| UART inestable | [ ] | [ ] | Enlace paralelo |
| Solicitud perdida | Pulso ocupado | LEDs de diagnóstico | Solicitud pendiente |
| Bloqueo LED0 | Estado `000` | Secuencia LFSR | [ ] |
| Bloqueo LED1 | Solicitud no reconocida | FSM en `WAIT_POSITION` | [ ] |
| Niveles de 5 V | Incompatibilidad | Multímetro | Divisores y 2N2222 |

---

## 14. Cumplimiento de requisitos

| Requisito | Cumplido | Evidencia | Observación |
|---|:---:|---|---|
| LFSR discreto | [ ] | [ ] | [ ] |
| 74LS138 y ocho LEDs | [ ] | [ ] | [ ] |
| Solicitud de topo | [ ] | [ ] | [ ] |
| UART 8N1 | No | Testbench parcial | Sustituido por paralelo |
| Ocho botones externos | [ ] | [ ] | [ ] |
| Antirrebote | [ ] | [ ] | [ ] |
| FSM | [ ] | [ ] | [ ] |
| Dificultad progresiva | [ ] | [ ] | [ ] |
| Puntajes 00-99 | [ ] | [ ] | [ ] |
| Tres fallos consecutivos | [ ] | [ ] | [ ] |
| Game over de 2 s | [ ] | [ ] | [ ] |
| Reset manual | [ ] | [ ] | [ ] |
| Testbenches autoverificables | [ ] | [ ] | [ ] |

---

## 15. Conclusiones

[Redactar conclusiones basadas directamente en objetivos y resultados. Incluir funcionamiento modular, verificación, implementación física, limitaciones del LFSR, consecuencias de sustituir UART y mejoras necesarias.]

---

## 16. Trabajo futuro

- Corregir definitivamente el LFSR.
- Considerar un LFSR de cuatro bits.
- Restaurar UART 8N1.
- Agregar `data_valid` al enlace paralelo.
- Mejorar adaptación de niveles.
- Medir solicitudes y relojes con osciloscopio.
- Ampliar cobertura de pruebas.
- [ ] Las referencias están completas.
- [ ] No se utiliza un PDF como entrega oficial.
