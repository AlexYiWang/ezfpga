`timescale 1ns / 1ps

// SPI模式说明：
// 模式0：CPOL=0，CPHA=0，SCK空闲状态为低电平，在SCK时钟的上升沿采样数据，在SCK时钟的下降沿变化
// 模式1：CPOL=0，CPHA=1，SCK空闲状态为低电平，在SCK时钟的下降沿采样数据，在SCK时钟的上升沿变化
// 模式2：CPOL=1，CPHA=0，SCK空闲状态为高电平，在SCK时钟的下降沿采样数据，在SCK时钟的上升沿变化
// 模式3：CPOL=1，CPHA=1，SCK空闲状态为高电平，在SCK时钟的上升沿采样数据，在SCK时钟的下降沿变化

// 使用模式3：CPOL=1，CPHA=1，SCK空闲状态为高电平，在SCK时钟的上升沿采样数据，在SCK时钟的下降沿变化
module spi_master_driver(
    //系统接口
    input                               sys_clk                    ,
    input                               sys_rst_n                  ,

    //用户接口
    input                               spi_start_i                ,// SPI开始信号
    input                               spi_end_i                  ,// SPI结束信号
    input              [   7: 0]        spi_send_data_i            ,// SPI发送数据
    output      reg                     spi_send_ack_o             ,// SPI发送8bit完成信号

    input                               lcd_dc_i                   ,//数据/命令信号输入
    output reg                          lcd_dc                     ,//数据/命令信号输出
    //SPI 端口
    output reg                          spi_sclk                   ,//SPI时钟


    output reg                          spi_mosi                   ,//SPI数据
    output                              spi_cs                      //SPI片选
);
localparam	IDLE = 3'b001,  //空闲状态
			DATA = 3'b010,  //数据传输状态
			STOP = 3'b100;  //停止状态
    reg	               [2:0]	    cure_state;//当前状态
    reg	               [2:0]	    next_state;//下一状态

    reg                [7:0]        spi_send_data_reg          ;//数据寄存器
    reg                [3:0]        spi_send_data_bit_cnt      ;//数据传输bit计数器

assign spi_cs = (cure_state == IDLE) ?1:0;    //片选信号，低电平有效，空闲状态时为高
always @(posedge sys_clk or negedge sys_rst_n)
	if(sys_rst_n == 1'b0 )
		cure_state <= IDLE;
	else
		cure_state <= next_state;
always @(*)
	case(cure_state)
		IDLE:begin	//空闲
			if(spi_start_i)	//spi_start 开始信号到来时，开始进行数据传输
				next_state = DATA;
			else
				next_state = IDLE;
		end
		DATA:begin	//数据传输
			if(spi_send_data_bit_cnt == 7 &&  spi_sclk == 1'b0)	//字节传输完成
				next_state = STOP;
			else
				next_state = DATA;
		end
		STOP:next_state = IDLE;	//停止
		default:next_state = IDLE;
	endcase

//数据传输完成后，加载新数据
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        spi_send_data_reg <= 'd0;
    else if(spi_send_data_bit_cnt == 'd0)         //8bit数据传输完成后，加载新数据
        spi_send_data_reg <= spi_send_data_i;
    else
        spi_send_data_reg <= spi_send_data_reg;
end
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0 )
        spi_send_ack_o <= 'd0;
    else if(spi_send_data_bit_cnt == 'd7 && spi_sclk == 1'b0 && spi_cs == 1'b0)     //发送完8位数据后，spi发送8bit完成信号置位
        spi_send_ack_o <= 'd1;
    else
        spi_send_ack_o <= 'd0;
end
//数据/命令信号锁存
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        lcd_dc <= 1'b1;
    else if( spi_start_i == 1'b1)  //接收到开始信号时，lcd_dc赋值为lcd_dc_i
        lcd_dc <= lcd_dc_i;
    else
        lcd_dc <= lcd_dc;
end
//生成spi时钟
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_sclk <= 1'b1;
    else if(cure_state != DATA )
        spi_sclk <= 1'b1;
    else if( spi_cs == 1'b0 )
        spi_sclk <= ~spi_sclk;  //当spi_cs为低电平时，翻转spi_sclk，产生40ns频率的sclk时钟
    else
        spi_sclk <= 1'b1;
end
//数据传输bit计数
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_send_data_bit_cnt <= 'd0;
    else if( spi_cs == 1'b0 && spi_sclk == 1'b0) //使用SPI模式3，在时钟下降沿采样，所以在时钟为低电平时，数据计数器加1
        if( spi_send_data_bit_cnt == 'd7)//发送完8位数据，清零
            spi_send_data_bit_cnt <= 'd0;
        else
            spi_send_data_bit_cnt <= spi_send_data_bit_cnt + 1'b1;
    else if( spi_cs == 1'b0)
        spi_send_data_bit_cnt <= spi_send_data_bit_cnt;//其他时候，保持不变
    else
        spi_send_data_bit_cnt <= 'd0;
end

//spi数据发送
always@(posedge sys_clk or negedge sys_rst_n) begin
    if( sys_rst_n == 1'b0)
        spi_mosi <= 1'b1;
    else if( spi_cs == 1'b0)
        spi_mosi <= spi_send_data_reg['d7 - spi_send_data_bit_cnt];//数据从高位到低位依次发送
    else
        spi_mosi <= spi_mosi;
end

endmodule