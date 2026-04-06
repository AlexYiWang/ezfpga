#!/usr/bin/env python3
"""
bit2hex.py - 图片转 RGB565 数据的 Python 脚本
支持 BMP、PNG、JPG 等格式，输出为 Verilog ROM 初始化文件或 C 数组
"""

import sys
import argparse
from PIL import Image
import numpy as np

def rgb888_to_rgb565(r, g, b):
    """将 8 位 RGB 转换为 16 位 RGB565 格式"""
    # 限制范围并移位
    r5 = (r >> 3) & 0x1F
    g6 = (g >> 2) & 0x3F
    b5 = (b >> 3) & 0x1F
    # 组合为 16 位
    return (r5 << 11) | (g6 << 5) | b5

def image_to_rgb565(image_path, output_format='verilog'):
    """转换图片为 RGB565 数据"""
    try:
        img = Image.open(image_path).convert('RGB')
    except Exception as e:
        print(f"无法打开图片: {e}")
        sys.exit(1)

    width, height = img.size
    print(f"图片尺寸: {width} × {height}")

    # 转换为 numpy 数组
    img_array = np.array(img)

    # 转换每个像素
    rgb565_data = []
    for y in range(height):
        row = []
        for x in range(width):
            r, g, b = img_array[y, x]
            rgb565 = rgb888_to_rgb565(r, g, b)
            row.append(rgb565)
        rgb565_data.append(row)

    return width, height, rgb565_data

def generate_verilog_rom(width, height, data, rom_name='IMAGE_ROM'):
    """生成 Verilog ROM 初始化文件"""
    output = []
    output.append(f"// {rom_name} - {width}×{height} RGB565 图像数据")
    output.append(f"// 自动生成，请勿手动修改")
    output.append(f"")
    output.append(f"module {rom_name} (")
    output.append(f"    input wire [{(width*height-1).bit_length()-1}:0] addr,")
    output.append(f"    output reg [15:0] data")
    output.append(f");")
    output.append(f"")
    output.append(f"  always @(*) begin")
    output.append(f"    case (addr)")

    # 展开二维数据为一维地址
    addr = 0
    for y in range(height):
        for x in range(width):
            rgb565 = data[y][x]
            output.append(f"      {addr}'h{addr:04X}: data = 16'h{rgb565:04X}; // ({x}, {y})")
            addr += 1

    output.append(f"      default: data = 16'h0000;")
    output.append(f"    endcase")
    output.append(f"  end")
    output.append(f"")
    output.append(f"endmodule")

    return '\n'.join(output)

def generate_c_array(width, height, data, array_name='image_data'):
    """生成 C 语言数组"""
    output = []
    output.append(f"// {array_name} - {width}×{height} RGB565 图像数据")
    output.append(f"const uint16_t {array_name}[{height}][{width}] = {{")

    for y in range(height):
        row_str = "  {"
        row_data = []
        for x in range(width):
            rgb565 = data[y][x]
            row_data.append(f"0x{rgb565:04X}")
        row_str += ", ".join(row_data)
        row_str += "}" + ("," if y < height - 1 else "")
        output.append(row_str)

    output.append("};")

    return '\n'.join(output)

def main():
    parser = argparse.ArgumentParser(description='转换图片为 RGB565 数据')
    parser.add_argument('input', help='输入图片文件路径')
    parser.add_argument('-o', '--output', help='输出文件路径（默认：stdout）')
    parser.add_argument('-f', '--format', choices=['verilog', 'c', 'raw'],
                       default='verilog', help='输出格式（默认：verilog）')
    parser.add_argument('-n', '--name', default='IMAGE_ROM',
                       help='模块或数组名称（默认：IMAGE_ROM）')
    parser.add_argument('--width', type=int, help='强制输出宽度（缩放图片）')
    parser.add_argument('--height', type=int, help='强制输出高度（缩放图片）')

    args = parser.parse_args()

    # 转换图片
    width, height, data = image_to_rgb565(args.input)

    # 可选缩放
    if args.width or args.height:
        target_width = args.width or width
        target_height = args.height or height
        if target_width != width or target_height != height:
            print(f"警告: 缩放功能未实现，保持原始尺寸 {width}×{height}")

    # 生成输出
    if args.format == 'verilog':
        output_text = generate_verilog_rom(width, height, data, args.name)
    elif args.format == 'c':
        output_text = generate_c_array(width, height, data, args.name)
    else:  # raw
        output_text = f"{width} {height}\n"
        for y in range(height):
            for x in range(width):
                output_text += f"{data[y][x]:04X} "
            output_text += "\n"

    # 输出到文件或标准输出
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(output_text)
        print(f"已生成 {args.output}")
    else:
        print(output_text)

if __name__ == '__main__':
    main()