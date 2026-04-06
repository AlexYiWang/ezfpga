`timescale 1ns / 1ps

// 修正版：解决了 16-bit 像素拆分时的坐标错位与黄线问题
// SPI TFT LCD显示驱动顶层模块
// 功能：协调外部像素数据输入与SPI发送时序，将16位像素数据拆分为两个8位字节发送
//       提供精确的坐标计数和数据锁存机制，确保显示无混色
module spi_screen_top(
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,

    // 用户接口
    output                              flush_data_update_o        , // 更新当前坐标点显示数据使能
                                             // 高电平有效，指示新的16位像素数据开始发送
                                             // 外部模块应在此信号为高时将新像素数据写入flush_data_i
    input              [  15: 0]        flush_data_i               , // 当前坐标点显示的数据输入
                                             // 16位RGB565格式像素数据，应在flush_data_update_o有效时稳定
    output             [  15: 0]        flush_addr_width_o         , // 当前刷新的x坐标
                                             // 范围：0 ~ SCREEN_WIDTH-1，在pixel_start_pulse时更新
    output             [  15: 0]        flush_addr_height_o        , // 当前刷新的y坐标
                                             // 范围：0 ~ SCREEN_HEIGHT-1，在每行结束时更新
    output                              spi_screen_flush_fsync_o   , // 屏幕帧同步
                                             // 高电平表示一帧数据发送完成，开始新的一帧

    // 屏幕物理接口
    output                              lcd_spi_sclk               ,
    output                              lcd_spi_mosi               ,
    output                              lcd_spi_cs                 ,
    output                              lcd_dc                     ,
    output                              lcd_reset                  ,
    output                              lcd_blk                     
);

    parameter                           SCREEN_WIDTH              = 32'd240;
    parameter                           SCREEN_HEIGHT             = 32'd240;

    // 内部信号
    wire               [   7: 0]        spi_screen_flush_data      ; // 发送到SPI的8位数据（16位像素的高8位或低8位）
    wire                                spi_screen_flush_updte     ; // SPI数据更新请求，来自底层驱动模块
    wire                                spi_screen_flush_fsync     ; // SPI帧同步信号，来自底层驱动模块

    reg                [  15: 0]        width_cnt                  ; // X坐标计数器，跟踪当前像素的列位置
    reg                [  15: 0]        height_cnt                 ; // Y坐标计数器，跟踪当前像素的行位置
    reg                                 data_update_cnt            ; // 数据更新计数器：0=发送高8位，1=发送低8位
    reg                [  15: 0]        flush_data_reg             ; // 像素数据寄存器，锁存外部输入的16位像素

    // 🌟 核心逻辑：定义像素起始脉冲
    // 当底层请求数据且 data_update_cnt 为 0 时，意味着正要发送 16bit 像素的第一个字节
    // 此脉冲信号用于：
    // 1. 触发外部像素数据更新（flush_data_update_o）
    // 2. 驱动坐标计数器递增
    // 3. 锁存新的16位像素数据到内部寄存器
    wire pixel_start_pulse;
    assign pixel_start_pulse = (spi_screen_flush_updte == 1'b1 && data_update_cnt == 1'b0);

    // 输出赋值
    assign spi_screen_flush_data    = flush_data_reg[15:8]; // 始终发送高8位，低8位通过移位处理
    assign flush_data_update_o      = pixel_start_pulse;    // 像素起始脉冲作为外部更新使能
    assign flush_addr_width_o       = width_cnt;            // 输出当前X坐标
    assign flush_addr_height_o      = height_cnt;           // 输出当前Y坐标
    assign spi_screen_flush_fsync_o = spi_screen_flush_fsync; // 透传帧同步信号

    // 1. 数据更新计数器：控制 16bit 拆分为两个 8bit 发送
    // data_update_cnt = 0：正在发送当前像素的高8位（RGB565的R[4:0]G[5:3]）
    // data_update_cnt = 1：正在发送当前像素的低8位（RGB565的G[2:0]B[4:0]）
    // 每完成一个字节发送，计数器翻转，实现16位到8位的拆分
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || spi_screen_flush_fsync == 1'b1)
            data_update_cnt <= 1'b0;           // 复位或帧同步时清零，开始新像素
        else if (spi_screen_flush_updte == 1'b1)
            data_update_cnt <= data_update_cnt + 1'b1; // SPI请求发送时翻转
    end

    // 2. 宽度计数器：使用像素起始脉冲驱动，确保与数据锁存严格对齐
    // 每个新像素开始时递增，达到行尾时清零
    // 与pixel_start_pulse严格同步，避免坐标与数据不匹配
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || spi_screen_flush_fsync == 1'b1)
            width_cnt <= 16'd0;                     // 复位或帧同步时清零
        else if (pixel_start_pulse) begin           // 只在像素开始时更新
            if (width_cnt == (SCREEN_WIDTH[15:0] - 1))
                width_cnt <= 16'd0;                 // 行尾，清零准备下一行
            else
                width_cnt <= width_cnt + 1'b1;      // 行内，递增X坐标
        end
    end

    // 3. 高度计数器：跟踪当前行号
    // 在每行的最后一个像素（width_cnt == SCREEN_WIDTH-1）开始时递增
    // 达到屏幕底部时清零，实现垂直回扫
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || spi_screen_flush_fsync == 1'b1)
            height_cnt <= 16'd0;                               // 复位或帧同步时清零
        else if (pixel_start_pulse && (width_cnt == SCREEN_WIDTH[15:0] - 1)) begin // 行尾像素
            if (height_cnt == (SCREEN_HEIGHT[15:0] - 1))
                height_cnt <= 16'd0;                           // 帧尾，清零准备下一帧
            else
                height_cnt <= height_cnt + 1'b1;               // 帧内，递增Y坐标
        end
    end

    // 4. 数据寄存器：在像素开始时刻精准锁存输入颜色，避免跨像素混色
    // 防混色机制：只在16位像素的第一个字节发送时刻锁存新数据
    // 确保整个16位像素传输期间使用同一数据，防止相邻像素数据交叉
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            flush_data_reg <= 16'd0;                                 // 复位清零
        else if (spi_screen_flush_updte == 1'b1) begin               // SPI请求发送数据
            if (data_update_cnt == 1'b0)
                flush_data_reg <= flush_data_i;                      // 新像素开始：锁存完整16位数据
            else
                flush_data_reg <= {flush_data_reg[7:0], 8'h00};      // 发送低8位：将原低8位移到高8位
        end                                                          // 低8位补0，因为spi_screen_flush_data始终取高8位
    end

    // 5. 实例化驱动总管 (请确保该模块名与你的工程一致)
    spi_tft_screen_driver spi_tft_screen_driver_inst(
        .sys_clk                  (sys_clk),
        .sys_rst_n                (sys_rst_n),
        .spi_screen_flush_data_i  (spi_screen_flush_data),
        .spi_screen_flush_updte_o (spi_screen_flush_updte),
        .spi_screen_flush_fsync_o (spi_screen_flush_fsync),
        .lcd_spi_sclk             (lcd_spi_sclk),
        .lcd_spi_mosi             (lcd_spi_mosi),
        .lcd_spi_cs               (lcd_spi_cs),
        .lcd_dc                   (lcd_dc),
        .lcd_reset                (lcd_reset),
        .lcd_blk                  (lcd_blk)
    );

endmodule
