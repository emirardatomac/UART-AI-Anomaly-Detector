module uart_rx(
    input wire clk,
    input wire rst,
    input wire rx,          
    input wire s_tick,      
    output wire [7:0] data_out, 
    output reg rx_done_tick
);

    localparam [1:0] 
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11;

    reg [1:0] state, state_next;
    reg [3:0] s_cnt, s_cnt_next;
    reg [2:0] n_cnt, n_cnt_next;
    reg [7:0] b_reg, b_reg_next;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            s_cnt <= 0;
            n_cnt <= 0;
            b_reg <= 0;
            
        end else begin
            state <= state_next;
            s_cnt <= s_cnt_next;
            n_cnt <= n_cnt_next;
            b_reg <= b_reg_next;
        end
    end

    always @* begin
        state_next = state;
        rx_done_tick = 1'b0;
        s_cnt_next = s_cnt;
        n_cnt_next = n_cnt;
        b_reg_next = b_reg;

        case (state)
            IDLE: begin
                if (~rx) begin
                    state_next = START;
                    s_cnt_next = 0;
                end
            end

            START: begin
                if (s_tick) begin
                    if (s_cnt == 7) begin
                        state_next = DATA;
                        s_cnt_next = 0;
                        n_cnt_next = 0;
                    end else begin
                        s_cnt_next = s_cnt + 1;
                    end
                end
            end

            DATA: begin
                if (s_tick) begin
                    if (s_cnt == 15) begin
                        s_cnt_next = 0;
                        b_reg_next = {rx, b_reg[7:1]};
                        if (n_cnt == 7)
                            state_next = STOP;
                        else
                            n_cnt_next = n_cnt + 1;
                    end else begin
                        s_cnt_next = s_cnt + 1;
                    end
                end
            end

            STOP: begin
                if (s_tick) begin
                    if (s_cnt == 15) begin 
                        state_next = IDLE;
                        rx_done_tick = 1'b1; // İşlem tamam
                    end else begin
                        s_cnt_next = s_cnt + 1;
                    end
                end
            end
        endcase
    end
    
    
    assign data_out = b_reg;

endmodule