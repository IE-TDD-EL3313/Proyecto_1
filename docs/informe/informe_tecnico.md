
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

[Sincronización, filtros y pulsos de ocho botones.]

### 8.5 `parallel_position_receiver`

[Sincronización del bus, estabilidad y `position_valid`.]

### 8.6 `mole_request_generator`

[Pulso, `busy`, solicitud pendiente y separación entre pulsos.]

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

[Explicar la conexión de todos los módulos y las señales `data_reset` y `effective_miss_pulse`.]

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
