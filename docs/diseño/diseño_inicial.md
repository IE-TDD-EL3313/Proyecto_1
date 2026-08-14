# Diseño inicial — Proyecto 1

## 1. Introducción

Este documento presenta el diseño inicial del sistema desarrollado para el Proyecto 1 del curso EL3313.

El diseño se realiza siguiendo una metodología de diseño modular y jerárquico, en la cual el sistema se descompone progresivamente en subsistemas y bloques de menor nivel.

Se presentan los diagramas correspondientes a los diferentes niveles de diseño, desde la representación general del sistema hasta la descripción detallada de los módulos internos que posteriormente serán implementados.

---

# 2. Diagrama de primer nivel

## 2.1 Descripción general

El diagrama de primer nivel representa el sistema de Whack-a-Mole completo como un único bloque. Su propósito es identificar las entradas y salidas externas necesarias para el funcionamiento del juego, sin mostrar todavía la estructura interna ni los módulos utilizados para cada función. 

El sistema recibe como entradas los ocho pulsadores externos utilizados por el jugador, la señal de reinicio manual y el reloj de 100 MHz. A partir de estas entradas, el sistema controla el desarrollo de la partida y genera las señales necesarias para indicar la posición activa del topo y mostrar los resultados obtenidos por el jugador.

Durante cada turno se selecciona una de ocho posiciones posibles, la cual se indica mediante uno de los ocho LEDs disponibles. El jugador debe presionar el pulsador correspondiente a la posición activa dentro del tiempo permitido. El sistema determina si la acción corresponde a un acierto o un fallo y actualiza los resultados de la partida.

Los aciertos y los fallos acumulados se muestran mediante cuatro displays de 7 segmentos.
## 2.2 Entradas

| Señal | Descripción |
|---|---|
| `Reloj de 100 MHz` | `Señal de reloj principal utilizada por el subsistema implementado en la FPGA` |
| `Ocho pulsadores` | `Permiten al jugador seleccionar una de las ocho posiciones del topo` |
| `Señal de reinicio` | `Permite reiniciar manualmente el juego y restablecer las condiciones iniciales` |

## 2.3 Salidas

| Señal | Descripción |
|---|---|
| `Ocho LEDs de posición` | `Indican visualmente cuál de las ocho posiciones corresponde al topo activo` |
| `Cuatro displays de 7 segmentos` | `Muestran la cantidad acumulada de aciertos y fallos` |


## 2.4 Diagrama

![Diagrama de primer nivel](ruta_imagen)

## 2.5 Descripción del funcionamiento

El sistema inicia la partida bajo las condiciones iniciales establecidas y selecciona una posición del topo. Mientras dicha posición permanece activa, el jugador puede responder mediante uno de los ocho pulsadores externos. El sistema evalúa la respuesta, actualiza los contadores y continua con un nuevo turno mientras no se alcance la condición de finalización del juego.

El reloj de 100 MHz proporciona la referencia temporal principal para las funciones implementadas en la FPGA.

---

# 3. Diagrama de segundo nivel

## 3.1 Descripción general

El diagrama de segundo nivel divide el sistema completo en dos subsistemas principales: el subsistema discreto y el subsistema FPGA. Ambos trabajan de forma conjunta para realizar las diferentes funciones necesarias durante el desarrollo del juego.

El subsistema discreto se encarga principalmente de generar la posición pseudoaleatoria del topo, indicar dicha posición mediante uno de los ocho LEDs y preparar la información necesaria para transmitirla hacia la FPGA mediante comunicación UART. El subsistema FPGA funciona como el controlador principal del juego, encargándose de recibir la posición generada, procesar las acciones del jugador, controlar la duración de los turnos, manejar la dificultad y actualizar los resultados mostrados en los displays.

La comunicación entre ambos subsistemas se realiza en dos direcciones. La FPGA envía una señal de solicitud de topo al subsistema discreto para indicar cuando debe generarse una nueva posición. Y el subsistema discreto transmite la posición generada hacia la FPGA mediante el enlace serial UART.

## 3.2 Subsistemas principales

### 3.2.1 Subsistema discreto

**Función:**

Generar una nueva posición pseudoaleatoria cada vez que la FPGA lo solicite, indicar visualmente la posición seleccionada mediante uno de los ocho LEDs y transmitir la información correspondiente hacia la FPGA mediante comunicación serial.

**Entradas:**

| Señal | Descripción |
|---|---|
| `Solicitud del topo` | `Señal proveniente de la FPGA que indica cuando debe generarse una nueva posición para el siguiente turno.` |

**Salidas:**

| Señal | Descripción |
|---|---|
| `UART TX` | `Señal serial que contiene la posición generada y se transmite hacia la FPGA mediante UART` |
| `LED[7:0]` | `Ocho señales utilizadas para indicar visualmente cuál de las posiciones del topo se encuentra activa` |

---

### 3.2.2 Subsistema FPGA

**Función:**

Controlar el funcionamiento general del juego, recibiendo la posición generada por el subsistema discreto, procesando las acciones realizadas por el jugador y administrando los tiempos, dificultad, aciertos, fallos y visualizació de resultados.

**Entradas:**

| Señal | Descripción |
|---|---|
| `UART RX` | `Señal serial proveniente del subsistema discreto que contiene la posición del topo` |
| `Botones[7:0]` | `Ocho pulsadores externos utilizados por el jugador para seleccionar la posición que desea golpear` |
| `CLK_100MHz` | `Reloj principal de 100 MHz utilizado por la lógica implementada en la FPGA` |
| `Reset` | `Señal utilizada para reiniciar el juego y regresar el sistema a sus condiciones iniciales` |

**Salidas:**

| Señal | Descripción |
|---|---|
| `Solicitud del topo` | `Señal enviada hacia el subsistema discreto para solicitar la generación de una nueva posición` |
| `aciertos/fallos` | `Señales utilizadas para controlar los cuatro displays de 7 segmentos y mostrar los aciertos y fallos acumulados` |

## 3.3 Diagrama

![Diagrama de segundo nivel](ruta_imagen)

## 3.4 Comunicación entre subsistemas

La comunicación entre subsistemas se realiza mediante dos señales principales. Debido a que ambos subsistemas operan con referencias temporales independientes, no se comparte ninguna señal de reloj entre ellos.

La señal solicitud del topo permite que la FPGA controle cuando debe generarse una nueva posición. Al recibir esta señal, el subsistema discreto actualiza el valor pseudoaleatorio y prepara la posición obtenida para su transmisión.

Posteriormente, la posición se envía mediante la línea UART desde la salida UART TX hacia la entrada UART RX. La transmisión utiliza una trama 8N1, donde los tres bits menos significativos del byte representan una de las ocho posibles posiciones del topo.

De esta manera, la FPGA determina cuando iniciar un nuevo turno, mientras que el subsistema discreto es el encargado de generar y devolver la nueva posición correspondiente.

---

# 4. Diagrama de tercer nivel

## 4.1 Descripción general

En el tercer nivel se realiza la descomposición interna de los subsistemas definidos en el segundo nivel.

Cada subsistema se divide en bloques funcionales responsables de realizar tareas específicas dentro del sistema.

## 4.2 Subsistema __________________

### 4.2.1 Bloque __________________

**Función:**

Describir la función realizada por el bloque.

**Entradas:**

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

**Salidas:**

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

---

### 4.2.2 Bloque __________________

**Función:**

Describir la función realizada por el bloque.

**Entradas:**

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

**Salidas:**

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

## 4.3 Diagrama

![Diagrama de tercer nivel](ruta_imagen)

## 4.4 Descripción del funcionamiento

Describir cómo interactúan los diferentes bloques internos y cómo las señales permiten realizar la función correspondiente al subsistema.

---

# 5. Diagrama de cuarto nivel

## 5.1 Descripción general

El cuarto nivel profundiza en la estructura interna de los bloques definidos en el tercer nivel.

En este nivel se muestran los elementos internos necesarios para implementar cada una de las funciones definidas anteriormente.

---

## 5.2 Bloque __________________

### Función

Describir detalladamente la función realizada por el bloque.

### Entradas

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

### Salidas

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

### Elementos internos

| Elemento | Función |
|---|---|
| `________` | ______________________________ |
| `________` | ______________________________ |
| `________` | ______________________________ |

### Diagrama

![Diagrama de cuarto nivel](ruta_imagen)

### Descripción del funcionamiento

Explicar el flujo de información dentro del bloque y la función de cada uno de sus elementos internos.

---

## 5.3 Bloque __________________

### Función

Describir detalladamente la función realizada por el bloque.

### Entradas

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

### Salidas

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

### Elementos internos

| Elemento | Función |
|---|---|
| `________` | ______________________________ |
| `________` | ______________________________ |

### Diagrama

![Diagrama de cuarto nivel](ruta_imagen)

### Descripción del funcionamiento

Describir el funcionamiento interno del bloque.

---

# 6. Diagrama de quinto nivel

## 6.1 Descripción general

El quinto nivel corresponde al mayor nivel de detalle del diseño.

En este nivel se representan los componentes elementales necesarios para implementar los bloques definidos en los niveles anteriores.

Dependiendo del bloque, pueden aparecer elementos como:

- Registros.
- Contadores.
- Comparadores.
- Multiplexores.
- Decodificadores.
- Divisores de frecuencia.
- Máquinas de estados.
- Lógica combinacional.
- Lógica secuencial.

---

## 6.2 Bloque __________________

### Función

Describir la función específica realizada por el bloque.

### Entradas

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

### Salidas

| Señal | Descripción |
|---|---|
| `________` | ______________________________ |

### Componentes internos

| Componente | Función |
|---|---|
| `________` | ______________________________ |
| `________` | ______________________________ |
| `________` | ______________________________ |

### Diagrama

![Diagrama de quinto nivel](ruta_imagen)

### Descripción del funcionamiento

Explicar detalladamente el comportamiento interno del bloque y la relación entre sus diferentes componentes.

---

# 7. Resumen de señales del sistema

En esta sección se resumen las principales señales utilizadas en los diferentes niveles del diseño.

| Señal | Origen | Destino | Tipo/Tamaño | Descripción |
|---|---|---|---|---|
| `________` | ________ | ________ | ________ | __________________ |
| `________` | ________ | ________ | ________ | __________________ |
| `________` | ________ | ________ | ________ | __________________ |
| `________` | ________ | ________ | ________ | __________________ |
| `________` | ________ | ________ | ________ | __________________ |

---

# 8. Consideraciones de diseño

Durante el desarrollo de los diagramas se consideran los siguientes aspectos:

- Diseño modular y jerárquico.
- Separación clara de responsabilidades entre bloques.
- Definición explícita de las entradas y salidas.
- Identificación de señales de datos y señales de control.
- Sincronización de señales externas cuando sea necesario.
- Tratamiento adecuado de las entradas provenientes de pulsadores.
- Uso de bloques reutilizables cuando sea posible.
- Correspondencia entre los diagramas y la futura implementación en HDL.
- Facilidad para verificar individualmente cada módulo.
- Comunicación claramente definida entre los diferentes bloques del sistema.

---

# 9. Conclusiones del diseño inicial

El diseño jerárquico permite dividir el sistema en módulos de menor complejidad, facilitando su comprensión, implementación y posterior verificación.

Cada nivel proporciona progresivamente un mayor grado de detalle, manteniendo una relación clara entre las entradas, salidas, señales internas y funciones de los diferentes bloques que conforman el proyecto.

La estructura definida en este documento servirá como base para las siguientes etapas de implementación y verificación del sistema.
