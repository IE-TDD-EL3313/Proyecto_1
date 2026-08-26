module uart_rx #(
    parameter int CLK_FREQ  = 100_000_000,
    parameter int BAUD_RATE = 2400
)(
    input  logic       clk,
    input  logic       reset,
    input  logic       serial_sync,

    output logic [7:0] rx_data,
    output logic       data_valid
);

    // Cantidad de ciclos de reloj de la FPGA por cada bit UART.
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // Mitad del tiempo de un bit, utilizado para confirmar
    // el bit de START aproximadamente en su centro.
    localparam int HALF_BIT = CLKS_PER_BIT / 2;

    // Estados del receptor UART.
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;

    // Cuenta los ciclos del reloj de 100 MHz dentro de cada bit UART.
    logic [$clog2(CLKS_PER_BIT)-1:0] baud_counter;

    // Indica cuál de los 8 bits de datos se está recibiendo.
    logic [2:0] bit_index;


    always_ff @(posedge clk) begin

        if (reset) begin

            state        <= IDLE;
            baud_counter <= 0;
            bit_index    <= 0;
            rx_data      <= 8'b0;
            data_valid   <= 1'b0;

        end
        else begin

            // Por defecto data_valid permanece en 0.
            // Solo se activa durante un ciclo cuando
            // se recibe correctamente una trama.
            data_valid <= 1'b0;


            case (state)

                // --------------------------------------------------
                // IDLE
                // UART permanece normalmente en nivel lógico 1.
                // Un 0 indica el posible inicio de una trama.
                // --------------------------------------------------

                IDLE: begin

                    baud_counter <= 0;
                    bit_index    <= 0;

                    if (serial_sync == 1'b0) begin
                        state <= START;
                    end

                end


                // --------------------------------------------------
                // START
                // Esperamos medio periodo de bit para comprobar
                // el START aproximadamente en el centro.
                // --------------------------------------------------

                START: begin

                    if (baud_counter == HALF_BIT - 1) begin

                        baud_counter <= 0;

                        // Si la línea sigue en 0,
                        // el bit START es válido.
                        if (serial_sync == 1'b0) begin
                            state <= DATA;
                        end
                        else begin
                            // Si volvió a 1, probablemente era ruido.
                            state <= IDLE;
                        end

                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end

                end


                // --------------------------------------------------
                // DATA
                // Se reciben los 8 bits de datos.
                // UART transmite primero el bit menos significativo.
                // --------------------------------------------------

                DATA: begin

                    if (baud_counter == CLKS_PER_BIT - 1) begin

                        baud_counter <= 0;

                        // Guardar el bit recibido.
                        rx_data[bit_index] <= serial_sync;

                        // Comprobar si ya recibimos D7.
                        if (bit_index == 3'd7) begin

                            bit_index <= 0;
                            state     <= STOP;

                        end
                        else begin

                            bit_index <= bit_index + 1;

                        end

                    end
                    else begin

                        baud_counter <= baud_counter + 1;

                    end

                end


                // --------------------------------------------------
                // STOP
                // El bit de STOP debe encontrarse en nivel lógico 1.
                // --------------------------------------------------

                STOP: begin

                    if (baud_counter == CLKS_PER_BIT - 1) begin

                        baud_counter <= 0;

                        // Si el STOP es válido, indicar que
                        // el byte recibido está disponible.
                        if (serial_sync == 1'b1) begin
                            data_valid <= 1'b1;
                        end

                        // Independientemente del resultado,
                        // regresar a esperar una nueva trama.
                        state <= IDLE;

                    end
                    else begin

                        baud_counter <= baud_counter + 1;

                    end

                end


                // Estado de seguridad.
                default: begin

                    state        <= IDLE;
                    baud_counter <= 0;
                    bit_index    <= 0;

                end

            endcase

        end

    end

endmodule