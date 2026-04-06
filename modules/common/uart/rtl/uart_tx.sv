// UART 发送模块
// 功能：按 8N1 格式（1起始位 + 8数据位 + 1停止位）发送数据
// 波特率由系统时钟分频生成

module uart_tx (
    input               clk         ,  // 系统时钟
    input               rst_n       ,  // 复位信号，低有效
    input               uart_tx_en  ,  // 发送使能脉冲（高有效）
    input      [7:0]    uart_tx_data,  // 要发送的数据
    output  reg         uart_txd    ,  // UART 发送引脚
    output  reg         uart_tx_busy   // 发送忙标志：1=正在发送，0=空闲
);

    // 系统时钟频率和目标波特率
    parameter CLK_FREQ = 50_000_000;    // 50MHz 系统时钟
    parameter UART_BPS = 115200  ;      // 115200 波特率
    localparam BAUD_CNT_MAX = CLK_FREQ / UART_BPS;  // 每个比特对应的时钟周期数

    // 发送数据寄存器：使能时锁存要发送的数据
    reg [7:0] tx_data_t;

    // bit 计数器：0=起始位，1-8=数据位，9=停止位
    reg [3:0] tx_cnt;

    // 波特率计数器：每位时间内计数
    reg [15:0] baud_cnt;

    // 发送控制：收到使能脉冲时锁存数据并进入发送状态，发送完成后退出
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_data_t <= 8'b0;
            uart_tx_busy <= 1'b0;
        end else if (uart_tx_en) begin
            tx_data_t <= uart_tx_data;
            uart_tx_busy <= 1'b1;
        end else if (tx_cnt == 4'd9 && baud_cnt == BAUD_CNT_MAX - 1) begin
            tx_data_t <= 8'b0;
            uart_tx_busy <= 1'b0;
        end
    end

    // 波特率计数器：发送状态时计数，空闲或开始发送时清零
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            baud_cnt <= 16'd0;
        else if (uart_tx_en)
            baud_cnt <= 16'd0;
        else if (uart_tx_busy) begin
            if (baud_cnt < BAUD_CNT_MAX - 1)
                baud_cnt <= baud_cnt + 1;
            else
                baud_cnt <= 16'd0;
        end
    end

    // bit 计数器：每位结束时加1，使能时或空闲时清零
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            tx_cnt <= 4'd0;
        else if (uart_tx_en)
            tx_cnt <= 4'd0;
        else if (uart_tx_busy) begin
            if (baud_cnt == BAUD_CNT_MAX - 1)
                tx_cnt <= tx_cnt + 1;
        end
    end

    // 串行输出：根据 tx_cnt 输出对应的位
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            uart_txd <= 1'b1;
        else if (uart_tx_busy) begin
            case (tx_cnt)
                4'd0 : uart_txd <= 1'b0;         // 起始位
                4'd1 : uart_txd <= tx_data_t[0];  // 数据位 bit0（LSB）
                4'd2 : uart_txd <= tx_data_t[1];
                4'd3 : uart_txd <= tx_data_t[2];
                4'd4 : uart_txd <= tx_data_t[3];
                4'd5 : uart_txd <= tx_data_t[4];
                4'd6 : uart_txd <= tx_data_t[5];
                4'd7 : uart_txd <= tx_data_t[6];
                4'd8 : uart_txd <= tx_data_t[7];  // 数据位 bit7（MSB）
                4'd9 : uart_txd <= 1'b1;         // 停止位
                default : uart_txd <= 1'b1;
            endcase
        end else begin
            uart_txd <= 1'b1;  // 空闲时保持高电平
        end
    end

endmodule
