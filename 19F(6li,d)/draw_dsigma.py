import matplotlib.pyplot as plt
import numpy as np
import os

filename = 'fort.16'
print(f"正在寻找并读取 {filename} ...")

if not os.path.exists(filename):
    print(f"错误：找不到文件 {filename}，请确保它与本脚本在同一目录下！")
else:
    angles = []
    cross_sections = []
    zero_count = 0  # 记录截面为0的点数

    with open(filename, 'r') as file:
        for line in file:
            if not line.strip():
                continue
            
            parts = line.split()
            
            try:
                # 尝试解析前两列为浮点数
                angle = float(parts[0])
                xsec = float(parts[1])
                
                # 过滤截面数据
                if xsec > 0:
                    angles.append(angle)
                    cross_sections.append(xsec)
                else:
                    zero_count += 1
            except ValueError:
                # 遇到表头文字跳过
                continue

    print("-" * 30)
    print("读取完毕！分析结果如下：")
    print(f"-> 找到大于0的有效数据点：{len(angles)} 个")
    print(f"-> 截面为0的无效数据点：{zero_count} 个")
    print("-" * 30)

    if len(angles) == 0:
        print("【警告】没有可绘制的有效数据点！")
        print("原因可能是：\n 1. FRESCO 算出的截面仍然全为 0。\n 2. fort.16 的格式不对（比如数据在第3列）。\n建议用记事本打开 fort.16 文件亲自看一眼里面的内容！")
    else:
        angles = np.array(angles)
        cross_sections = np.array(cross_sections)

        plt.figure(figsize=(8, 6), dpi=120)
        plt.plot(angles, cross_sections, marker='o', markersize=4, linestyle='-', color='#1f77b4', linewidth=1.5, label='FRESCO DWBA')

        plt.yscale('log')
        plt.xlabel('Center of Mass Angle θ (degrees)', fontsize=14, fontweight='bold')
        plt.ylabel('dσ/dΩ (mb/sr)', fontsize=14, fontweight='bold')
        plt.title('Transfer Reaction Angular Distribution', fontsize=16, pad=15)
        
        if len(angles) > 0:
            plt.xlim(0, max(angles) + 5)
        
        plt.grid(True, which="major", linestyle='-', alpha=0.6)
        plt.grid(True, which="minor", linestyle='--', alpha=0.3)
        plt.legend(fontsize=12, frameon=True, shadow=True)
        plt.tight_layout()
        
        # 【关键新增】：强制把图片保存到本地
        save_name = "angular_distribution.png"
        plt.savefig(save_name, dpi=300)
        print(f"【成功】图表已保存为当前目录下的高清图片文件：{save_name}")
        
        print("正在尝试弹出绘图窗口...")
        try:
            plt.show()
        except Exception as e:
            print(f"弹窗失败，但图片已保存！(错误信息: {e})")