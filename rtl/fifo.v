module fifo #(
    parameter DATA_WIDTH = 8,  // 8 bitlik veri
    parameter ADDR_WIDTH = 4   // 16 adet saklama kapasitesi
)(
    input  wire clk,
    input  wire rst,
    input  wire wr_en,                  // Yaz komutu (RX'ten)
    input  wire rd_en,                  // Oku komutu (AI'dan)
    input  wire [DATA_WIDTH-1:0] din,   // Giriş verisi
    output wire [DATA_WIDTH-1:0] dout,  // Çıkış verisi
    output wire full,                   // Depo dolu mu?
    output wire empty                   // Depo boş mu?
);

    reg [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0]   count;

    // Yazma
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr] <= din;
            wr_ptr      <= wr_ptr + 1;
        end
    end

    // Okuma
    assign dout = mem[rd_ptr];

    // İbre Yönetimi
    always @(posedge clk) begin
        if (rst) begin
            rd_ptr <= 0;
            count  <= 0;
        end else begin
            if (wr_en && !full && rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;
            end else if (wr_en && !full) begin
                count <= count + 1;
            end else if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1;
                count  <= count - 1;
            end
        end
    end

    assign empty = (count == 0);
    assign full  = (count == (2**ADDR_WIDTH));

endmodule