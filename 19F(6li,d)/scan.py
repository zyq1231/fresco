import os
import shutil
import re
import time

# ================= 配置区域 =================
FRESCO_CMD = "fresco.exe"      # FRESCO 程序名
START_DEPTH = 70.0             # 扫描起始深度
END_DEPTH = 82.0               # 扫描结束深度
STEP = 0.5                     # 步长

# 文件名配置
TEMPLATE_FILE = "template.in"
INPUT_FILE = "19F_scan.in"
OUTPUT_FILE = "19F_scan.out"
CMD_FILE = "run.txt"           # 存放文件名的引导文件
# ===========================================

# 自动生成模板（如果不存在）
DEFAULT_TEMPLATE = """19F(6Li,d)23Na at 16 MeV (Auto Scan)
NAMELIST
 &FRESCO hcm=0.1 rmatch=30.0 rintp=0.1 hnl=0.1 rnl=18.0 centre=0.00
  jtmin=0.0 jtmax=40.0 absend=-1.0 cutl=-2 thmin=0.0 thmax=80.0 thinc=0.1
  ips=0.001 iter=1 iblock=8 nnu=24 epc=0.00 xstabl=1 elab=16.0 /
 &PARTITION namep='6Li' massp=6.0151 zp=3 nex=-1 pwf=T namet='19F' masst=18.998 zt=9 qval=0.0 /
 &STATES jp=1.0 ptyp=1 ep=0.0 cpot=1 jt=0.5 ptyt=1 et=0.0 /
 &PARTITION namep='d' massp=2.0141 zp=1 nex=-1 pwf=T namet='23Na' masst=22.989 zt=11 qval=8.993 /
 &STATES jp=1.0 ptyp=1 ep=0.0 cpot=2 jt=1.5 ptyt=1 et=0 /
 &partition /
 &pot kp=1 type=0 p(1)=1.30 /
 &pot kp=1 type=1 p(1:3)=265.8 1.0002 0.6924 /
 &pot kp=1 type=2 p(1:3)=19.0 1.23 0.97 /
 &pot kp=1 type=3 p(1:3)=2.0 1.16 0.65 /
 &pot kp=2 type=0 p(1)=1.30 /
 &pot kp=2 type=1 p(1:3)=89.75 1.15 0.76 p(4:6)=1.34 1.34 0.57 /
 &pot kp=2 type=2 p(4:6)=10.51 1.34 0.57 /
 &pot kp=2 type=3 p(1:3)=3.56 0.97 1.01 /
 
! KP=3: 6Li -> d + alpha (扫描目标)
 &pot kp=3 type=0 p(1)=1.25 /
 &pot kp=3 type=1 p(1:3)={DEPTH} 1.25 0.65 /

! KP=4: 23Na -> 19F + alpha
 &pot kp=4 type=0 p(1)=1.30 /
 &pot kp=4 type=1 p(1:3)=130.0 1.30 0.70 /
 &pot /
 &overlap kn1=1 kn2=0 ic1=1 ic2=2 in=1 kind=0 nn=2 l=0 sn=1.0 j=0.0 kbpot=3 be=1.474 /
 &overlap kn1=2 kn2=0 ic1=2 ic2=1 in=1 kind=0 nn=4 l=2 sn=1.0 j=2.0 kbpot=4 be=10.467 /
 &overlap /
 &COUPLING icto=2 icfrom=1 kind=7 ip1=1 ip2=2 ip3=3 /
 &cfp in=1 kn=1 a=1.0 /
 &cfp in=1 kn=2 a=1.0 /
 &COUPLING /
"""

def create_template_if_missing():
    if not os.path.exists(TEMPLATE_FILE):
        with open(TEMPLATE_FILE, "w", encoding="utf-8") as f:
            f.write(DEFAULT_TEMPLATE)
def get_discrepancy(output_file):
    if not os.path.exists(output_file): return None
    try:
        with open(output_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            match = re.search(r"DISCREPANCY\s*=\s*([-\d\.E\+]+)", content)
            if match: return float(match.group(1))
    except: pass
    return None

def run_fresco_redirection():
    """
    使用 CMD 输入重定向: fresco.exe < run.txt > 19F_scan.out
    """
    # 1. 创建引导文件 (只包含输入文件名)
    with open(CMD_FILE, "w") as f:
        f.write(f"{INPUT_FILE}\n")
    
    # 2. 构造 CMD 命令
    # 注意: Windows 下 os.system 直接调用 cmd，支持 < 和 > 重定向
    cmd = f'{FRESCO_CMD} < {INPUT_FILE} > {OUTPUT_FILE}'
    
    # 3. 执行
    ret = os.system(cmd)
    
    # 稍微等待文件写入
    time.sleep(0.1) 
    return ret

def main():
    if not os.path.exists(FRESCO_CMD) and shutil.which(FRESCO_CMD) is None:
        print(f"❌ 错误: 找不到 {FRESCO_CMD}")
        return

    create_template_if_missing()
    
    print(f"=== 🚀 FRESCO 重定向扫描模式 ({START_DEPTH} - {END_DEPTH} MeV) ===")
    print(f"{'深度(MeV)':<10} | {'偏差值 (Discrepancy)':<25} | {'状态'}")
    print("-" * 55)

    history = [] 
    
    # 生成深度列表
    depths = []
    d = START_DEPTH
    while d <= END_DEPTH + 0.001:
        depths.append(d)
        d += STEP

    for depth_val in depths:
        # 1. 生成输入文件
        with open(TEMPLATE_FILE, 'r', encoding='utf-8') as f:
            tmpl = f.read()
        with open(INPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(tmpl.replace("{DEPTH}", f"{depth_val:.2f}"))
            
        # 2. 清理旧输出
        if os.path.exists(OUTPUT_FILE):
            os.remove(OUTPUT_FILE)

        # 3. 运行
        run_fresco_redirection()
        
        # 4. 读取结果
        disc = get_discrepancy(OUTPUT_FILE)
        
        # 状态判断
        status = "⚠️ 失败"
        # 检查是否生成了截面表 (成功标志)
        is_success = False
        try:
            with open(OUTPUT_FILE, 'r', encoding='utf-8', errors='ignore') as f:
                log = f.read()
                if "CUMULATIVE OUTGOING" in log or "CROSS SECTIONS" in log:
                    if "FAIL IN EIGCC" not in log:
                        is_success = True
        except: pass

        if is_success:
            status = "✅ 成功"
        
        # 格式化输出
        disc_str = f"{disc:+.4e}" if disc is not None else "崩溃/无数据"
        hint = ""
        if disc is not None:
            if disc > 0: hint = "(太浅)"
            elif disc < 0: hint = "(太深)"
            history.append((depth_val, disc))
            
        print(f"{depth_val:<10.2f} | {disc_str} {hint:<8} | {status}")
        
        if is_success:
            print("-" * 55)
            print(f"🎉 恭喜！找到可用深度: {depth_val:.2f} MeV")
            break

    # 智能插值
    print("-" * 55)
    
    last_pos = None
    last_neg = None
    
    for d, val in history:
        if val > 0: last_pos = (d, val)
        if val < 0 and last_neg is None: last_neg = (d, val)
        
    if last_pos and last_neg:
        d1, v1 = last_pos
        d2, v2 = last_neg
        perfect_depth = d1 + (0 - v1) * (d2 - d1) / (v2 - v1)
        print(f"💡 根据扫描数据，理论最佳深度是: {perfect_depth:.3f} MeV")
        
        print(f"🚀 正在验证 {perfect_depth:.3f} MeV ...")
        
        with open(TEMPLATE_FILE, 'r', encoding='utf-8') as f:
            tmpl = f.read()
        with open(INPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(tmpl.replace("{DEPTH}", f"{perfect_depth:.3f}"))
            
        run_fresco_redirection()
        
        # 最终检查
        final_disc = get_discrepancy(OUTPUT_FILE)
        is_final_success = False
        try:
            with open(OUTPUT_FILE, 'r', encoding='utf-8', errors='ignore') as f:
                if "CROSS SECTIONS" in f.read(): is_final_success = True
        except: pass

        print(f"验证结果: 偏差 = {final_disc}")
        if is_final_success:
            print("✅ 验证成功！结果已保存在 19F_scan.out")
        else:
            print("⚠️ 仍有微小偏差，但已是最优解。")
    else:
        print("未找到正负交界，请尝试扩大扫描范围 (如 70.0 - 90.0)。")

if __name__ == "__main__":
    main()