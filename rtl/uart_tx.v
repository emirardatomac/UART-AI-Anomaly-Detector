module uart_tx(
    input  wire clk,
    input  wire rst,
    input  wire baud_tick, // baud_gen'den gelen 'tick_1x' buraya girer
    input  wire send,
    input  wire [7:0] data_in,
    output reg  tx,
    output reg  busy
);
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_idx;
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1; // Hat boşta iken High (1) olmalı
            busy      <= 0;
            bit_idx   <= 0;
            shift_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx   <= 1;
                    busy <= 0;
                    if (send) begin
                        busy      <= 1;
                        shift_reg <= data_in;
                        bit_idx   <= 0;
                        state     <= START;
                    end
                end

                START: begin
                    tx <= 0; // Start biti (Low)
                    if (baud_tick) begin
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx <= shift_reg[bit_idx]; // Sıradaki biti gönder
                    if (baud_tick) begin
                        if (bit_idx == 3'd7) begin
                            state <= STOP;
                        end else begin
                            bit_idx <= bit_idx + 1;
                        end
                    end
                end

                STOP: begin
                    tx <= 1; // Stop biti (High)
                    if (baud_tick) begin
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule