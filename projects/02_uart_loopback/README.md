# 案例2: UART 回环测试

## 实验目标
验证 UART 硬件连接是否正确，将接收到的数据原样发送出去。

## 硬件连接
| FPGA 引脚 | 信号 | 说明 |
|-----------|------|------|
| R4 | sys_clk | 系统时钟输入 |
| U7 | sys_rst_n | 复位信号，低有效 |
| E14 | uart_rxd | UART 接收引脚 |
| D17 | uart_txd | UART 发送引脚 |

## 软件设计
- **顶层模块**: `uart_loopback.sv`
- **通信格式**: 8N1（115200 波特率）
- **回环方式**: 收到数据后立即发送

## 文件说明
- `rtl/uart_loopback.sv` - 回环测试顶层
- `constrs/uart_loopback.xdc` - 引脚约束文件
- `scripts/rebuild_project.tcl` - 一键恢复本地 Vivado 工程的 Tcl 脚本

## 一键恢复工程
在 Vivado Tcl Console 中执行：
```tcl
source scripts/rebuild_project.tcl
```

## 使用步骤
1. 执行 `rebuild_project.tcl` 恢复工程
2. 综合、实现、生成比特流
3. 下载到 FPGA 开发板
4. 使用 USB 转 TTL 模块连接 PC 与开发板
5. 打开串口调试工具，打开对应的串口端口
6. 发送任意数据，应收到相同数据（回环）

## 预期结果
- 发送端发送什么字符，接收端就收到什么字符
- 验证 FPGA 与 PC 的 UART 通信链路正常

## 调试笔记
- 确认串口参数：115200 波特率，8 数据位，无校验，1 停止位
- 检查 TX/RX 引脚连接是否正确（注意交叉连接）
- 检查 TTL 模块电平与 FPGA IO 电平是否匹配（通常为 3.3V）
