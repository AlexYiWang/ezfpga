# 同步/异步 FIFO 封装

## 功能描述
提供参数化的同步和异步 FIFO（先进先出）存储器模块，用于数据缓冲和时钟域交叉。

## 特性
- 支持同步 FIFO（单时钟域）和异步 FIFO（双时钟域）
- 完全参数化：数据宽度、深度、满/空阈值可配置
- 多种实现方式：基于寄存器、分布式 RAM、块 RAM
- 精确的状态标志：空、满、几乎空、几乎满
- 低延迟设计：读写操作单周期完成
- 错误检测：上溢、下溢保护

## 接口说明
### 通用接口（同步/异步）
- `wr_clk` - 写时钟（异步 FIFO 时）
- `rd_clk` - 读时钟（异步 FIFO 时）
- `rst_n` - 复位（低有效，异步复位）
- `wr_en` - 写使能
- `wr_data` - 写入数据（WIDTH 位）
- `rd_en` - 读使能
- `rd_data` - 读取数据（WIDTH 位）
- `full` - FIFO 满标志
- `empty` - FIFO 空标志
- `almost_full` - 几乎满标志（可配置阈值）
- `almost_empty` - 几乎空标志（可配置阈值）
- `wr_count` - 写侧数据计数（可选）
- `rd_count` - 读侧数据计数（可选）

## 参数配置
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `WIDTH` | integer | 8 | 数据位宽（1-1024） |
| `DEPTH` | integer | 16 | FIFO 深度（2 的幂次） |
| `RAM_STYLE` | string | "block" | 存储类型："reg"、"distributed"、"block" |
| `SYNC_STAGES` | integer | 2 | 异步 FIFO 同步器级数 |
| `ALMOST_FULL_THRESH` | integer | DEPTH-2 | 几乎满阈值 |
| `ALMOST_EMPTY_THRESH` | integer | 2 | 几乎空阈值 |
| `SHOW_AHEAD` | integer | 1 | 输出模式：0=标准，1=预读 |

## 同步 FIFO 架构
- 单时钟域操作
- 简单的读写指针管理
- 适合数据速率匹配

## 异步 FIFO 架构
- 双时钟域，格雷码指针同步
- 同步器链避免亚稳态
- 适合跨时钟域数据传输

## 性能指标
- 最大频率：取决于实现方式和器件
- 资源使用：与深度和宽度成正比
- 延迟：读写操作均为单周期（预读模式）

## 使用示例
```verilog
// 同步 FIFO 实例化
fifo_sync #(
    .WIDTH(32),
    .DEPTH(64),
    .RAM_STYLE("block")
) u_fifo_sync (
    .clk(sys_clk),
    .rst_n(sys_rst_n),
    .wr_en(wr_valid),
    .wr_data(wr_data),
    .rd_en(rd_ready),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
);

// 异步 FIFO 实例化
fifo_async #(
    .WIDTH(16),
    .DEPTH(256),
    .SYNC_STAGES(3)
) u_fifo_async (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .rst_n(rst_n),
    // ... 其他信号
);
```

## 目录结构
- `rtl/` - RTL 源码
  - `fifo_sync.sv` - 同步 FIFO
  - `fifo_async.sv` - 异步 FIFO
  - `fifo_core.sv` - FIFO 核心逻辑
  - `gray_code.sv` - 格雷码转换器
- `tb/` - 测试平台
- `docs/` - 时序图和资源使用报告

## 开发状态
- [ ] 同步 FIFO 实现
- [ ] 异步 FIFO 实现
- [ ] 参数化验证
- [ ] 性能测试与优化
- [ ] 综合约束与资源评估