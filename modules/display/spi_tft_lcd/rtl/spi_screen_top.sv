`timescale 1ns / 1ps

// 修正版：解决了 16-bit 像素拆分时的坐标错位与黄线问题
module spi_screen_top(
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,

    // 用户接口
    output                              flush_data_update_o        , // 更新当前坐标点显示数据使能
    input              [  15: 0]        flush_data_i               , // 当前坐标点显示的数据输入
    output             [  15: 0]        flush_addr_width_o         , // 当前刷新的x坐标
    output             [  15: 0]        flush_addr_height_o        , // 当前刷新的y坐标
    output                              spi_screen_flush_fsync_o   , // 屏幕帧同步

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
    wire               [   7: 0]        spi_screen_flush_data      ; 
    wire                                spi_screen_flush_updte     ; 
    wire                                spi_screen_flush_fsync     ; 

    reg                [  15: 0]        width_cnt                  ;
    reg                [  15: 0]        height_cnt                 ;
    reg                                 data_update_cnt            ;
    reg                [  15: 0]        flush_data_reg             ;

    // 🌟 核心逻辑：定义像素起始脉冲
    // 当底层请求数据且 data_update_cnt 为 0 时，意味着正要发送 16bit 像素的第一个字节
    wire pixel_start_pulse;
    assign pixel_start_pulse = (spi_screen_flush_updte == 1'b1 && data_update_cnt == 1'b0);

    // 输出赋值
    assign spi_screen_flush_data    = flush_data_reg[15:8]; 
    assign flush_data_update_o      = pixel_start_pulse; 
    assign flush_addr_width_o       = width_cnt;
    assign flush_addr_height_o      = height_cnt;
    assign spi_screen_flush_fsync_o = spi_screen_flush_fsync;

    // 1. 数据更新计数器：控制 16bit 拆分为两个 8bit 发送
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || spi_screen_flush_fsync == 1'b1)
            data_update_cnt <= 1'b0;
        else if (spi_screen_flush_updte == 1'b1)
            data_update_cnt <= data_update_cnt + 1'b1;
    end

    // 2. 宽度计数器：使用像素起始脉冲驱动，确保与数据锁存严格对齐
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || spi_screen_flush_fsync == 1'b1)
            width_cnt <= 16'd0;
        else if (pixel_start_pulse) begin
            if (width_cnt == (SCREEN_WIDTH - 1))
                width_cnt <= 16'd0;
            else
                width_cnt <= width_cnt + 1'b1;
        end
    end

    // 3. 高度计数器
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0 || spi_screen_flush_fsync == 1'b1)
            height_cnt <= 16'd0;
        else if (pixel_start_pulse && (width_cnt == SCREEN_WIDTH - 1)) begin
            if (height_cnt == (SCREEN_HEIGHT - 1))
                height_cnt <= 16'd0;
            else
                height_cnt <= height_cnt + 1'b1;
        end
    end

    // 4. 数据寄存器：在像素开始时刻精准锁存输入颜色，避免跨像素混色
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (sys_rst_n == 1'b0)
            flush_data_reg <= 16'd0;
        else if (spi_screen_flush_updte == 1'b1) begin
            if (data_update_cnt == 1'b0)
                flush_data_reg <= flush_data_i; // 锁存新像素
            else
                flush_data_reg <= {flush_data_reg[7:0], 8'h00}; // 移位发送低8位
        end
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