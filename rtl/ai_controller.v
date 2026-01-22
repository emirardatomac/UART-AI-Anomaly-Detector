module ai_controller(
    input  wire clk,
    input  wire rst,
    
    // FIFO Arayüzü
    input  wire [7:0] fifo_data,
    input  wire fifo_empty,
    output reg  fifo_rd_en,

    // UART TX Arayüzü
    input  wire tx_busy,
    output reg  [7:0] tx_data,
    output reg  tx_send
);

    localparam [1:0]
        IDLE      = 2'b00,
        READ_FIFO = 2'b01,
        PROCESS   = 2'b10,
        SEND_TX   = 2'b11;

    reg [1:0] state;
    reg [7:0] data_latch; 

    always @(posedge clk) begin
        if (rst) begin
            state      <= IDLE;
            fifo_rd_en <= 0;
            tx_send    <= 0;
            tx_data    <= 0;
            data_latch <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_send <= 0;
                    if (!fifo_empty && !tx_busy) begin
                        // Veriyi burada yakalıyoruz
                        data_latch <= fifo_data;
                        fifo_rd_en <= 1; 
                        state      <= READ_FIFO;
                        // DEBUG MESAJI
                        $display("[AI DEBUG] IDLE: FIFO dolu, veri okumaya basliyorum. FIFO cikisi: %d", fifo_data);
                    end
                end

                READ_FIFO: begin
                    fifo_rd_en <= 0;
                    state      <= PROCESS;
                end

                PROCESS: begin
                    // DEBUG MESAJI
                    $display("[AI DEBUG] PROCESS: Yakalanan Veri = %d", data_latch);
                    
                    if (data_latch > 8'd100) begin
                        tx_data <= 8'hFF; 
                        $display("[AI DEBUG] KARAR: ANOMALI (0xFF) olarak ayarlandi.");
                    end else begin
                        tx_data <= 8'h01; 
                        $display("[AI DEBUG] KARAR: NORMAL (0x01) olarak ayarlandi.");
                    end
                    state <= SEND_TX;
                end

                SEND_TX: begin
                    // DEBUG MESAJI
                    $display("[AI DEBUG] SEND_TX: Gonder emri veriliyor. Gidecek Veri: 0x%h", tx_data);
                    tx_send <= 1;
                    state   <= IDLE;
                end
            endcase
        end
    end
endmodule