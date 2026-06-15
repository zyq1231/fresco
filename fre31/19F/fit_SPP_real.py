import os
import subprocess
import numpy as np
import matplotlib.pyplot as plt  # [新增] 引入绘图库
from scipy.optimize import differential_evolution
from scipy.interpolate import interp1d

# ================= 配置区域 =================

# FRESCO 可执行文件路径 (请根据实际情况修改)
FRESCO_EXEC = "frescoR.exe"  
INPUT_FILE = "fit_real_pot.in"
OUTPUT_FILE = "fit_real_pot.out"
CROSS_SEC_FILE = "fort.16"

# 物理参数 (19F + 6Li @ 20 MeV)
BEAM_ENERGY = 20.0      # MeV (Lab)
PROJ_NAME = '6Li'
TARGET_NAME = '19F'
PROJ_MASS = 6.015
TARGET_MASS = 18.998
PROJ_CHARGE = 3.0
TARGET_CHARGE = 9.0
PROJ_SPIN = 1.0
TARGET_SPIN = 0.5

# 实验数据 (示例数据，请务必替换为您真实的实验数据)
# 格式: [角度(CM), sigma/sigma_R, 误差]
EXP_DATA = np.array([
    [13.2, 0.940, 0.18799],
    [19.8, 0.342, 0.0684],
    [26.1, 0.264, 0.0528],
    [32.85, 0.164, 0.0328],
    [35.1, 0.142, 0.0284],
    [39.6, 0.084, 0.0168],
    [46.35, 0.063, 0.0126],
    [53.1, 0.032, 0.0064],
    [59.4, 0.032, 0.0064],
    [66.15, 0.012, 0.0024]
])

# ================= 固定参数 (基于 Zamora et al. 2022 Table I) =================

W_VOL_FIXED = 19.0     # 虚部深度
RW_FIXED    = 1.230    # 虚部半径
AW_FIXED    = 0.97     # 虚部弥散

VSO_FIXED   = 2.00     # 自旋轨道深度
RSO_FIXED   = 1.16     # 自旋轨道半径
ASO_FIXED   = 0.65     # 自旋轨道弥散

RC_FIXED    = 1.30     # 库仑半径

# ================= 拟合变量 (实部势 Real Potential) =================

# 拟合参数范围: [V_real, r_real, a_real]
BOUNDS = [
    (40.0, 200.0),  # V_real (实部深度)
    (1.00, 1.50),   # r_real (实部半径)
    (0.50, 0.90)    # a_real (实部弥散)
]

# ================= 核心函数 =================

def generate_fresco_input(params):
    """生成 FRESCO 输入文件"""
    V_real, r_real, a_real = params
    
    # 采用单行写法以避免 namelist 读取错误
    content = f"""Fit Real Potential
NAMELIST
&FRESCO hcm=0.05 rmatch=30.0 jtmin=0.0 jtmax=60.0 absend=0.01
        thmin=0.0 thmax=180.0 thinc=1.0 chans=1 smats=2 xstabl=1
        elab={BEAM_ENERGY} /
&PARTITION namep='{PROJ_NAME}' massp={PROJ_MASS} zp={PROJ_CHARGE} nex=1
           namet='{TARGET_NAME}' masst={TARGET_MASS} zt={TARGET_CHARGE} qval=0.0 /
&STATES jp={PROJ_SPIN} ptyp=1 ep=0.0 cpot=1 jt={TARGET_SPIN} ptyt=1 et=0.0 /
&partition /

! Potential 1
&POT kp=1 type=0 p(1:3)= {TARGET_MASS} {PROJ_MASS} {RC_FIXED} /
&POT kp=1 type=1 p(1:6)= {V_real:.4f} {r_real:.4f} {a_real:.4f} {W_VOL_FIXED} {RW_FIXED} {AW_FIXED} /
&POT kp=1 type=3 p(1:3)= {VSO_FIXED} {RSO_FIXED} {ASO_FIXED} /

&pot /
&overlap /
&coupling /
"""
    with open(INPUT_FILE, 'w') as f:
        f.write(content)

def run_fresco():
    """运行 FRESCO"""
    if not os.path.exists(FRESCO_EXEC):
        return False
    try:
        result = subprocess.run([FRESCO_EXEC], stdin=open(INPUT_FILE, 'r'), 
                              stdout=open(OUTPUT_FILE, 'w'), stderr=subprocess.PIPE)
        return result.returncode == 0
    except Exception:
        return False

def read_cross_sections():
    """读取 fort.16 输出文件"""
    if not os.path.exists(CROSS_SEC_FILE): return None, None
    angles, ratios = [], []
    try:
        with open(CROSS_SEC_FILE, 'r') as f:
            lines = f.readlines()
            for line in lines:
                parts = line.strip().split()
                if not parts or len(parts) < 2: continue
                try:
                    # 过滤表头
                    float(parts[0])
                except ValueError: continue
                
                try:
                    theta = float(parts[0])
                    # 尝试读取第3列(Ratio)，如果不存在则读取第2列
                    val = float(parts[2]) if len(parts) >= 3 else float(parts[1])
                    angles.append(theta)
                    ratios.append(val)
                except ValueError: continue
    except Exception: return None, None
    return np.array(angles), np.array(ratios)

def objective_function(params):
    """目标函数 (Chi2)"""
    # 物理约束检查
    if any(p < 0 for p in params): return 1e10

    generate_fresco_input(params)
    
    if not run_fresco(): return 1e10
    
    th_angles, th_vals = read_cross_sections()
    if th_angles is None or len(th_angles) == 0: return 1e10
    
    try:
        f_interp = interp1d(th_angles, th_vals, kind='cubic', fill_value="extrapolate")
        th_at_exp = f_interp(EXP_DATA[:, 0])
        # 使用对数 Chi2 以平衡后角数据的权重
        chi2 = np.sum(((np.log(EXP_DATA[:, 1]) - np.log(th_at_exp))**2))
        return chi2
    except: return 1e10

# ================= 主程序 =================

if __name__ == "__main__":
    print("\n--- Starting Real Potential Fitting (Imaginary Fixed) ---")
    print(f"Fixed Imaginary (Vol): W={W_VOL_FIXED}, r={RW_FIXED}, a={AW_FIXED}")
    print(f"Fixed Spin-Orbit     : V={VSO_FIXED}, r={RSO_FIXED}, a={ASO_FIXED}")
    
    # 1. 执行拟合
    result = differential_evolution(
        objective_function, 
        bounds=BOUNDS,
        strategy='best1bin', 
        popsize=15,
        tol=0.01,
        disp=True
    )

    print("\n" + "="*40)
    print(f"Fit Finished! Final Chi2: {result.fun:.4f}")
    print("-" * 20)
    print("Optimized Real Potential Parameters:")
    print(f"  V (Depth) : {result.x[0]:.4f} MeV")
    print(f"  r0 (Rad)  : {result.x[1]:.4f} fm")
    print(f"  a0 (Diff) : {result.x[2]:.4f} fm")
    print("="*40)
    
    # ================= [新增] 绘图模块 =================
    print("\nGenerating final plot...")
    
    # 1. 使用最优参数重新生成输入文件并运行
    generate_fresco_input(result.x)
    run_fresco()
    
    # 2. 读取理论曲线数据
    th_angles, th_vals = read_cross_sections()
    
    if th_angles is not None and len(th_angles) > 0:
        # 3. 设置绘图风格
        plt.figure(figsize=(10, 7))
        plt.rcParams.update({'font.size': 12}) # 调整字体大小
        
        # 4. 绘制实验数据点 (带误差棒)
        # yerr是误差列，fmt='ko'表示黑色圆点
        plt.errorbar(EXP_DATA[:,0], EXP_DATA[:,1], yerr=EXP_DATA[:,2], 
                     fmt='ko', capsize=3, label='Experiment Data', zorder=5)
        
        # 5. 绘制拟合理论曲线
        # 'r-' 表示红色实线
        plt.plot(th_angles, th_vals, 'r-', linewidth=2, label=f'Best Fit (V={result.x[0]:.1f})')
        
        # 6. 图表设置
        plt.yscale('log')  # 对数纵坐标 (核物理截面图标准)
        plt.xlabel(r'$\theta_{c.m.}$ (deg)', fontsize=14)
        plt.ylabel(r'$\sigma / \sigma_{R}$', fontsize=14)
        plt.title(f'Optical Model Fit: {PROJ_NAME} + {TARGET_NAME} @ {BEAM_ENERGY} MeV', fontsize=16)
        plt.legend(loc='upper right')
        plt.grid(True, which="both", linestyle='--', alpha=0.5)
        
        # 限制显示范围 (可选)
        plt.xlim(0, 180)
        
        # 7. 保存并显示
        plot_filename = "fit_result_plot.png"
        plt.savefig(plot_filename, dpi=300)
        print(f"Plot saved to '{plot_filename}'")
        plt.show()
    else:
        print("[Error] Could not read theoretical data for plotting.")