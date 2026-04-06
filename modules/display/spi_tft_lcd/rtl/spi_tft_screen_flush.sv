`timescale 1ns / 1ps

//对spi tft屏幕进行刷新
// SPI TFT LCD刷新控制模块
// 功能：控制屏幕初始化后的数据刷新流程，包括发送配置命令和像素数据
//       生成帧同步信号和像素更新请求，协调SPI主模块的时序
module spi_tft_screen_flush(
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,


    //用户接口
    input              [   7: 0]        spi_screen_flush_data_i    ,//屏幕显示数据，来自上层模块的8位像素数据
    output                              spi_screen_flush_updte_o   ,//像素点数据刷新，请求上层提供新数据
    output                              spi_screen_flush_fsync_o   ,//屏幕帧同步，指示一帧数据发送完成


    //驱动模块
    input                               tft_screen_flush_req_i     ,//刷新请求//初始化完成之后此信号拉高模块进入刷新模式
    output reg         [   7: 0]        tft_screen_flush_data_o    ,//刷新数据//刷新的图像数据和刷新命令通过spi模块发送
    output reg                          tft_screen_flush_dc_o      ,//刷新dc//区分命令与数据
                                             // 0:命令，1:数据

    //SPI主模块
    output                              spi_send_flush_req_o       ,//spi发送数据请求，高电平请求发送
    output                              spi_send_flush_end_o       ,//结束spi发送，高电平表示传输结束
    input                               spi_send_flush_ack_i        //spi一个数据发送完成，应答信号
);
    parameter                           SCREEN_WIDTH              = 16'd240;  // 屏幕宽度（像素）
    parameter                           SCREEN_HEIGHT             = 16'd240;  // 屏幕高度（像素）
    parameter                           Number_Of_Pixels          = 32'd240*32'd240*32'd2; // 像素点个数（240x240x2字节）
                                                                                 // 乘以2是因为每个像素16位=2字节

    // 状态机状态定义
    localparam                          S_IDLE                    = 4'b0001;  // 空闲状态，等待刷新请求
    localparam                          S_DATA                    = 4'b0010;  // 发送数据状态，发送命令或像素数据
    localparam                          S_DELAY                   = 4'b0100;  // 延时状态，命令与数据间切换等待
    localparam                          S_FRAME_SYNC              = 4'b1000;  // 帧同步状态，一帧发送完成

    // 时序参数
    localparam                          DELAY_5clk                = 'd5   ; //命令与数据之间切换等待5个时钟周期

    reg                [  31: 0]        flush_cnt                  ;        //刷新模块写命令/数据计数器
                                                                                 // 计数发送的字节数，包括命令、参数和像素数据
    reg                [  12: 0]        delay_cnt                  ;        //延迟计数，用于S_DELAY状态
    reg                [   3: 0]        state           ,next_state;        //状态寄存器和下一状态

    // SPI控制信号赋值逻辑
    // 为写数据状态时，请求拉高
    assign spi_send_flush_req_o = (state == S_DATA) ? 1'b1 : 1'b0;  // 仅在发送数据时请求SPI传输

    // 为延迟状态或帧同步状态时结束信号拉高
    assign spi_send_flush_end_o = (state == S_DELAY || state == S_FRAME_SYNC) ? 1'b1 : 1'b0; // 非数据传输状态表示结束

    // 用户接口信号赋值逻辑
    // 当发送完数据时，且写命令/数据计数器计数到10时，像素点数据刷新拉高
    // 前10个字节是配置命令(2A+4参数 + 2B+4参数 + 2C)，之后才是像素数据
    assign spi_screen_flush_updte_o = (spi_send_flush_ack_i == 1'b1 && flush_cnt >= 'd10) ? 1'b1 : 1'b0;

    // 为帧同步状态时，屏幕帧同步拉高，产生帧同步信号
    assign spi_screen_flush_fsync_o = (state == S_FRAME_SYNC) ? 1'b1 : 1'b0;

// 状态寄存器更新逻辑
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        state <= S_IDLE;                // 复位时回到空闲状态
    else
        state <= next_state;            // 将状态赋值为下一状态
end


// 状态转移逻辑：根据当前状态和输入条件确定下一状态
always@(*) begin
    case(state)
    S_IDLE:  // 空闲状态：等待刷新请求
        if( tft_screen_flush_req_i == 1'b1 )                    //初始化完成之后此信号拉高模块进入刷新模式
            next_state = S_DATA;                                // 收到请求，开始发送数据
        else
            next_state = S_IDLE;                                // 无请求，保持空闲

    S_DATA:  // 发送数据状态：发送配置命令或像素数据
        if( spi_send_flush_ack_i == 1'b1 && flush_cnt <= 'd10 )     // 发送完一个字节且还在前10个配置字节内
            next_state = S_DELAY;                                   // 配置命令间需要延迟
        else if( spi_send_flush_ack_i == 1'b1 && flush_cnt == (Number_Of_Pixels + 'd10))// 一帧图像数据发送完成
            next_state = S_FRAME_SYNC;                               // 跳转到帧同步状态
        else
            next_state = S_DATA;                                    // 继续发送数据

    S_DELAY:  // 延时状态：命令与数据间切换等待
        if( delay_cnt == DELAY_5clk)  // 延迟5个时钟周期后
            next_state = S_DATA;        // 跳转回数据发送状态
        else
            next_state = S_DELAY;       // 继续延迟

    S_FRAME_SYNC:  // 帧同步状态：一帧发送完成
        next_state = S_IDLE;            // 总是返回空闲状态，等待下一帧

    default:
        next_state = S_IDLE;            // 默认返回空闲状态
    endcase
end


// 发送数据计数器：统计已发送的字节数
// 计数范围：0 ~ (Number_Of_Pixels + 10)
// 0-9: 配置命令和参数（2A+4参数 + 2B+4参数 + 2C）
// 10~: 像素数据（每个像素2字节）
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        flush_cnt <= 'd0;                                                    // 复位清零
    else if( spi_send_flush_ack_i == 1'b1 && flush_cnt == (Number_Of_Pixels + 'd10)) // 一帧图像数据发送完成
        flush_cnt <= 'd0;                                                    // 计数器清零，准备下一帧
    else if( spi_send_flush_ack_i == 1'b1 )                                  // 发送完一个字节
        flush_cnt <= flush_cnt + 1'b1;                                       // 计数器加1
    else
        flush_cnt <= flush_cnt;                                              // 无发送，保持计数值
end


// 延时计数器：用于S_DELAY状态的定时
// TFT屏幕要求命令与数据间有一定延迟时间
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        delay_cnt <= 'd0;                          // 复位清零
    else if( state == S_DELAY)                     // 处于延迟状态
        delay_cnt <= delay_cnt + 1'b1;             // 计数器递增
    else
        delay_cnt <= 'd0;                          // 非延迟状态时清零
end

// 数据选择逻辑：根据flush_cnt选择发送命令、参数或像素数据
// tft_screen_flush_dc_o = 0: 写命令 (Command)
// tft_screen_flush_dc_o = 1: 写数据 (Data)
// 前11个字节(0-10)是屏幕配置命令，之后是像素数据
always @(*) begin
    case(flush_cnt)
    // 字节0: 设置列地址命令 (0x2A = CASET)
    'd0: begin
        tft_screen_flush_data_o = 8'h2A;                        // 设置列地址命令
        tft_screen_flush_dc_o   = 1'b0;                         // 命令模式
    end

    // 字节1-4: 列地址参数 (X起始和结束地址)
    // 写X起始地址高8位
    'd1: begin
        tft_screen_flush_data_o = 8'h00;                        // 列地址开始的高8位 (X起始=0)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end
    // 写X起始地址低8位
    'd2: begin
        tft_screen_flush_data_o = 8'h00;                        // 列地址开始的低8位 (X起始=0)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end
    // 写X结束地址高8位
    'd3: begin
        tft_screen_flush_data_o = SCREEN_WIDTH[15:8];           // 列地址结束的高8位 (X结束=239)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end
    // 写X结束地址低8位 (需要-1，因为地址从0开始)
    'd4: begin
        tft_screen_flush_data_o = SCREEN_WIDTH[7:0] - 1'b1;     // 列地址结束的低8位 (X结束=239)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end

    // 字节5: 设置行地址命令 (0x2B = RASET)
    'd5: begin
        tft_screen_flush_data_o = 8'h2B;                        // 设置行地址命令
        tft_screen_flush_dc_o   = 1'b0;                         // 命令模式
    end

    // 字节6-9: 行地址参数 (Y起始和结束地址)
    // 写Y起始地址高8位
    'd6: begin
        tft_screen_flush_data_o = 8'h00;                        // 行地址开始的高8位 (Y起始=0)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end
    // 写Y起始地址低8位
    'd7: begin
        tft_screen_flush_data_o = 8'h00;                        // 行地址开始的低8位 (Y起始=0)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end
    // 写Y结束地址高8位
    'd8: begin
        tft_screen_flush_data_o = SCREEN_HEIGHT[15:8];          // 行地址结束的高8位 (Y结束=239)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end
    // 写Y结束地址低8位 (需要-1)
    'd9: begin
        tft_screen_flush_data_o = SCREEN_HEIGHT[7:0] - 1'b1;    // 行地址结束的低8位 (Y结束=239)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end

    // 字节10: 内存写命令 (0x2C = RAMWR)
    'd10: begin
        tft_screen_flush_data_o = 8'h2C;                        // 发送图像数据命令
        tft_screen_flush_dc_o   = 1'b0;                         // 命令模式
    end

    // 字节11及以后: 像素数据 (每个像素16位=2字节)
    default: begin
        tft_screen_flush_data_o = spi_screen_flush_data_i;      // 图像显示数据 (来自上层模块)
        tft_screen_flush_dc_o   = 1'b1;                         // 数据模式
    end
    endcase
end

endmodule