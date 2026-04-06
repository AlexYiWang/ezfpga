# LCD 控制器模块（带有请求/响应握手机制）

## 功能描述
高级 LCD 显示控制器，提供基于请求/响应握手的显示命令接口，支持双缓冲显存管理和多种显示操作。

## 特性
- 请求/响应握手机制，确保显示命令的可靠执行
- 双缓冲显存架构，避免画面撕裂
- 支持多种显示操作：清屏、画点、画线、矩形填充、字符显示
- 可配置显示分辨率（最大 240×240）
- 与底层 SPI TFT 驱动无缝集成

## 接口说明
### 控制接口
- `req_valid` - 请求有效
- `req_ready` - 请求就绪
- `req_cmd` - 请求命令码
- `req_param` - 请求参数
- `rsp_valid` - 响应有效
- `rsp_status` - 响应状态

### 显存接口
- `buf_select` - 缓冲选择（0/1）
- `buf_addr` - 显存地址
- `buf_wdata` - 写入数据（RGB565）
- `buf_we` - 写使能
- `buf_rdata` - 读取数据

### 与 SPI 驱动接口
- `spi_start` - 启动 SPI 传输
- `spi_done` - SPI 传输完成
- `spi_data` - 发送数据
- `spi_cmd` - 命令/数据选择

## 命令集
| 命令码 | 名称 | 参数 | 功能 |
|--------|------|------|------|
| 0x01 | CLEAR | color | 清屏为指定颜色 |
| 0x02 | SET_PIXEL | x, y, color | 设置单个像素 |
| 0x03 | DRAW_LINE | x0, y0, x1, y1, color | 画线 |
| 0x04 | FILL_RECT | x, y, w, h, color | 填充矩形 |
| 0x05 | DRAW_CHAR | x, y, char, color | 绘制字符 |
| 0x06 | SWAP_BUFFER | - | 切换显示缓冲 |
| 0x07 | SET_WINDOW | x0, y0, x1, y1 | 设置显示窗口 |

## 工作流程
1. 外部模块发起显示请求（设置 `req_valid` 和 `req_cmd`）
2. 控制器响应 `req_ready` 接受请求
3. 控制器执行显示操作（访问显存、调用 SPI 驱动）
4. 操作完成后发送响应（`rsp_valid` 和 `rsp_status`）

## 目录结构
- `rtl/` - RTL 源码
  - `lcd_controller.sv` - 主控制器
  - `cmd_decoder.sv` - 命令解码器
  - `buf_manager.sv` - 显存管理器
- `tb/` - 测试平台
- `docs/` - 时序图和状态机说明

## 开发状态
- [ ] 基础请求/响应逻辑
- [ ] 显存双缓冲管理
- [ ] 基本绘图命令实现
- [ ] 与 SPI 驱动集成
- [ ] 性能测试与优化