# 字模提取工具

## 功能说明
本目录用于存放字模提取工具及相关配置，用于生成 ASCII 字符集或其他自定义字符的点阵数据，供 `modules/display/font_engine/` 使用。

## 工具推荐
1. **PCtoLCD2002** - 经典字模提取软件
2. **FontForge** - 开源字体编辑器
3. **自定义 Python 脚本** - 灵活生成任意格式字模

## 文件格式
### Verilog ROM 格式
```
// 8×16 ASCII 字模
module FONT_ROM (
    input wire [10:0] addr,  // ASCII 码 × 16 + 行号
    output reg [7:0] data
);
always @(*) begin
    case (addr)
        11'h000: data = 8'h00; // 空格
        11'h001: data = 8'h00;
        // ...
    endcase
end
endmodule
```

### 二进制/十六进制格式
- 每个字符按行存储
- 每行一个字节（8 像素）
- 字符间空一行（可选）

## 配置示例
### 8×16 ASCII 字体
- 字符尺寸：8 像素宽 × 16 像素高
- 字符集：ASCII 32~126（可打印字符）
- 存储大小：(126-32+1) × 16 = 1520 字节

### 16×16 中文字体
- 字符尺寸：16 像素宽 × 16 像素高
- 字符集：常用汉字
- 存储大小：按需计算

## 使用流程
1. 准备 TrueType 或位图字体文件
2. 使用工具导出字模数据
3. 转换为 Verilog ROM 初始化文件
4. 复制到 `modules/display/font_engine/rtl/` 目录
5. 在项目中实例化字体 ROM 模块

## 注意事项
- 确保字模数据与 `font_engine` 模块的接口匹配
- 考虑存储资源限制（BRAM 使用量）
- 可优化为分段存储（如分页加载）