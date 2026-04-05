`timescale 1ns / 1ps

// spi tft屏幕数据刷新模块
module spi_tft_screen_flush(
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,


    //用户接口
    input              [   7: 0]        spi_screen_flush_data_i    ,//屏幕显示数据
    output                              spi_screen_flush_updte_o   ,//屏幕数据更新
    output                              spi_screen_flush_fsync_o   ,//屏幕帧同步


    //上层模块
    input                               tft_screen_flush_req_i     ,//刷新请求//初始化完成之后信号有效，模块进入刷新模式
    output reg         [   7: 0]        tft_screen_flush_data_o    ,//刷新数据//刷新的图像数据经刷新模块通过spi模块发送
    output reg                          tft_screen_flush_dc_o      ,//刷新dc//数据/命令控制信号

    //SPI子模块
    output                              spi_send_flush_req_o       ,//spi发送请求
    output                              spi_send_flush_end_o       ,//结束spi发送
    input                               spi_send_flush_ack_i        //spi一次数据发送完成
);
    parameter                           SCREEN_WIDTH              = 16'd240;
    parameter                           SCREEN_HEIGHT             = 16'd240;
    parameter                           Number_Of_Pixels          = 32'd240*32'd240*32'd2; // 总像素数


    localparam                          S_IDLE                    = 4'b0001;
    localparam                          S_DATA                    = 4'b0010;  //数据传输
    localparam                          S_DELAY                   = 4'b0100;  //延迟
    localparam                          S_FRAME_SYNC              = 4'b1000;  // 帧同步


    localparam                          DELAY_5clk                = 'd5   ; //在发送数据之间需要等待5个时钟周期

    reg                [  31: 0]        flush_cnt                  ;        //刷新模块写命令/数据计数器
    reg                [  12: 0]        delay_cnt                  ;        //延迟计数器
    reg                [   3: 0]        state           ,next_state;        //状态机

    //为数据传输状态时，发送请求
    assign                              spi_send_flush_req_o      = (state == S_DATA) ? 1'b1 : 1'b0;
    //为延迟状态或帧同步状态时，结束信号有效
    assign                              spi_send_flush_end_o      = (state == S_DELAY || state == S_FRAME_SYNC) ? 1'b1 : 1'b0;

    //在数据传输时，当写命令/数据计数器 大于等于10时，屏幕数据更新
    assign                              spi_screen_flush_updte_o  = ( spi_send_flush_ack_i == 1'b1 && flush_cnt >= 'd10 ) ? 1'b1 : 1'b0;
    //为帧同步状态时，屏幕帧同步信号有效，产生帧同步信号
    assign                              spi_screen_flush_fsync_o  = ( state == S_FRAME_SYNC ) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        state <= S_IDLE;
    else
        state <= next_state;            //当前状态值为下一状态
end


always@(*) begin
    case(state)
    S_IDLE:
        if( tft_screen_flush_req_i == 1'b1 )                    //初始化完成之后信号有效，模块进入刷新模式
            next_state = S_DATA;
        else
            next_state = S_IDLE;
    S_DATA:
        if( spi_send_flush_ack_i == 1'b1 && flush_cnt <= 'd10 )     //地址设置需要先写入，写入的是设置XY地址，需要10个数据
            next_state = S_DELAY;                                   //实际操作中，在写命令时需要11个数据，所以flush_cnt要大于10
        else if( spi_send_flush_ack_i == 1'b1 && flush_cnt == (Number_Of_Pixels + 'd10))//一帧图像数据发送完成，跳转到帧同步状态
            next_state = S_FRAME_SYNC;
        else
            next_state = S_DATA;
    S_DELAY:
        if( delay_cnt == DELAY_5clk)  //延迟5个时钟周期后，跳转到S_DATA状态
            next_state = S_DATA;
        else
            next_state = S_DELAY;
    S_FRAME_SYNC:
        next_state = S_IDLE;
    default: next_state = S_IDLE;
    endcase
end


//数据计数器
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        flush_cnt <= 'd0;
    else if( spi_send_flush_ack_i == 1'b1 &&  flush_cnt == (Number_Of_Pixels + 'd10))//一帧图像数据发送完成，flush_cnt清零
        flush_cnt <= 'd0;
    else if( spi_send_flush_ack_i == 1'b1 )//发送完一个数据，flush_cnt加1
        flush_cnt <= flush_cnt + 1'b1;
    else
        flush_cnt <= flush_cnt;
end


//延迟计数器
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        delay_cnt <= 'd0;
    else if( state == S_DELAY)//为延迟状态时，delay_cnt加1
        delay_cnt <= delay_cnt + 1'b1;
    else
        delay_cnt <= 'd0;
end

//tft_screen_flush_dc_o=0时写命令
//tft_screen_flush_dc_o=1时写数据
always @(*) begin
    case(flush_cnt)
    'd0: begin
        tft_screen_flush_data_o = 8'h2A;                        //设置列地址
        tft_screen_flush_dc_o   = 1'b0;
    end
    //写X
    'd1: begin
        tft_screen_flush_data_o = 8'h00;                        //列地址起始的高8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    'd2: begin
        tft_screen_flush_data_o = 8'h00;                        //列地址起始的低8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    'd3: begin
        tft_screen_flush_data_o = SCREEN_WIDTH[15:8];           //列地址结束的高8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    'd4: begin
        tft_screen_flush_data_o = SCREEN_WIDTH[7:0] - 1'b1;     //列地址结束的低8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    //写Y
    'd5: begin
        tft_screen_flush_data_o = 8'h2B;                        //设置行地址
        tft_screen_flush_dc_o   = 1'b0;
    end
    'd6: begin
        tft_screen_flush_data_o = 8'h00;                        //行地址起始的高8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    'd7: begin
        tft_screen_flush_data_o = 8'h00;                        //行地址起始的低8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    'd8: begin
        tft_screen_flush_data_o = SCREEN_HEIGHT[15:8];          //行地址结束的高8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    'd9: begin
        tft_screen_flush_data_o = SCREEN_HEIGHT[7:0] - 1'b1;    //行地址结束的低8位
        tft_screen_flush_dc_o   = 1'b1;
    end
    //写数据
    'd10: begin
        tft_screen_flush_data_o = 8'h2C;                        //写入图像数据
        tft_screen_flush_dc_o   = 1'b0;
    end
    default: begin
        tft_screen_flush_data_o = spi_screen_flush_data_i;      //图像显示数据
        tft_screen_flush_dc_o   = 1'b1;
    end
    endcase
end

endmodule