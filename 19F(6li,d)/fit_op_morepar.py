import os
import subprocess
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize
from scipy.interpolate import interp1d

# ================= 1. 基础配置 =================

FRESCO_EXEC = "frescoR.exe"  # Windows系统
INPUT_FILE = "xu_fit.in"
OUTPUT_FILE = "xu_fit.out"
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

# *** 请在此处填入你的真实实验数据 ***
# 格式: [角度(CM), Sigma/Sigma_R, 误差]
# 如果没有误差，建议设为数值的 10%
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

# ================= 2. Xu et al. (2018) 全局参数计算 =================

def get_xu_global_params(E_lab):
    """
    根据 Xu et al. Phys. Rev. C 98, 024619 (2018) 计算初始参数
    公式 (6-8) 和 Table III
    """
    # 深度 (Depths)
    V_r = 265.736 - 0.183 * E_lab
    W_s = max(0.0, 28.850 - 0.0989 * E_lab)
    W_v = max(0.0, -5.226 + 0.118 * E_lab + 0.000379 * (E_lab**2))
    
    # 几何参数 (Geometry)
    # 半径定义 R = r * At^(1/3)
    geom = {
        'r_r': 1.120, 'a_r': 0.814,
        'r_s': 1.311, 'a_s': 0.939,
        'r_v': 1.537, 'a_v': 0.726,
        'r_c': 1.674
    }
    return V_r, W_s, W_v, geom

# ================= 3. FRESCO 接口 =================

def generate_fresco_input(params, fixed_geom):
    """
    生成输入文件
    params: [V_r, W_s, W_v] (拟合变量)
    fixed_geom: 几何参数 (固定)
    """
    V_r, W_s, W_v = params
    g = fixed_geom
    
    # 这里的关键是 p(1)=TARGET_MASS, p(2)=0
    # 这样 FRESCO 计算半径时公式变为 R = r0 * (At^(1/3) + 0) = r0 * At^(1/3)
    # 这符合 Xu et al. (2018) Eq.12 的定义
    
    content = f"""Xu 2018 Global Fit
NAMELIST
&FRESCO hcm=0.05 rmatch=30.0 jtmin=0.0 jtmax=60.0 absend=0.01
        thmin=0.0 thmax=180.0 thinc=1.0 chans=1 smats=2 xstabl=1
        elab={BEAM_ENERGY} /
&PARTITION namep='{PROJ_NAME}' massp={PROJ_MASS} zp={PROJ_CHARGE} nex=1
           namet='{TARGET_NAME}' masst={TARGET_MASS} zt={TARGET_CHARGE} qval=0.0 /
&STATES jp={PROJ_SPIN} ptyp=1 ep=0.0 cpot=1 jt={TARGET_SPIN} ptyt=1 et=0.0 /
&partition /

! Potential 1: Elastic Optical Potential
! 1. Coulomb (Type 0)
&POT kp=1 type=0 p(1:3)= {TARGET_MASS} 0.0 {g['r_c']} /

! 2. Real Volume (Type 1) + Imaginary Volume (Type 1 p4-6)
&POT kp=1 type=1 p(1:6)= {V_r:.4f} {g['r_r']} {g['a_r']} {W_v:.4f} {g['r_v']} {g['a_v']} /

! 3. Imaginary Surface (Type 2)
&POT kp=1 type=2 p(1:3)= {W_s:.4f} {g['r_s']} {g['a_s']} /

&pot /
&overlap /
&coupling /
"""
    with open(INPUT_FILE, 'w') as f:
        f.write(content)

def run_fresco():
    try:
        # 运行 FRESCO 并等待完成
        subprocess.run([FRESCO_EXEC], stdin=open(INPUT_FILE, 'r'), 
                       stdout=open(OUTPUT_FILE, 'w'), stderr=subprocess.DEVNULL, check=True)
        return True
    except Exception as e:
        return False

def read_cross_sections():
    if not os.path.exists(CROSS_SEC_FILE): return None, None
    angles, ratios = [], []
    try:
        with open(CROSS_SEC_FILE, 'r') as f:
            for line in f:
                parts = line.strip().split()
                if not parts or len(parts) < 2: continue
                try:
                    # 过滤表头
                    float(parts[0])
                    theta = float(parts[0])
                    # fort.16通常格式: Theta, Sigma, Ratio
                    # 我们需要 Ratio (通常是第3列，即索引2；若无则取第2列)
                    val = float(parts[2]) if len(parts) >= 3 else float(parts[1])
                    angles.append(theta)
                    ratios.append(val)
                except ValueError: continue
    except: return None, None
    return np.array(angles), np.array(ratios)

# ================= 4. 目标函数 (对数卡方) =================

def objective_function(params, fixed_geom):
    # 物理约束：深度不能为负
    if any(p < 0 for p in params): return 1e10
    
    # 1. 生成输入并运行
    generate_fresco_input(params, fixed_geom)
    if not run_fresco(): return 1e10
    
    # 2. 读取理论值
    th_angles, th_vals = read_cross_sections()
    if th_angles is None or len(th_angles) == 0: return 1e10
    
    # 3. 插值并计算 Log-Chi2
    try:
        f_interp = interp1d(th_angles, th_vals, kind='cubic', fill_value="extrapolate")
        th_at_exp = f_interp(EXP_DATA[:, 0])
        
        # 防止 log(0)
        th_at_exp = np.maximum(th_at_exp, 1e-9)
        exp_vals = np.maximum(EXP_DATA[:, 1], 1e-9)
        
        # 使用对数差的平方和 (Log-Chi2)
        # 这能让优化器“看到”后角数量级较小的数据点的差异
        residuals = np.log10(exp_vals) - np.log10(th_at_exp)
        chi2 = np.sum(residuals**2)
        
        return chi2
    except: return 1e10

# ================= 5. 主程序 =================

if __name__ == "__main__":
    # 获取 Xu 2018 初始参数
    V_r_0, W_s_0, W_v_0, geom = get_xu_global_params(BEAM_ENERGY)
    
    # 如果 Xu 公式算出 W_v 为 0，给它一个小的初始值让优化器可以动
    if W_v_0 < 0.1: W_v_0 = 1.0 
    
    initial_guess = [V_r_0, W_s_0, W_v_0]
    
    print("\n--- Xu et al. (2018) Global Parameters (Initial) ---")
    print(f"V_r: {V_r_0:.2f} MeV")
    print(f"W_s: {W_s_0:.2f} MeV")
    print(f"W_v: {W_v_0:.2f} MeV")
    print(f"Radii: rR={geom['r_r']}, rS={geom['r_s']}, rV={geom['r_v']}")
    print("----------------------------------------------------")

    # 1. 计算初始状态的 Chi2
    init_chi2 = objective_function(initial_guess, geom)
    print(f"Initial Log-Chi2 (Before Fit): {init_chi2:.4f}")

    # 2. 运行优化 (只调整深度 V_r, W_s, W_v)
    print("\nStarting optimization (L-BFGS-B)...")
    # 设置边界：允许深度在初始值附近大幅波动 (例如 0 到 2倍)
    bounds = [
        (V_r_0 * 0.5, V_r_0 * 1.5),  # V_r
        (0.0, 50.0),                 # W_s
        (0.0, 50.0)                  # W_v
    ]
    
    result = minimize(
        objective_function, 
        initial_guess, 
        args=(geom,), 
        method='L-BFGS-B', 
        bounds=bounds,
        options={'disp': True, 'eps': 0.1} # eps=0.1 增大步长，防止因梯度太小而不动
    )

    print("\n" + "="*40)
    print(f"Optimization Finished!")
    print(f"Final Log-Chi2: {result.fun:.4f}")
    print("-" * 20)
    print(f"{'Parameter':<10} {'Initial':<10} {'Fitted':<10}")
    print(f"{'V_r':<10} {initial_guess[0]:<10.2f} {result.x[0]:<10.2f}")
    print(f"{'W_s':<10} {initial_guess[1]:<10.2f} {result.x[1]:<10.2f}")
    print(f"{'W_v':<10} {initial_guess[2]:<10.2f} {result.x[2]:<10.2f}")
    print("="*40)

    # 3. 绘图对比
    # 获取初始曲线
    generate_fresco_input(initial_guess, geom)
    run_fresco()
    ang_init, val_init = read_cross_sections()
    
    # 获取最佳拟合曲线
    generate_fresco_input(result.x, geom)
    run_fresco()
    ang_best, val_best = read_cross_sections()
    
    plt.figure(figsize=(8, 6))
    # 实验数据
    plt.errorbar(EXP_DATA[:,0], EXP_DATA[:,1], yerr=EXP_DATA[:,2], fmt='ko', label='Experiment')
    
    # 全局势预测 (蓝色虚线)
    if ang_init is not None:
        plt.plot(ang_init, val_init, 'b--', label='Xu (2018) Global', linewidth=1.5)
        
    # 拟合后曲线 (红色实线)
    if ang_best is not None:
        plt.plot(ang_best, val_best, 'r-', label='Fitted (Adjusted Depths)', linewidth=2)
        
    plt.yscale('log')
    plt.xlabel(r'$\theta_{c.m.}$ (deg)')
    plt.ylabel(r'$\sigma / \sigma_R$')
    plt.title(f'Optical Model Fit ({PROJ_NAME}+{TARGET_NAME} @ {BEAM_ENERGY} MeV)')
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig('xu_fit_plot.png')
    plt.show()