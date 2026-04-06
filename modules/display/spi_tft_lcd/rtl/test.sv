`timescale 1ns / 1ps
module test(
    input                               sys_clk                    ,// 系统时钟
    input                               sys_rst_n                  ,// 复位

    //spi tft screen   屏幕接口
    output                              lcd_spi_sclk               ,// 屏幕spi时钟接口
    output                              lcd_spi_mosi               ,// 屏幕spi数据接口
    output                              lcd_spi_cs                 ,// 屏幕spi使能接口
    output                              lcd_dc                     ,// 屏幕 数据/命令 接口
    output                              lcd_reset                  ,// 屏幕复位接口
    output                              lcd_blk                   , // 屏幕背光接口
    output                              lcd_init_done               // LCD初始化完成标志
);

    wire                                flush_data_update          ;//更新当前坐标点显示数据使能
    reg                [  15: 0]        flush_data                 ;//当前坐标点显示的数据
    wire               [  15: 0]        flush_addr_width           ;//当前刷新的x坐标
    wire               [  15: 0]        flush_addr_height          ;//当前刷新的y坐标


always @(posedge sys_clk or negedge sys_rst_n) begin                // 显示九宫格测试图片 240*240
    if (sys_rst_n == 1'b0)
        flush_data <= 16'd0;
    else if ((flush_addr_width >= 'd0   && flush_addr_width < 'd80) && (flush_addr_height >= 'd0 && flush_addr_height < 'd80))
        flush_data <= 16'hF800; //红  1111 1000 0000 0000
    else if ((flush_addr_width >= 'd80 && flush_addr_width < 'd160) && (flush_addr_height >= 'd0 && flush_addr_height < 'd80))
        flush_data <= 16'h07E0; //绿  0000 0111 1110 0000
    else if ((flush_addr_width >= 'd160 && flush_addr_width < 'd240) && (flush_addr_height >= 'd0 && flush_addr_height < 'd80))
        flush_data <= 16'h001F; //蓝  0000 0000 0001 1111

    else if ((flush_addr_width >= 'd0   && flush_addr_width < 'd80) && (flush_addr_height >= 'd80 && flush_addr_height < 'd160))
        flush_data <= 16'h07E0; //绿
    else if ((flush_addr_width >= 'd80 && flush_addr_width < 'd160) && (flush_addr_height >= 'd80 && flush_addr_height < 'd160))
        flush_data <= 16'h001F; //蓝
    else if ((flush_addr_width >= 'd160 && flush_addr_width < 'd240) && (flush_addr_height >= 'd80 && flush_addr_height < 'd160))
        flush_data <= 16'hF800; //红

    else if ((flush_addr_width >= 'd0   && flush_addr_width < 'd80) && (flush_addr_height >= 'd160 && flush_addr_height < 'd240))
        flush_data <= 16'h001F; //蓝
    else if ((flush_addr_width >= 'd80 && flush_addr_width < 'd160) && (flush_addr_height >= 'd160 && flush_addr_height < 'd240))
        flush_data <= 16'hF800; //红
    else if ((flush_addr_width >= 'd160 && flush_addr_width < 'd240) && (flush_addr_height >= 'd160 && flush_addr_height < 'd240))
        flush_data <= 16'h07E0; //绿
    else
        flush_data <= 16'h0000;
end

//整个spi屏幕控制顶层，用户只需要提供显示数据就可以使用这个顶层进行spi屏幕显示
spi_screen_top spi_screen_top_inst(
    .sys_clk                            (sys_clk                   ),
    .sys_rst_n                          (sys_rst_n                 ),


    //用户信号
    .flush_data_update_o                (flush_data_update         ),//更新当前坐标点显示数据使能
    .flush_data_i                       (flush_data                ),//当前坐标点显示的数据
    .flush_addr_width_o                 (flush_addr_width          ),//当前刷新的x坐标
    .flush_addr_height_o                (flush_addr_height         ),//当前刷新的y坐标

     //spi tft screen   屏幕接口
    .lcd_spi_sclk                       (lcd_spi_sclk              ),// 屏幕spi时钟接口
    .lcd_spi_mosi                       (lcd_spi_mosi              ),// 屏幕spi数据接口
    .lcd_spi_cs                         (lcd_spi_cs                ),// 屏幕spi使能接口
    .lcd_dc                             (lcd_dc                    ),// 屏幕 数据/命令 接口
    .lcd_reset                          (lcd_reset                 ),// 屏幕复位接口
    .lcd_blk                            (lcd_blk                   ) // 屏幕背光接口
);

    // 将内部初始化完成标志引出
    assign lcd_init_done = spi_screen_top_inst.spi_tft_screen_driver_inst.lcd_init_done;

endmodule
