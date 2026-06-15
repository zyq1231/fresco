import os
import subprocess
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize, differential_evolution
from scipy.interpolate import interp1d

# ================= 配置区域 =================

# FRESCO 可执行文件路径
FRESCO_EXEC = "frescoR.exe"  # 根据实际安装路径修改

# 临时文件名
INPUT_FILE = "fit_run.in"
OUTPUT_FILE = "fit_run.out"
CROSS_SEC_FILE = "fort.16"

# 实验数据 (角度 deg, 比值 sigma/sigma_R, 误差)
# 示例数据：假定的 p + 112Cd @ 27.9 MeV 数据 质心系下数据
EXP_DATA = np.array([
    [13.2, 0.940, 0.18799],
    [19.8, 0.342, 0.0684],
    [26.1, 0.264, 0.0528],
    [32.85, 0.164, 0.0328],
    [35.10, 0.129,0.0258],
    [39.5,0.124,0.0248],
    [41.9,0.126,0.0253],
    [45.8,0.088,0.0177],
    [47.8,0.0711,0.0142],
    [52.1,0.062,0.0124],
    [54.0,0.061,0.0121],
    [58.1,0.059,0.0118],
    [65.7,0.034,0.0068],
    [71.23,0.013,0.00263],
    [77.1,0.0108,0.002157],
])

# 物理常数与设定
BEAM_E = 20  # 入射能量 (MeV) 
MASS_P, CHARGE_P = 6.0, 3.0
MASS_T, CHARGE_T = 19.0, 9.0

# 待拟合参数的初始猜测值
# 参数顺序: [V, r0, a0, W, rw, aw]
# 这里的 V 和 W 是势阱深度，r 和 a 是几何参数
INITIAL_GUESS = [50, 1.16, 0.65, 19.0, 1.293, 0.76]

# 参数边界 (Min, Max) - 防止参数变为负数导致 FRESCO 崩溃
BOUNDS = [
    (20.0, 300.0), # V range
    (1.0, 1.6),   # r0 range
    (0.4, 1),   # a0 range
    (0.0, 50.0),  # W range
    (1.0, 1.6),   # rw range
    (0.4, 1.0)    # aw range
]

# ================= 核心函数 =================

def generate_fresco_input(params):
    """
    根据参数生成 FRESCO 输入文件 (.in)
    params: [V, r0, a0, W, rw, aw]
    """
    V, r0, a0, W, rw, aw = params
    
    # 这里的 namelist 模板可以根据 fresco 文档 [cite: 20-22, 131-144] 修改
    content = f"""Fitting Run
NAMELIST
&FRESCO hcm=0.1 rmatch=20.0 jtmin=0.0 jtmax=60.0 absend=0.01
        thmin=0.0 thmax=180.0 thinc=1.0 chans=1 smats=2 xstabl=1
        elab={BEAM_E} /
&PARTITION namep='p' massp={MASS_P} zp={CHARGE_P} nex=1
           namet='Cd' masst={MASS_T} zt={CHARGE_T} qval=0.0 /
&STATES jp=0.5 ptyp=1 ep=0.0 cpot=1 jt=0.0 ptyt=1 et=0.0 /
&partition /

! Coulomb Potential
&POT kp=1 type=0 p(1:3)= {MASS_T} {MASS_P} 1.25 /

! Nuclear Volume Real (Type 1) -> Fits V, r0, a0
&POT kp=1 type=1 p(1:3)= {V:.4f} {r0:.4f} {a0:.4f} /

! Nuclear Surface Imaginary (Type 2) -> Fits W, rw, aw
! FRESCO Type 2 typically takes parameters in p(4:6) if mixed, 
! or p(1:3) if separate lines. Let's use separate line for clarity.
&POT kp=1 type=2 p(1:3)= {W:.4f} {rw:.4f} {aw:.4f} /

! Spin-Orbit (Fixed for this example)
&POT kp=1 type=3 p(1:3)= 6.0 1.1 0.75 /
&pot /
&overlap /
&coupling /
"""
    with open(INPUT_FILE, 'w') as f:
        f.write(content)

def run_fresco():
    """执行 FRESCO 计算"""
    try:
        with open(INPUT_FILE, 'r') as fin, open(OUTPUT_FILE, 'w') as fout:
            # FRESCO 从标准输入读取 namelist
            subprocess.run([FRESCO_EXEC], stdin=fin, stdout=fout, stderr=subprocess.DEVNULL, check=True)
    except Exception as e:
        print(f"Error running FRESCO: {e}")
        return False
    return True

def read_cross_sections():
    """
    读取 fort.16 文件获取理论计算的截面
    增强版：包含错误处理和列数自动判定
    """
    if not os.path.exists(CROSS_SEC_FILE):
        return None, None
    
    angles = []
    ratios = []
    
    try:
        with open(CROSS_SEC_FILE, 'r') as f:
            lines = f.readlines()
            
        for line in lines:
            parts = line.strip().split()
            
            # 1. 跳过空行或短行
            if not parts or len(parts) < 2:
                continue
                
            # 2. 尝试解析第一列为角度，如果报错说明是表头，跳过
            try:
                theta = float(parts[0])
            except ValueError:
                continue # 这是一行表头或非数字内容

            # 3. 智能读取截面/比值列
            # fort.16 的格式通常是: Theta, Sigma, [Ratio/Other...]
            # 如果有第3列(索引2)，通常是比值或其他观测量；只有2列则读第2列(索引1)
            try:
                if len(parts) >= 3:
                    val = float(parts[2]) # 尝试读取第3列
                else:
                    val = float(parts[1]) # 只有两列，读取第2列
                
                angles.append(theta)
                ratios.append(val)
            except ValueError:
                continue

    except Exception as e:
        print(f"[Warning] Error reading {CROSS_SEC_FILE}: {e}")
        return None, None
                
    return np.array(angles), np.array(ratios)

def objective_function(params):
    """
    损失函数 (Chi-Square)
    """
    # 1. 生成输入
    generate_fresco_input(params)
    
    # 2. 运行 FRESCO
    success = run_fresco()
    if not success:
        # 如果 FRESCO 没跑通，返回一个巨大的惩罚值
        return 1e10 
    
    # 3. 读取理论值
    th_angles, th_vals = read_cross_sections()
    
    # [关键修复] 如果读取失败或没有数据，也返回巨大惩罚值
    if th_angles is None or len(th_angles) == 0:
        return 1e10
    
    # 4. 插值与计算
    try:
        f_interp = interp1d(th_angles, th_vals, kind='cubic', fill_value="extrapolate")
        th_at_exp_angles = f_interp(EXP_DATA[:, 0])
        
        # Chi2 = sum( (Exp - Theo)^2 / Error^2 )
        chi2 = np.sum(((EXP_DATA[:, 1] - th_at_exp_angles) / EXP_DATA[:, 2]) ** 2)
    except Exception as e:
        # 如果插值或计算出错（例如数据点太少），返回惩罚值
        return 1e10
    
    # 打印当前进度（可选）
    # print(f"Chi2: {chi2:.4f} | Params: {np.round(params, 3)}")
    return chi2

# ================= 主程序 =================

if __name__ == "__main__":
    print("--- Starting Optimization with Scipy ---")
    print(f"Initial Guess: {INITIAL_GUESS}")
    
    # 使用 L-BFGS-B 算法 (支持边界约束，速度快，适合平滑函数)
    # result = minimize(
    #     objective_function, 
    #     INITIAL_GUESS, 
    #     method='L-BFGS-B', 
    #     bounds=BOUNDS,
    #     options={'ftol': 1e-4, 'disp': True}
    # )
    
    # 如果 L-BFGS-B 陷入局部最优，可以改用 differential_evolution (全局优化，更慢但更稳)
    #result = differential_evolution(objective_function, bounds=BOUNDS, strategy='best1bin')
    result = differential_evolution(
        objective_function, 
        bounds=BOUNDS,
        strategy='best1bin',
        maxiter=100,
        popsize=20, 
        tol=0.01,
        disp=True  # 打印过程
    )

    print("\n" + "="*40)
    print("Optimization Finished!")
    print(f"Success: {result.success}")
    print(f"Message: {result.message}")
    print(f"Final Chi2: {result.fun:.4f}")
    print("-" * 20)
    print("Optimized Optical Potential Parameters:")
    names = ["V (Real Vol)", "r0", "a0", "W (Surf Imag)", "rw", "aw"]
    for name, val in zip(names, result.x):
        print(f"{name:15s}: {val:.4f}")
    print("="*40)

    # ================= 绘图结果 =================
    # 使用最优参数再跑一次以获取绘图数据
    generate_fresco_input(result.x)
    run_fresco()
    th_angles, th_vals = read_cross_sections()
    
    plt.figure(figsize=(8, 6))
    plt.errorbar(EXP_DATA[:,0], EXP_DATA[:,1], yerr=EXP_DATA[:,2], fmt='ko', label='Experiment')
    plt.plot(th_angles, th_vals, 'r-', linewidth=2, label='Fitted (FRESCO)')
    
    plt.yscale('log') # 截面通常用对数坐标
    plt.xlabel('CM Angle (deg)')
    plt.ylabel(r'Ratio to Rutherford ($\sigma / \sigma_R$)')
    plt.title(f'Optical Model Fit (Chi2={result.fun:.2f})')
    plt.legend()
    plt.grid(True, which="both", ls="-", alpha=0.4)
    plt.savefig('fit_result.png')
    plt.show()