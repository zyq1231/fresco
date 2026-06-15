import matplotlib.pyplot as plt
import numpy as np

# 读取 fort.16 (假设您已将其重命名为 data.txt)
# FRESCO 的 fort.16 头部可能有几行文本，使用 skip_header 跳过
data = np.loadtxt('fort.3', comments=['#', '@', '!']) 

theta = data[:, 0]  # 第一列：角度
sigma = data[:, 1]  # 第二列：截面

plt.plot(theta, sigma, 'r-', label='FRESCO Calculation')
plt.xlabel('Theta (deg)')
plt.ylabel('Cross Section (mb/sr)')
plt.yscale('log') # 核物理截面通常用对数坐标
plt.legend()
plt.show()