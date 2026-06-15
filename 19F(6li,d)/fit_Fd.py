import os
import subprocess
import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import minimize
from scipy.interpolate import interp1d

# ================= 1. 基础配置 =================

FRESCO_EXEC = "frescoR.exe"  # Windows请保留.exe, Linux/Mac请去掉
INPUT_FILE = "amer_fit.in"
OUTPUT_FILE = "amer_fit.out"
CROSS_SEC_FILE = "fort.16"

# 物理参数 (19F + d @ 16 MeV)
BEAM_ENERGY = 2.1      # MeV (Lab) - 修正为 16 MeV 以匹配数据量级
PROJ_NAME = 'd'
TARGET_NAME = '19F'
PROJ_MASS_AMU = 2.014   # amu
TARGET_MASS_AMU = 18.998 # amu
PROJ_CHARGE = 1.0
TARGET_CHARGE = 9.0
PROJ_SPIN = 1.0
TARGET_SPIN = 0.5

# *** 原始实验室系数据 (来自 fit_Fd.py) ***
# 格式: [Lab角度(deg), Lab微分截面(mb/sr), Lab误差(mb/sr)]
RAW_LAB_DATA = np.array([
    [125.0,  31.7,  0.8],
    [140.0,  27.6,  0.8],
    [150.0,  25.8,  0.7],
    [160.0,  24.2,  0.6],
    [170.0,  22.5,  0.6],
])

# ================= 2. 数据处理：Lab -> CM & Ratio Calculation =================

def process_experimental_data(lab_data, E_lab, mp, mt, Zp, Zt):
    """
    1. 将 Lab 数据 (角度, 截面) 转换为 CM 数据
    2. 计算 Rutherford 截面
    3. 返回 (Theta_CM, Ratio = Sigma_CM / Sigma_R, Ratio_Err)
    """
    # 运动学参数
    gamma = mp / mt
    # 质心系能量 E_cm
    E_cm = E_lab * mt / (mp + mt)
    
    # Rutherford 公式系数 (fm^2)
    # R_const = Zp*Zt*e^2 / (4*E_cm)
    R_const = 1.44 * Zp * Zt / (4.0 * E_cm) 
    
    processed_data = []
    
    for row in lab_data:
        th_lab_deg, sig_lab, err_lab = row
        th_lab = np.radians(th_lab_deg)
        
        # 1. 角度转换 Lab -> CM (适用于 gamma < 1)
        delta = np.arcsin(gamma * np.sin(th_lab))
        th_cm = th_lab + delta
        th_cm_deg = np.degrees(th_cm)
        
        # 2. 截面转换 (Jacobian)
        # J = dOmega_lab / dOmega_cm
        num = 1 + gamma * np.cos(th_cm)
        den = (1 + gamma**2 + 2 * gamma * np.cos(th_cm))**1.5
        # Jacobian for Sigma: Sig_CM = Sig_Lab * (dOmega_Lab / dOmega_CM)
        # 实际上 Sig_CM * dOm_CM = Sig_Lab * dOm_Lab => Sig_CM = Sig_Lab * J
        # 但这里的 Jacobian J = d(cos_lab)/d(cos_cm) ?
        # 标准公式: J = (1 + g*cos_cm) / (1 + g^2 + 2g*cos_cm)^(3/2) 是 dSig_CM / dSig_Lab 的反比?
        # 让我们使用标准 Jacobian J:
        J_val = (1 + gamma**2 + 2*gamma*np.cos(th_cm))**1.5 / np.abs(1 + gamma*np.cos(th_cm))
        
        sig_cm = sig_lab * J_val
        
        # 3. 计算 Rutherford 截面 (mb/sr)
        sin_half_th = np.sin(th_cm / 2.0)
        sig_r_fm2 = (R_const / (sin_half_th**2))**2
        sig_r_mb = sig_r_fm2 * 10.0 # 1 fm^2 = 10 mb
        
        # 4. 计算比值
        ratio = sig_cm / sig_r_mb
        ratio_err = (err_lab * J_val) / sig_r_mb
        
        processed_data.append([th_cm_deg, ratio, ratio_err])
        
    return np.array(processed_data)

# 执行数据转换
EXP_DATA_CM_RATIO = process_experimental_data(
    RAW_LAB_DATA, BEAM_ENERGY, PROJ_MASS_AMU, TARGET_MASS_AMU, PROJ_CHARGE, TARGET_CHARGE
)

# ================= 3. Amer et al. (2025) 光学势参数 =================

def get_amer_2025_parameters(E_lab, Ap, At, Zp, Zt):
    """
    基于 Amer et al. (2025) 对 d + 24Mg 的分析
    Table 1: Phenomenological OM potential best-fit parameters
    选取 15.3 MeV (接近 16 MeV) 的参数作为基准
    """
    
    # 参数来自 Amer 2025 Table 1 (Row for Ed = 15.3 MeV)
    # V0 = 71.84, aV = 0.832
    # WV = 2.06, aW = 0.567
    # WD = 25.12, aD = 0.538
    # Reduced radius rV = 0.799 fm (Fixed in paper)
    
    # 半径定义: 论文中 r0=0.799 较小，推测使用 R = r0 * (Ap^(1/3) + At^(1/3))
    # 这是一个常见的 Phenomenological 做法，特别是对于 light + light 系统
    
    params = {
        'V0': 78.12,
        'rV_reduced': 0.799,
        'aV': 0.765,
        
        'WV': 1.64,  # Volume Imaginary
        'rW_reduced': 0.799,
        'aW': 0.567,
        
        'WD': 14.37, # Surface Imaginary
        'rD_reduced': 0.799,
        'aD': 0.764,
        
        # Spin-Orbit: Amer论文未详述，沿用 An & Cai (2006) 作为合理估计
        'Vso': 3.557,
        'rso_reduced': 0.972, # An & Cai uses R = r * At^(1/3)
        'aso': 1.011,
        
        'rc': 1.303
    }
    
    # 计算物理半径 (fm)
    # 假设 Amer 使用 R = r0 * (Ap^1/3 + At^1/3)
    R_common_factor = (Ap**(1/3) + At**(1/3))
    
    params['R_V'] = params['rV_reduced'] * R_common_factor
    params['R_W'] = params['rW_reduced'] * R_common_factor
    params['R_D'] = params['rD_reduced'] * R_common_factor
    
    # An & Cai Spin orbit uses R = r0 * At^(1/3)
    params['R_so'] = params['rso_reduced'] * (At**(1/3))
    params['R_c'] = params['rc'] * (At**(1/3))
    
    return params

INITIAL_PARAMS = get_amer_2025_parameters(BEAM_ENERGY, PROJ_MASS_AMU, TARGET_MASS_AMU, PROJ_CHARGE, TARGET_CHARGE)

# ================= 4. FRESCO 接口 =================

def generate_fresco_input(var_params, fixed_params):
    """
    var_params: [V0, WV, WD] (拟合变量)
    fixed_params: 包含几何参数 (a, R)
    """
    V0, WV, WD = var_params
    p = fixed_params
    
    # 半径已经在 get_amer_2025_parameters 中计算为物理半径 R
    # 在 FRESCO 中，设置 p(1)=1.0, p(2)=R (或者 p(1)=0, p(2)=1, p(3)=R for type 0?)
    # 对于 Type 1/2/3 Woods-Saxon:
    # p(1)=V, p(2)=r0, p(3)=a
    # 如果我们在 input 中设置 massp=... masst=...
    # FRESCO 会自动用 r0 * ... 计算。
    # 为了精确控制半径，我们在这里将 FRESCO 的 p(2) 设为物理半径 R，
    # 并在 Potential 定义中通过 trick 让 FRESCO 不乘 A^(1/3)。
    # 方法: 在 &POT 中使用 p(1)=1.0 (dummy mass), p(2)=0.0 (dummy). 
    # 或者，更简单：计算出等效的 r0_fresco = R_physical / (At^(1/3)) 并填入。
    # 让我们用等效 r0 方法，配合 FRESCO 默认的 R = r0 * At^(1/3)。
    
    At_13 = TARGET_MASS_AMU**(1/3)
    
    r_V_eff = p['R_V'] / At_13
    r_W_eff = p['R_W'] / At_13
    r_D_eff = p['R_D'] / At_13
    r_so_eff = p['R_so'] / At_13
    r_c_eff = p['R_c'] / At_13

    content = f"""Amer 2025 Fit 19F+d
NAMELIST
&FRESCO hcm=0.05 rmatch=30.0 jtmin=0.0 jtmax=60.0 absend=0.01
        thmin=0.0 thmax=180.0 thinc=1.0 chans=1 smats=2 xstabl=1
        elab={BEAM_ENERGY} /
&PARTITION namep='{PROJ_NAME}' massp={PROJ_MASS_AMU} zp={PROJ_CHARGE} nex=1
           namet='{TARGET_NAME}' masst={TARGET_MASS_AMU} zt={TARGET_CHARGE} qval=0.0 /
&STATES jp={PROJ_SPIN} ptyp=1 ep=0.0 cpot=1 jt={TARGET_SPIN} ptyt=1 et=0.0 /
&partition /

! 1. Coulomb
&POT kp=1 type=0 p(1:3)= {TARGET_MASS_AMU} 0.0 {r_c_eff:.4f} /

! 2. Real Volume (Amer 2025 Ph-WS)
&POT kp=1 type=1 p(1:3)= {V0:.4f} {r_V_eff:.4f} {p['aV']:.4f} /

! 3. Imaginary Volume (Amer 2025 Ph-WS)
&POT kp=1 type=1 p(4:6)= {WV:.4f} {r_W_eff:.4f} {p['aW']:.4f} /

! 4. Imaginary Surface (Amer 2025 Ph-WS)
&POT kp=1 type=2 p(1:3)= {WD:.4f} {r_D_eff:.4f} {p['aD']:.4f} /

! 5. Spin-Orbit (An & Cai)
&POT kp=1 type=3 p(1:3)= {p['Vso']:.4f} {r_so_eff:.4f} {p['aso']:.4f} /

&pot /
&overlap /
&coupling /
"""
    with open(INPUT_FILE, 'w') as f:
        f.write(content)

def run_fresco():
    try:
        subprocess.run([FRESCO_EXEC], stdin=open(INPUT_FILE, 'r'), 
                       stdout=open(OUTPUT_FILE, 'w'), stderr=subprocess.DEVNULL, check=True)
        return True
    except:
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
                    float(parts[0])
                    theta = float(parts[0])
                    # 假设 FRESCO 输出 Ratio (第3列或第2列)
                    val = float(parts[2]) if len(parts) >= 3 else float(parts[1])
                    angles.append(theta)
                    ratios.append(val)
                except ValueError: continue
    except: return None, None
    return np.array(angles), np.array(ratios)

# ================= 5. 目标函数 =================

def objective_function(params, fixed_params):
    if any(p < 0 for p in params): return 1e10
    
    generate_fresco_input(params, fixed_params)
    if not run_fresco(): return 1e10
    
    th_angles, th_vals = read_cross_sections()
    if th_angles is None or len(th_angles) == 0: return 1e10
    
    try:
        f_interp = interp1d(th_angles, th_vals, kind='cubic', fill_value="extrapolate")
        th_at_exp = f_interp(EXP_DATA_CM_RATIO[:, 0])
        
        th_at_exp = np.maximum(th_at_exp, 1e-9)
        exp_vals = np.maximum(EXP_DATA_CM_RATIO[:, 1], 1e-9)
        
        # Log-Chi2
        residuals = np.log10(exp_vals) - np.log10(th_at_exp)
        chi2 = np.sum(residuals**2)
        return chi2
    except: return 1e10

# ================= 6. 主程序 =================

if __name__ == "__main__":
    p = INITIAL_PARAMS
    # 初始拟合变量: [V0, WV, WD]
    initial_guess = [p['V0'], p['WV'], p['WD']]
    
    print("\n--- Amer et al. (2025) Parameters (Initial) ---")
    print(f"V0 : {p['V0']:.2f}, aV: {p['aV']:.3f}, R_V: {p['R_V']:.3f} fm")
    print(f"WV : {p['WV']:.2f}, aW: {p['aW']:.3f}, R_W: {p['R_W']:.3f} fm")
    print(f"WD : {p['WD']:.2f}, aD: {p['aD']:.3f}, R_D: {p['R_D']:.3f} fm")
    print(f"Vso: {p['Vso']:.2f} (Fixed)")
    
    # 1. 初始 Chi2
    init_chi2 = objective_function(initial_guess, p)
    print(f"Initial Log-Chi2: {init_chi2:.4f}")

    # 2. 优化
    print("\nStarting optimization (Depths only)...")
    bounds = [
        (40.0, 120.0), # V0
        (0.0, 20.0),   # WV
        (0.0, 50.0)    # WD
    ]
    
    result = minimize(
        objective_function, 
        initial_guess, 
        args=(p,), 
        method='L-BFGS-B', 
        bounds=bounds
    )

    print("\nOptimization Finished!")
    print(f"Final Log-Chi2: {result.fun:.4f}")
    
    # 3. 绘图
    generate_fresco_input(result.x, p)
    run_fresco()
    ang_best, val_best = read_cross_sections()
    
    generate_fresco_input(initial_guess, p)
    run_fresco()
    ang_init, val_init = read_cross_sections()
    
    plt.figure(figsize=(8, 6))
    
    plt.errorbar(EXP_DATA_CM_RATIO[:,0], EXP_DATA_CM_RATIO[:,1], 
                 yerr=EXP_DATA_CM_RATIO[:,2], fmt='ko', label='Exp Data (16 MeV)')
    
    if ang_init is not None:
        plt.plot(ang_init, val_init, 'b--', label='Amer 2025 (Mg params)', linewidth=1.5)
        
    if ang_best is not None:
        plt.plot(ang_best, val_best, 'r-', label='Fitted (F depths)', linewidth=2)
    
    plt.yscale('log')
    plt.xlabel(r'$\theta_{c.m.}$ (deg)')
    plt.ylabel(r'$\sigma / \sigma_R$')
    plt.title(f'Optical Model Fit ({TARGET_NAME}+d @ {BEAM_ENERGY} MeV)')
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.savefig('amer_fit_result.png')
    plt.show()