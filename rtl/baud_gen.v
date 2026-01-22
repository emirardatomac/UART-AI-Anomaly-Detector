module baud_gen #(
    parameter integer CLK_FREQ_HZ = 100_000_000, 
    parameter integer BAUD_RATE   = 9600
)(
    input  wire clk,
    input  wire rst,
    output reg  tick_1x,  // TX kullanacak (9600 Hz)
    output reg  tick_16x  // RX kullanacak (9600 * 16 Hz)
);
    // 16 kat hızlı örnekleme için sayaç limiti
    localparam integer TICKS_PER_SAMPLE = CLK_FREQ_HZ / (BAUD_RATE * 16);
    
    reg [31:0] cnt;
    reg [3:0]  sample_cnt; // 0'dan 15'e sayıp 1x tick üretecek

    always @(posedge clk) begin
        if (rst) begin
            cnt        <= 0;
            sample_cnt <= 0;
            tick_16x   <= 0;
            tick_1x    <= 0;
        end else begin
            // Pulse (tık) sinyalleri varsayılan olarak 0'dır
            tick_16x <= 0;
            tick_1x  <= 0;

            if (cnt == TICKS_PER_SAMPLE - 1) begin
                cnt      <= 0;
                tick_16x <= 1; // RX için hızlı tick üretildi
                
                // Hızlı tick üretildiğinde 1x sayacını kontrol et
                if (sample_cnt == 15) begin
                    sample_cnt <= 0;
                    tick_1x    <= 1; // TX için yavaş tick üretildi
                end else begin
                    sample_cnt <= sample_cnt + 1;
                end
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
endmodule