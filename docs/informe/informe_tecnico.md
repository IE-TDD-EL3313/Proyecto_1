
# Informe técnico: Whack-a-Mole con lógica discreta y FPGA

## Resumen

[COMPLETAR EN 150-250 PALABRAS]

Resumir el objetivo, la división entre lógica discreta y FPGA, el método de generación de posición, el control del juego, la comunicación utilizada, los resultados principales, las dificultades y la conclusión más importante.

---

## 1. Introducción

### 1.1 Contexto

[Explicar en qué consiste Whack-a-Mole y el problema planteado por el instructivo.]

### 1.2 Solución desarrollada

[Resumir la arquitectura implementada y la responsabilidad de cada subsistema.]

### 1.3 Alcance y limitaciones

Indicar claramente:

- Partes implementadas completamente.
- Partes modificadas respecto al instructivo.
- Sustitución de UART por el bus paralelo `Q[2:0]`.
- Limitaciones y bloqueos observados en el LFSR.

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

| Requisito | Valor especificado | Implementación final |
|---|---:|---|
| Posiciones | 8 | [COMPLETAR] |
| Botones externos | 8 | [COMPLETAR] |
| Tiempo inicial | 1500 ms | [COMPLETAR] |
| Reducción por acierto | 100 ms | [COMPLETAR] |
| Tiempo mínimo | 500 ms | [COMPLETAR] |
| Fallos consecutivos | 3 | [COMPLETAR] |
| Game over | 2000 ms | [COMPLETAR] |
| Aciertos | 00-99 | [COMPLETAR] |
| Fallos acumulados | 00-99 | [COMPLETAR] |
| Reloj FPGA | 100 MHz | [COMPLETAR] |
| Comunicación requerida | UART 8N1 | Paralelo `Q[2:0]`; justificar |

### 3.2 Requisitos eléctricos

- Lógica discreta alimentada con 5 V.
- Entradas Pmod limitadas a 3.3 V.
- Tierra común entre FPGA y protoboard.
- Divisores o adaptación de nivel para `Q0`, `Q1` y `Q2`.
- Transistor 2N2222 para aislar e invertir `SOLICITUD_TOPO`.

---

## 4. Fundamentación teórica

### 4.1 Lógica combinacional y secuencial

[Explicar compuertas, flip-flops, registros, reloj, reset, clock enable y asignaciones no bloqueantes.]

### 4.2 Linear Feedback Shift Register (LFSR)

[Explicar registros de desplazamiento, XOR, taps, polinomio característico, semilla, periodo máximo y estado prohibido.]

#### Polinomio utilizado

```text
[COMPLETAR]
```

#### Tabla de estados

| Pulso | Estado actual | Realimentación | Estado siguiente | LED |
|---:|:---:|:---:|:---:|:---:|
| 0 | [ ] | [ ] | [ ] | [ ] |
| 1 | [ ] | [ ] | [ ] | [ ] |
| 2 | [ ] | [ ] | [ ] | [ ] |

Analizar por qué `000` puede ser un estado absorbente y por qué un LFSR máximo de tres bits tiene un periodo máximo de siete estados.

### 4.3 Decodificador 74LS138

[Explicar entradas, habilitaciones y salidas activas en bajo.]

| Q2 | Q1 | Q0 | Salida | Posición |
|:---:|:---:|:---:|---|---|
| 0 | 0 | 0 | Y0 | LED0 |
| 0 | 0 | 1 | Y1 | LED1 |
| 0 | 1 | 0 | Y2 | LED2 |
| 0 | 1 | 1 | Y3 | LED3 |
| 1 | 0 | 0 | Y4 | LED4 |
| 1 | 0 | 1 | Y5 | LED5 |
| 1 | 1 | 0 | Y6 | LED6 |
| 1 | 1 | 1 | Y7 | LED7 |

### 4.4 UART asíncrono

[Explicar trama 8N1, start, ocho bits LSB-first, stop, baud rate, muestreo central, error entre relojes y sincronizador de dos etapas.]

### 4.5 Comunicación paralela implementada

[Explicar `Q0`, `Q1`, `Q2`, sincronización, estabilidad, ventajas, desventajas y desviación del requisito UART.]

### 4.6 Metastabilidad

[Explicar su origen y el sincronizador de dos etapas.]

### 4.7 Rebote de botones

[Explicar el rebote, muestreo cada 1 ms, validación de 10 ms y generación de pulsos.]

### 4.8 Máquinas de estados

[Explicar estado actual, estado siguiente, FSM Moore, lógica de transición, salidas y prevención de latches.]

### 4.9 Displays de siete segmentos

[Explicar multiplexación, ánodos y segmentos activos en bajo, frecuencia de refresco y conversión decimal.]

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

[Conversión one-hot y criterios de acierto/fallo.]

### 8.8 `turn_window_timer`

[Inicio, cancelación, conteo y timeout.]

### 8.9 `difficulty_controller`

| Aciertos que reducen | Duración |
|---:|---:|
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

### 8.10 `score_counters`

[Aciertos, fallos acumulados y saturación en 99.]

### 8.11 `consecutive_misses`

[Tres fallos consecutivos y reinicio mediante acierto.]

### 8.12 `game_over_timer`

[Duración de 2000 ms y pulso de finalización.]

### 8.13 `game_controller_fsm`

![FSM principal](figuras/fsm_principal.png)

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

### 8.14 `seven_segment_controller`

[Barrido, selección de dígitos y patrones de segmentos.]

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
