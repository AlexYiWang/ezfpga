// UART 回环测试模块
// 功能：将从 uart_rxd 接收到的数据通过 uart_txd 原样发送出去
// 常用于验证 UART 硬件连接是否正确

module uart_loopback (
    input  sys_clk  ,   // 系统时钟，50MHz
    input  sys_rst_n,   // 复位信号，低有效

    input  uart_rxd ,   // UART 接收引脚
    output uart_txd     // UART 发送引脚
);

    // 系统参数
    parameter CLK_FREQ = 50_000_000;    // 50MHz 系统时钟
    parameter UART_BPS = 115200  ;      // 115200 波特率

    // 内部信号
    wire        uart_rx_done;    // 接收完成脉冲
    wire [7:0]  uart_rx_data;    // 接收到的数据
    /* verilator lint_off UNUSEDSIGNAL */
    wire        uart_tx_busy;    // 发送忙标志（未使用，保留接口）
    /* verilator lint_on UNUSEDSIGNAL */

    // UART 接收模块：接收串行数据
    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .UART_BPS  (UART_BPS)
    )
    u_uart_rx (
        .clk           (sys_clk     ),
        .rst_n         (sys_rst_n   ),
        .uart_rxd      (uart_rxd    ),
        .uart_rx_done  (uart_rx_done),
        .uart_rx_data  (uart_rx_data)
    );

    // UART 发送模块：发送接收到的数据
    // 发送使能直接使用接收完成信号，实现收到即发送
    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .UART_BPS  (UART_BPS)
    )
    u_uart_tx (
        .clk           (sys_clk     ),
        .rst_n         (sys_rst_n   ),
        .uart_tx_en    (uart_rx_done),  // 接收完成触发发送
        .uart_tx_data  (uart_rx_data),
        .uart_txd      (uart_txd    ),
        .uart_tx_busy  (uart_tx_busy  )
    );

endmodule
