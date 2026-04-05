`timescale 1ns / 1ps

// spi tft屏幕初始化模块 (针对 ST7789 IPS屏优化版)
module spi_tft_screen_init(
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,

    input                               tft_screen_init_req_i      ,//初始化请求
    output                              tft_screen_init_ack_o      ,//初始化响应
    output reg         [   7: 0]        tft_screen_init_data_o     ,//初始化数据
    output reg                          tft_screen_init_dc_o       ,//初始化dc

    output                              spi_send_init_req_o        ,//spi发送请求
    output                              spi_send_init_end_o        ,//结束spi发送
    input                               spi_send_init_ack_i         //spi一次数据发送完成
);

    parameter                           SCREEN_WIDTH              = 16'd240;
    parameter                           SCREEN_HEIGHT             = 16'd240;

    localparam                          DELAY_255ms               = 32'd12_750_000;//255ms 255_000_000 /20 =12_750_000
    localparam                          DELAY_200us               = 32'd10_000;    //200us 200_000/20=10_000
    localparam                          S_IDLE                    = 4'b0001;//初始状态
    localparam                          S_SEND_DATA               = 4'b0010;//数据发送状态
    localparam                          S_DELAY                   = 4'b0100;//延迟状态
    localparam                          S_ACK                     = 4'b1000;//响应状态


    reg                [   4: 0]        init_cnt                   ;//初始化命令/数据计数器
    reg                [  31: 0]        delay_cnt                  ;//延迟计数器
    reg                [   3: 0]        state                      ;//状态机
    reg                [   3: 0]        next_state                 ;//下一状态


    //为响应状态时，初始化完成信号有效
    assign                              tft_screen_init_ack_o     = (state == S_ACK) ? 1'b1 : 1'b0;
    //为数据发送状态时，spi发送请求信号有效
    assign                              spi_send_init_req_o       = (state == S_SEND_DATA) ? 1'b1 : 1'b0;
    //为延迟状态时，结束spi发送
    assign                              spi_send_init_end_o       = (state == S_DELAY) ? 1'b1 : 1'b0;

always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        state <= S_IDLE;
    else
        state <= next_state;
end


always@(*) begin
    case(state)
    S_IDLE:
        if( tft_screen_init_req_i == 1'b1)//初始化请求有效时，跳转到数据发送状态
            next_state <= S_SEND_DATA;
        else
            next_state <= S_IDLE;
    S_SEND_DATA:
        if( spi_send_init_ack_i == 1'b1)//spi一次数据发送完成，跳转到延迟状态
            next_state <= S_DELAY;
        else
            next_state <= S_SEND_DATA;
    S_DELAY:
        if( init_cnt == 'd19)//修改：共19条指令，全部发送完成跳转到响应状态
            if( delay_cnt == DELAY_255ms)
                next_state <= S_ACK;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd1 )//延迟结束后，跳转到数据发送状态
            if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd2 )
            if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd4 )
            if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if(init_cnt == 'd18 )//修改：由于加了一条指令，这里顺延为18
            if(delay_cnt == DELAY_255ms)
                next_state <= S_SEND_DATA;
            else
                next_state <= S_DELAY;
        else if( delay_cnt == DELAY_200us)
            next_state <= S_SEND_DATA;
        else
            next_state <= S_DELAY;
    S_ACK:
        next_state <= S_IDLE;
    default: next_state <= S_IDLE;
    endcase
end


//初始化数据计数器//
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        init_cnt <= 'd0;
    else if( spi_send_init_ack_i == 1'b1)//spi一次数据发送完成，init_cnt加1
        init_cnt <= init_cnt + 1'b1;
    else
        init_cnt <= init_cnt;
end


//延迟计数器//写命令之间需要加入延迟
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        delay_cnt <= 'd0;
    else if( state == S_DELAY)           //为延迟状态时，delay_cnt加1
        delay_cnt <= delay_cnt + 1'b1;
    else
        delay_cnt <= 'd0;
end


//初始化命令序列
//0命令，1数据
always@(*)begin
    case (init_cnt)
        'd0: begin
            tft_screen_init_data_o  = 8'h01;                        //SWRESET//软件复位
            tft_screen_init_dc_o    = 1'b0;
        end
        'd1: begin
            tft_screen_init_data_o  = 8'h11;                        //SLPOUT//睡眠退出
            tft_screen_init_dc_o    = 1'b0;
        end
        'd2: begin
            tft_screen_init_data_o  = 8'h3A;                        //COLMOD//设置像素格式
            tft_screen_init_dc_o    = 1'b0;
        end
        'd3: begin
            tft_screen_init_data_o  = 8'h55;                        //设置//0_101_0_101//0_65k色彩_0_rgb565(16bit)
            tft_screen_init_dc_o    = 1'b1;
        end
        'd4: begin
            tft_screen_init_data_o  = 8'h36;                        //MADCTL//设置帧内存中数据的读写扫描方式
            tft_screen_init_dc_o    = 1'b0;
        end
        'd5: begin
            tft_screen_init_data_o  = 8'h78;                        //设置//01111000 (BGR顺序)。如红蓝反转，请改为 8'h70
            tft_screen_init_dc_o    = 1'b1;
        end
        'd6: begin
            tft_screen_init_data_o  = 8'h21;                        //INVON//开启反相显示 (解决全黑显白问题)
            tft_screen_init_dc_o    = 1'b0;
        end
        'd7: begin
            tft_screen_init_data_o  = 8'h2A;                        //CASET列地址设置
            tft_screen_init_dc_o    = 1'b0;
        end
        'd8: begin
            tft_screen_init_data_o  = 8'h00;                        //列地址起始的高8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd9: begin
            tft_screen_init_data_o  = 8'h00;                        //列地址起始的低8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd10: begin
            tft_screen_init_data_o  = SCREEN_WIDTH[15:8];           //列地址结束的高8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd11: begin
            tft_screen_init_data_o  = SCREEN_WIDTH[7:0] - 1'b1;     //列地址结束的低8位
            tft_screen_init_dc_o    = 1'b1;
        end

        'd12: begin
            tft_screen_init_data_o  = 8'h2B;                        //RASET//行地址设置
            tft_screen_init_dc_o    = 1'b0;
        end

        'd13: begin
            tft_screen_init_data_o  = 8'h00;                        //行地址起始的高8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd14: begin
            tft_screen_init_data_o  = 8'h00;                        //行地址起始的低8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd15: begin
            tft_screen_init_data_o  = SCREEN_HEIGHT[15:8];          //行地址结束的高8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd16: begin
            tft_screen_init_data_o  = SCREEN_HEIGHT[7:0] - 1'b1;    //行地址结束的低8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd17: begin
            tft_screen_init_data_o  = 8'h13;                        //NORON//转换为正常显示模式
            tft_screen_init_dc_o    = 1'b0;
        end
        'd18: begin
            tft_screen_init_data_o  = 8'h29;                        //DISPON//开启显示
            tft_screen_init_dc_o    = 1'b0;
        end
        default: begin
            tft_screen_init_data_o  = 8'h01;                        //SWRESET//软件复位
            tft_screen_init_dc_o    = 1'b0;
        end
    endcase
end

endmodule