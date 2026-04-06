`timescale 1ns / 1ps

//对spi tft屏幕进行初始化
module spi_tft_screen_init(
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,


    input                               tft_screen_init_req_i      ,//初始化请求
    output                              tft_screen_init_ack_o      ,//初始化完成
    output reg         [   7: 0]        tft_screen_init_data_o     ,//初始化数据
    output reg                          tft_screen_init_dc_o       ,//初始化dc

    output                              spi_send_init_req_o        ,//spi发送数据请求
    output                              spi_send_init_end_o        ,//结束spi发送
    input                               spi_send_init_ack_i         //spi一个数据发送完成
);
    parameter                           SCREEN_WIDTH              = 16'd240;
    parameter                           SCREEN_HEIGHT             = 16'd240;


    localparam                          DELAY_255ms               = 32'd12_750_000;//255ms 255_000_000 /20 =12_750_000
    localparam                          DELAY_200us               = 32'd10_000;    //200us 200_000/20=10_000
    localparam                          S_IDLE                    = 4'b0001;//初始状态
    localparam                          S_SEND_DATA               = 4'b0010;//发送数据状态
    localparam                          S_DELAY                   = 4'b0100;//延迟状态
    localparam                          S_ACK                     = 4'b1000;//响应状态


    reg                [   4: 0]        init_cnt                   ;//初始化命令/数据计数
    reg                [  31: 0]        delay_cnt                  ;//延时计数
    reg                [   3: 0]        state                      ;//状态寄存器
    reg                [   3: 0]        next_state                 ;//下一状态寄存器


    //为响应状态时，初始化完成信号拉高
    assign                              tft_screen_init_ack_o     = (state == S_ACK) ? 1'b1 : 1'b0;
    //为发送数据状态时，spi发送数据请求信号拉高
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
        if( tft_screen_init_req_i == 1'b1)//初始化请求有效时，跳转到发送数据状态
            next_state = S_SEND_DATA;
        else
            next_state = S_IDLE;
    S_SEND_DATA:
        if( spi_send_init_ack_i == 1'b1)//spi一个数据发送完成，跳转到延迟状态
            next_state = S_DELAY;
        else
            next_state = S_SEND_DATA;
    S_DELAY:
        // 🔥 修复点1：总数从18改成19
        if( init_cnt == 'd19)//初始化命令和数据发送完成跳转到响应状态
            if( delay_cnt == DELAY_255ms)
                next_state = S_ACK;
            else
                next_state = S_DELAY;
        else if(init_cnt == 'd1 )//延迟结束后，跳转到发送数据状态
            if(delay_cnt == DELAY_255ms)
                next_state = S_SEND_DATA;
            else
                next_state = S_DELAY;
        else if(init_cnt == 'd2 )
                if(delay_cnt == DELAY_255ms)
                next_state = S_SEND_DATA;
            else
                next_state = S_DELAY;
        else if(init_cnt == 'd4 )
                if(delay_cnt == DELAY_255ms)
                next_state = S_SEND_DATA;
            else
                next_state = S_DELAY;
        else if(init_cnt == 'd17 )
                if(delay_cnt == DELAY_255ms)
                next_state = S_SEND_DATA;
            else
                next_state = S_DELAY;
        else if( delay_cnt == DELAY_200us)
            next_state = S_SEND_DATA;
        else
            next_state = S_DELAY;
    S_ACK:
        next_state = S_IDLE;
    default: next_state = S_IDLE;
    endcase

end




//初始化数据计数//
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        init_cnt <= 'd0;
    else if( spi_send_init_ack_i == 1'b1)//spi一个数据发送完成，init_cnt加1
        init_cnt <= init_cnt + 1'b1;
    else
        init_cnt <= init_cnt;
end


//延时计数//写命令之间需要间隔的时间
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        delay_cnt <= 'd0;
    else if( state == S_DELAY)           //为延迟状态时，delay_cnt加1
        delay_cnt <= delay_cnt + 1'b1;
    else
        delay_cnt <= 'd0;
end


//命令数据输出
//0命令，1数据
always@(*)begin
    case (init_cnt)
        'd0: begin
            tft_screen_init_data_o  = 8'h01;                        //SWRESET//软复位
            tft_screen_init_dc_o    = 1'b0;
        end
        'd1: begin
            tft_screen_init_data_o  = 8'h11;                        //SLPOUT//唤醒
            tft_screen_init_dc_o    = 1'b0;
        end
        'd2: begin
            tft_screen_init_data_o  = 8'h3A;                        //COLMOD//像素设置
            tft_screen_init_dc_o    = 1'b0;
        end
        'd3: begin
            tft_screen_init_data_o  = 8'h55;                        //数据//0_101_0_101//0_65k像素_0_rgb565(16bit)
            tft_screen_init_dc_o    = 1'b1;
        end
        'd4: begin
            tft_screen_init_data_o  = 8'h36;                        //MADCTL//帧内存数据的读写扫描方向
            tft_screen_init_dc_o    = 1'b0;
        end
        'd5: begin
            tft_screen_init_data_o  = 8'h70;                        //数据
            tft_screen_init_dc_o    = 1'b1;
        end
        'd6: begin
            tft_screen_init_data_o  = 8'h2A;                        //CASET列地址设置
            tft_screen_init_dc_o    = 1'b0;
        end

        'd7: begin
            tft_screen_init_data_o  = 8'h00;                        //列地址开始的高8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd8: begin
            tft_screen_init_data_o  = 8'h00;                        //列地址开始的低8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd9: begin
            tft_screen_init_data_o  = SCREEN_WIDTH[15:8];           //列地址结束的高8位
            tft_screen_init_dc_o    = 1'b1;
        end
        'd10: begin
            tft_screen_init_data_o  = SCREEN_WIDTH[7:0] - 1'b1;     //列地址结束的低8位
            tft_screen_init_dc_o    = 1'b1;
        end

        'd11: begin
            tft_screen_init_data_o  = 8'h2B;                        //RASET//行地址设置
            tft_screen_init_dc_o    = 1'b0;
        end

        'd12: begin
            tft_screen_init_data_o  = 8'h00;                        //与列地址设置相似
            tft_screen_init_dc_o    = 1'b1;
        end
        'd13: begin
            tft_screen_init_data_o  = 8'h00;                        //数据
            tft_screen_init_dc_o    = 1'b1;
        end
        'd14: begin
            tft_screen_init_data_o  = SCREEN_HEIGHT[15:8];          //数据
            tft_screen_init_dc_o    = 1'b1;
        end
        'd15: begin
            tft_screen_init_data_o  = SCREEN_HEIGHT[7:0] - 1'b1;    //数据
            tft_screen_init_dc_o    = 1'b1;
        end
        'd16: begin
            tft_screen_init_data_o  = 8'h13;                        //NORON//转换为正常显示模式
            tft_screen_init_dc_o    = 1'b0;
        end
        // 🔥 修复点2：加入关闭反色命令 INVOFF (0x21)
        'd17: begin
            tft_screen_init_data_o  = 8'h21;                        // INVOFF 关闭反色显示
            tft_screen_init_dc_o    = 1'b0;
        end
        'd18: begin
            tft_screen_init_data_o  = 8'h29;                        //DISPON//开启显示
            tft_screen_init_dc_o    = 1'b0;
        end
        default: begin
            tft_screen_init_data_o  = 8'h00;
            tft_screen_init_dc_o    = 1'b0;
        end
    endcase
end

endmodule
