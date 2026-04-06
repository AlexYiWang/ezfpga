`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/05 21:24:49
// Design Name: 
// Module Name: tb_spi_tft
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_spi_tft();

    // 1. 信号定义 [cite: 265, 266]
    reg        sys_clk;
    reg        sys_rst_n;

    wire       lcd_spi_sclk;
    wire       lcd_spi_mosi;
    wire       lcd_spi_cs;
    wire       lcd_dc;
    wire       lcd_reset;
    wire       lcd_blk;

    // 2. 实例化你的顶层测试模块 [cite: 277, 281]
    test u_test (
        .sys_clk      (sys_clk),
        .sys_rst_n    (sys_rst_n),
        .lcd_spi_sclk (lcd_spi_sclk),
        .lcd_spi_mosi (lcd_spi_mosi),
        .lcd_spi_cs   (lcd_spi_cs),
        .lcd_dc       (lcd_dc),
        .lcd_reset    (lcd_reset),
        .lcd_blk      (lcd_blk)
    );

    // 3. 时钟产生：50MHz (20ns 周期) [cite: 191]
    initial begin
        sys_clk = 0;
        forever #10 sys_clk = ~sys_clk;
    end

    // 4. 仿真流程控制
    initial begin
        // 初始化复位 [cite: 272]
        sys_rst_n = 0;
        #100;
        sys_rst_n = 1;

        // 监视关键点：当初始化完成，开始进入刷新（Flush）阶段时 [cite: 86, 97, 106]
        #50000; // 等待50us确保LCD初始化完成
        $display("Time: %t | Info: LCD Initialization Done (fixed delay), Start Flushing...", $time);

        // 监视 0x2C 写显存命令的时刻 [cite: 181]
        wait(lcd_dc == 0 && lcd_spi_mosi == 0); // 粗略捕获命令起始
        #500; 
        
        // 运行足够长的时间以观察前几行像素
        #200000; 
        
        $display("Simulation Finished. Please check the waveform.");
        $finish;
    end

    // 5. 自动波形跟踪（针对 Vivado 仿真）
    initial begin
        $dumpfile("spi_debug.vcd");
        $dumpvars(0, tb_spi_tft);
    end

endmodule
