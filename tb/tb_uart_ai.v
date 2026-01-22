`timescale 1ns/1ps

module tb_uart_ai;

    reg clk = 0;
    reg rst = 1;
    reg rx_in_sim = 1; // PC'den FPGA'ye giden hat (Normalde 1)
    wire tx_out_sim;   // FPGA'den PC'ye gelen hat

    // Veri göndermek için yardımcı task 
    // Bu task, bir byte veriyi UART formatında (Start+8bit+Stop) rx_in_sim hattına basar.
    task send_byte_to_fpga;
        input [7:0] data;
        integer i;
        begin
            // Start Bit
            rx_in_sim = 0;
            #(104166); // 9600 baud için 1 bit süresi (10^9 / 9600 ≈ 104166 ns)
            
            // Data Bits
            for (i=0; i<8; i=i+1) begin
                rx_in_sim = data[i];
                #(104166);
            end
            
            // Stop Bit
            rx_in_sim = 1;
            #(104166);
        end
    endtask

    // 100 MHz Clock
    always #5 clk = ~clk;

    // DUT (Device Under Test)
    uart_ai_system u_dut (
        .clk(clk),
        .rst(rst),
        .rx_in(rx_in_sim),
        .tx_out(tx_out_sim)
    );

    // RX Tarafını Dinlemek İçin Yardımcı (Basitçe TX modülünü kullanıyoruz)
    // FPGA'in gönderdiği cevabı (tx_out_sim) okuyup ekrana basacağız.
    wire [7:0] captured_response;
    wire response_valid;
    wire tick_1x, tick_16x;
    
    // Testbench'in kendi baud generator'ı 
    baud_gen u_tb_baud (.clk(clk), .rst(rst), .tick_1x(tick_1x), .tick_16x(tick_16x));
    
    // Testbench'in alıcısı (FPGA'in cevabını dinler)
    uart_rx u_tb_monitor (
        .clk(clk), .rst(rst), .rx(tx_out_sim), .s_tick(tick_16x),
        .data_out(captured_response), .rx_done_tick(response_valid)
    );

    initial begin
        $dumpfile("uart_ai.vcd");
        $dumpvars(0, tb_uart_ai);

        rst = 1;
        #200;
        rst = 0;
        #200;

        // --- SENARYO 1: NORMAL VERİ (50) ---
        $display("--- TEST 1: 50 Gonderiliyor (Normal Bekleniyor) ---");
        send_byte_to_fpga(8'd50);

        // Cevap gelene kadar bekle 
        @(posedge response_valid); 
        
        if (captured_response == 8'h01)
            $display("BASARILI: FPGA 'Normal' (0x01) dedi.");
        else
            $display("HATA: FPGA 0x%h dedi (Beklenen 0x01).", captured_response);

        #1000000; // Biraz boşluk bırak

        // --- SENARYO 2: ANOMALİ VERİ (150) ---
        $display("--- TEST 2: 150 Gonderiliyor (Anomali Bekleniyor) ---");
        send_byte_to_fpga(8'd150);

        @(posedge response_valid);

        if (captured_response == 8'hFF)
            $display("BASARILI: FPGA 'Anomali' (0xFF) dedi.");
        else
            $display("HATA: FPGA 0x%h dedi (Beklenen 0xFF).", captured_response);

        #1000000;
        $finish;
    end

endmodule