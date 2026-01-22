module uart_ai_system(
    input  wire clk,
    input  wire rst,
    input  wire rx_in,  // PC'den gelen
    output wire tx_out  // PC'ye giden
);

    wire tick_1x, tick_16x;
    wire [7:0] rx_data_out;
    wire rx_done_tick;
    wire [7:0] fifo_dout;
    wire fifo_full, fifo_empty, ai_read_en;
    wire [7:0] ai_result_data;
    wire ai_send_cmd, tx_is_busy;

    // 1. Baud Gen
    baud_gen u_baud_gen (
        .clk(clk), .rst(rst),
        .tick_1x(tick_1x), .tick_16x(tick_16x)
    );

    // 2. RX
    uart_rx u_rx (
        .clk(clk), .rst(rst),
        .rx(rx_in), .s_tick(tick_16x),
        .data_out(rx_data_out), .rx_done_tick(rx_done_tick)
    );

    // 3. FIFO
    fifo u_fifo (
        .clk(clk), .rst(rst),
        .wr_en(rx_done_tick), .din(rx_data_out),
        .rd_en(ai_read_en), .dout(fifo_dout),
        .full(fifo_full), .empty(fifo_empty)
    );

    // 4. AI Controller
    ai_controller u_ai (
        .clk(clk), .rst(rst),
        .fifo_data(fifo_dout), .fifo_empty(fifo_empty),
        .fifo_rd_en(ai_read_en),
        .tx_busy(tx_is_busy), .tx_data(ai_result_data), .tx_send(ai_send_cmd)
    );

    // 5. TX
    uart_tx u_tx (
        .clk(clk), .rst(rst),
        .baud_tick(tick_1x), .send(ai_send_cmd),
        .data_in(ai_result_data), .tx(tx_out), .busy(tx_is_busy)
    );

endmodule