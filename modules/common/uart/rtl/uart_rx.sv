// UART 接收模块
// 功能：接收 UART 数据，8N1 格式（1起始位 + 8数据位 + 1停止位）
// 采样点位于每位中间位置，确保数据稳定

module uart_rx (
    input               clk         ,  // 系统时钟
    input               rst_n       ,  // 复位信号，低有效

    input               uart_rxd    ,  // UART 接收引脚
    output  reg         uart_rx_done,  // 接收完成脉冲信号
    output  reg [7:0]   uart_rx_data   // 接收到的数据
);

    // 系统时钟频率和目标波特率
    parameter CLK_FREQ = 50_000_000;         // 50MHz 系统时钟
    parameter UART_BPS = 115200  ;           // 115200 波特率
    localparam [31:0] BAUD_CNT_MAX = CLK_FREQ / UART_BPS;  // 每个比特对应的时钟周期数

    // 跨时钟域同步寄存器链（3级），防止亚稳态
    reg uart_rxd_d0;
    reg uart_rxd_d1;
    reg uart_rxd_d2;

    // 接收状态标志：0=空闲，1=正在接收
    reg rx_flag;

    // bit 计数器：0=起始位，1-8=数据位，9=停止位
    reg [3:0] rx_cnt;

    // 波特率计数器：每位时间内计数
    reg [15:0] baud_cnt;

    // 临时数据寄存器，接收过程中暂存数据
    reg [7:0] rx_data_t;

    // 检测起始位：当 rxd 从高跳变到低（空闲时）产生一个脉冲
    wire start_en;

    // UART 空闲时收到起始位（下降沿）则启动接收
    assign start_en = uart_rxd_d2 & ~uart_rxd_d1 & ~rx_flag;

    // 3级同步器：将异步输入信号同步到 clk 时钟域
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rxd_d0 <= 1'b0;
            uart_rxd_d1 <= 1'b0;
            uart_rxd_d2 <= 1'b0;
        end else begin
            uart_rxd_d0 <= uart_rxd;
            uart_rxd_d1 <= uart_rxd_d0;
            uart_rxd_d2 <= uart_rxd_d1;
        end
    end

    // 接收状态控制：检测到起始位时进入接收状态，接收完10位后退出
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rx_flag <= 1'b0;
        else if (start_en)
            rx_flag <= 1'b1;  // 收到起始位，开始接收
        // 接收完停止位（计数到9且到达中间位置）时退出接收状态
        else if ((rx_cnt == 4'd9) && (baud_cnt == BAUD_CNT_MAX / 2 - 1))
            rx_flag <= 1'b0;
    end

    // 波特率计数器：每位时间计数一次，循环
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            baud_cnt <= 16'd0;
        else if (rx_flag) begin
            if (baud_cnt < BAUD_CNT_MAX - 1)
                baud_cnt <= baud_cnt + 1;
            else
                baud_cnt <= 16'd0;
        end else begin
            baud_cnt <= 16'd0;
        end
    end

    // bit 计数器：每位结束时加1，rx_flag 为 0 时清零
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rx_cnt <= 4'd0;
        else if (rx_flag) begin
            if (baud_cnt == BAUD_CNT_MAX - 1)
                rx_cnt <= rx_cnt + 1;
        end else begin
            rx_cnt <= 4'd0;
        end
    end

    // 数据采样：在每位中间位置采样（baud_cnt 计数到中间时）
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            rx_data_t <= 8'b0;
        else if (rx_flag) begin
            if (baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
                case (rx_cnt)
                    4'd1 : rx_data_t[0] <= uart_rxd_d2;  // 数据位 bit0（LSB）
                    4'd2 : rx_data_t[1] <= uart_rxd_d2;
                    4'd3 : rx_data_t[2] <= uart_rxd_d2;
                    4'd4 : rx_data_t[3] <= uart_rxd_d2;
                    4'd5 : rx_data_t[4] <= uart_rxd_d2;
                    4'd6 : rx_data_t[5] <= uart_rxd_d2;
                    4'd7 : rx_data_t[6] <= uart_rxd_d2;
                    4'd8 : rx_data_t[7] <= uart_rxd_d2;  // 数据位 bit7（MSB）
                    default : ;
                endcase
            end
        end else begin
            rx_data_t <= 8'b0;
        end
    end

    // 接收完成输出：停止位中间位置时给出完成脉冲，并输出数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rx_done <= 1'b0;
            uart_rx_data <= 8'b0;
        end else if (rx_cnt == 4'd9 && baud_cnt == BAUD_CNT_MAX / 2 - 1) begin
            uart_rx_done <= 1'b1;
            uart_rx_data <= rx_data_t;
        end else begin
            uart_rx_done <= 1'b0;
            uart_rx_data <= uart_rx_data;
        end
    end

endmodule
