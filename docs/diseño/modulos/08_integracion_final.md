# Integracion final

## Modulo superior

`whack_a_mole_top` conecta todos los bloques ya verificados. Sus parametros por
defecto corresponden al reloj de 100 MHz de la Nexys 4 y a los tiempos reales
del proyecto. El banco de pruebas reemplaza esos parametros por tiempos cortos,
sin modificar la logica funcional.

## Flujo de una jugada

1. La FSM activa `solicitud_topo` durante 1 ms.
2. El receptor paralelo sincroniza y valida `Q2:Q0`.
3. Se enciende el LED correspondiente y comienza la ventana del turno.
4. Un boton correcto genera un acierto; cualquier otro boton genera un fallo.
5. Si no se pulsa un boton dentro de la ventana, el timeout cuenta como fallo.
6. Tres fallos consecutivos producen fin de partida durante 2 s.
7. El auto reset limpia puntajes, vidas y dificultad, e inicia otra partida.

## Indicadores

- `mole_leds[7:0]`: topo activo.
- `status_led`: fijo durante la partida y parpadeando durante game over.
- `AN3..AN0`: dos digitos de fallos y dos de aciertos.

## Conexion electrica

Las entradas de la FPGA son LVCMOS de 3.3 V. Las salidas de 5 V del circuito
discreto deben entrar mediante divisores o adaptacion de nivel, y ambas partes
deben compartir tierra. No se debe aplicar 5 V directamente a un Pmod.
