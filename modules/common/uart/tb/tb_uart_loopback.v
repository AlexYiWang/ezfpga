`timescale 1ns/1ns   // 时间单位 1ns，时间精度 1ns

module tb_uart_loopback();

// 时钟周期参数：20ns = 50MHz
parameter CLK_PERIOD = 20;

// 输入信号定义
reg            sys_clk  ;  // 系统时钟
reg            sys_rst_n;  // 复位信号，低有效
reg            uart_rxd ;  // UART 接收引脚（测试激励）

// 输出信号定义
wire           uart_txd ;  // UART 发送引脚（测试观测）

//*****************************************************
//**                    main code
//*****************************************************

// 发送测试数据 0x55（0101_0101），按照 UART 8N1 格式
// 波特率 115200，每位时间 = 1/115200 ≈ 8.68us = 8680ns
initial begin
    sys_clk <= 1'b0;
    sys_rst_n <= 1'b0;
    uart_rxd <= 1'b1;   // 空闲电平为高
    #200
    sys_rst_n <= 1'b1;  // 释放复位
    #1000
    uart_rxd <= 1'b0;   // 起始位（低电平）
    #8680
    uart_rxd <= 1'b1;   // D0 = 1
    #8680
    uart_rxd <= 1'b0;   // D1 = 0
    #8680
    uart_rxd <= 1'b1;   // D2 = 1
    #8680
    uart_rxd <= 1'b0;   // D3 = 0
    #8680
    uart_rxd <= 1'b1;   // D4 = 1
    #8680
    uart_rxd <= 1'b0;   // D5 = 0
    #8680
    uart_rxd <= 1'b1;   // D6 = 1
    #8680
    uart_rxd <= 1'b0;   // D7 = 0
    #8680
    uart_rxd <= 1'b1;   // 停止位（高电平）
    #8680
    uart_rxd <= 1'b1;   // 回到空闲状态
end

// 50MHz 时钟：周期 20ns，每 10ns 翻转一次
always #(CLK_PERIOD/2) sys_clk = ~sys_clk;

// 实例化被测模块
uart_loopback u_uart_loopback(
    .sys_clk      (sys_clk  ),
    .sys_rst_n    (sys_rst_n),
    .uart_rxd     (uart_rxd ),
    .uart_txd     (uart_txd )
);

endmodule
