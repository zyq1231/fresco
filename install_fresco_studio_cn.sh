#!/bin/bash
#
# FRESCO Studio 安装脚本（中文版）
# macOS 和 Linux 自动安装脚本
#
# 使用方法: chmod +x install_fresco_studio_cn.sh && ./install_fresco_studio_cn.sh
#

set -e

# 输出颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'cd
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # 无颜色
BOLD='\033[1m'

# 打印横幅
print_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                               ║${NC}"
    echo -e "${CYAN}║${NC}   ${BOLD}FRESCO Studio 安装程序${NC}                                      ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   核反应耦合道计算的现代图形界面                              ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 打印步骤
print_step() {
    echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"
}

# 打印成功
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# 打印警告
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# 打印错误
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        print_error "不支持的操作系统: $OSTYPE"
        echo "此安装程序仅支持 macOS 和 Linux。"
        echo "Windows 用户请使用 WSL（Windows Subsystem for Linux）"
        exit 1
    fi
    print_success "检测到操作系统: $OS"
}

# 自动安装 Git
install_git() {
    print_step "正在安装 Git..."

    if [[ "$OS" == "macos" ]]; then
        # 检查是否已安装 Xcode 命令行工具
        if ! xcode-select -p &>/dev/null; then
            echo "正在安装 Xcode 命令行工具（可能需要几分钟）..."
            xcode-select --install 2>/dev/null || true
            # 等待安装完成
            echo "请在弹出的窗口中完成 Xcode 命令行工具的安装。"
            echo "安装完成后按回车键继续..."
            read -r
        fi
        # Git 应该已经通过 Xcode 命令行工具安装
        if command_exists git; then
            print_success "Git 安装成功！"
        else
            print_error "Git 安装失败，请手动安装。"
            exit 1
        fi
    else
        # Linux
        if command_exists apt-get; then
            echo "使用 apt-get 安装 git..."
            sudo apt-get update && sudo apt-get install -y git
        elif command_exists yum; then
            echo "使用 yum 安装 git..."
            sudo yum install -y git
        elif command_exists dnf; then
            echo "使用 dnf 安装 git..."
            sudo dnf install -y git
        elif command_exists pacman; then
            echo "使用 pacman 安装 git..."
            sudo pacman -S --noconfirm git
        elif command_exists zypper; then
            echo "使用 zypper 安装 git..."
            sudo zypper install -y git
        else
            print_error "无法检测到包管理器，请手动安装 git。"
            exit 1
        fi

        if command_exists git; then
            print_success "Git 安装成功！"
        else
            print_error "Git 安装失败。"
            exit 1
        fi
    fi
}

# 自动安装 Fortran 编译器
install_gfortran() {
    print_step "正在安装 Fortran 编译器 (gfortran)..."

    if [[ "$OS" == "macos" ]]; then
        # 检查是否已安装 Homebrew
        if ! command_exists brew; then
            echo "未找到 Homebrew，正在安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # 将 Homebrew 添加到当前会话的 PATH
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        echo "正在通过 Homebrew 安装 gcc（包含 gfortran）..."
        brew install gcc
        if command_exists gfortran; then
            print_success "gfortran 安装成功！"
        else
            print_error "gfortran 安装失败。"
            exit 1
        fi
    else
        # Linux
        if command_exists apt-get; then
            echo "使用 apt-get 安装 gfortran..."
            sudo apt-get update && sudo apt-get install -y gfortran
        elif command_exists yum; then
            echo "使用 yum 安装 gfortran..."
            sudo yum install -y gcc-gfortran
        elif command_exists dnf; then
            echo "使用 dnf 安装 gfortran..."
            sudo dnf install -y gcc-gfortran
        elif command_exists pacman; then
            echo "使用 pacman 安装 gfortran..."
            sudo pacman -S --noconfirm gcc-fortran
        elif command_exists zypper; then
            echo "使用 zypper 安装 gfortran..."
            sudo zypper install -y gcc-fortran
        else
            print_error "无法检测到包管理器，请手动安装 gfortran。"
            exit 1
        fi

        if command_exists gfortran; then
            print_success "gfortran 安装成功！"
        else
            print_error "gfortran 安装失败。"
            exit 1
        fi
    fi
}

# 自动安装 Miniconda
install_conda() {
    print_step "正在安装 Miniconda..."

    MINICONDA_DIR="$HOME/miniconda3"

    if [[ "$OS" == "macos" ]]; then
        # 检测架构
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        fi
    else
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    fi

    echo "正在下载 Miniconda..."
    curl -fsSL "$MINICONDA_URL" -o /tmp/miniconda.sh

    echo "正在将 Miniconda 安装到 $MINICONDA_DIR..."
    bash /tmp/miniconda.sh -b -p "$MINICONDA_DIR"
    rm /tmp/miniconda.sh

    # 为当前会话初始化 conda
    export PATH="$MINICONDA_DIR/bin:$PATH"
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"

    # 为以后的会话初始化 conda
    "$MINICONDA_DIR/bin/conda" init bash 2>/dev/null || true
    "$MINICONDA_DIR/bin/conda" init zsh 2>/dev/null || true

    if command_exists conda; then
        print_success "Miniconda 安装成功！"
        print_warning "注意：您可能需要重启终端才能在以后的会话中使用 conda。"
    else
        print_error "Miniconda 安装失败。"
        exit 1
    fi
}

# 检查前置依赖，如果缺失则自动安装
check_prerequisites() {
    print_step "检查前置依赖..."

    # 检查 git
    if ! command_exists git; then
        print_warning "未找到 Git"
        read -p "是否自动安装 Git？(y/n): " INSTALL_GIT
        if [[ "$INSTALL_GIT" =~ ^[Yy]$ ]]; then
            install_git
        else
            print_error "Git 是必需的。请手动安装后重新运行此脚本。"
            exit 1
        fi
    else
        print_success "Git 已安装"
    fi

    # 检查 gfortran
    if ! command_exists gfortran; then
        print_warning "未找到 Fortran 编译器 (gfortran)"
        read -p "是否自动安装 gfortran？(y/n): " INSTALL_GFORTRAN
        if [[ "$INSTALL_GFORTRAN" =~ ^[Yy]$ ]]; then
            install_gfortran
        else
            print_error "gfortran 是编译 FRESCO 所必需的。请手动安装后重新运行此脚本。"
            exit 1
        fi
    else
        print_success "Fortran 编译器 (gfortran) 已安装"
    fi

    # 检查 conda
    if ! command_exists conda; then
        print_warning "未找到 Conda"
        read -p "是否自动安装 Miniconda？(y/n): " INSTALL_CONDA
        if [[ "$INSTALL_CONDA" =~ ^[Yy]$ ]]; then
            install_conda
        else
            print_error "Conda 是必需的。请手动安装后重新运行此脚本。"
            echo "下载地址: https://docs.conda.io/en/latest/miniconda.html"
            exit 1
        fi
    else
        print_success "Conda 已安装"
    fi

    print_success "所有前置依赖已安装！"
}

# 选择安装目录
choose_install_dir() {
    print_step "选择安装目录..."

    # 默认目录
    DEFAULT_DIR="$HOME/fresco_gui"

    echo ""
    echo "您想将 FRESCO Studio 安装到哪里？"
    echo "  默认位置: $DEFAULT_DIR"
    echo ""
    read -p "按回车使用默认位置，或输入自定义路径: " CUSTOM_DIR

    if [ -z "$CUSTOM_DIR" ]; then
        INSTALL_DIR="$DEFAULT_DIR"
    else
        INSTALL_DIR="$CUSTOM_DIR"
    fi

    # 检查目录是否已存在
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "目录已存在: $INSTALL_DIR"
        read -p "是否删除并重新安装？(y/n): " REMOVE_OLD
        if [[ "$REMOVE_OLD" =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            print_success "已删除旧安装"
        else
            print_error "安装已取消。请选择其他目录。"
            exit 1
        fi
    fi

    print_success "安装目录: $INSTALL_DIR"
}

# 克隆仓库
clone_repository() {
    print_step "下载 FRESCO Studio..."

    git clone https://github.com/jinleiphys/fresco_gui.git "$INSTALL_DIR"

    print_success "下载完成！"
}

# 运行安装
run_setup() {
    print_step "配置 FRESCO Studio..."

    cd "$INSTALL_DIR"

    # 使安装脚本可执行
    chmod +x setup_gui.sh

    # 运行安装
    ./setup_gui.sh

    print_success "配置完成！"
}

# 创建桌面快捷方式（仅 macOS）
create_shortcut() {
    if [[ "$OS" == "macos" ]]; then
        print_step "创建应用快捷方式..."

        # 创建简单的 .command 文件便于启动
        SHORTCUT="$HOME/Desktop/FRESCO Studio.command"
        cat > "$SHORTCUT" << EOF
#!/bin/bash
cd "$INSTALL_DIR"
./run_fresco_gui.sh
EOF
        chmod +x "$SHORTCUT"
        print_success "已在桌面创建快捷方式: FRESCO Studio.command"
    fi
}

# 打印使用说明
print_instructions() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}${BOLD}安装完成！${NC}                                                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}FRESCO Studio 已安装到:${NC}"
    echo "  $INSTALL_DIR"
    echo ""
    echo -e "${BOLD}运行 FRESCO Studio:${NC}"
    echo ""
    echo "  方法一：使用启动脚本"
    echo -e "    ${CYAN}cd $INSTALL_DIR${NC}"
    echo -e "    ${CYAN}./run_fresco_gui.sh${NC}"
    echo ""
    echo "  方法二：手动运行"
    echo -e "    ${CYAN}conda activate fresco_gui${NC}"
    echo -e "    ${CYAN}cd $INSTALL_DIR/fresco_gui${NC}"
    echo -e "    ${CYAN}python main.py${NC}"
    echo ""
    if [[ "$OS" == "macos" ]]; then
        echo "  方法三：双击桌面上的 'FRESCO Studio.command'"
        echo ""
    fi
    echo -e "${BOLD}快速入门指南:${NC}"
    echo ""
    echo "  1. 使用上述任一方法启动 FRESCO Studio"
    echo ""
    echo "  2. 在向导中输入反应方程式："
    echo "     - 弹性散射:   p+ni58"
    echo "     - 非弹性散射: p+ni58（带激发态）"
    echo "     - 转移反应:   c12(d,p)c13"
    echo ""
    echo "  3. 按照向导步骤配置您的计算"
    echo ""
    echo "  4. 点击"运行"执行 FRESCO 并查看结果"
    echo ""
    echo -e "${BOLD}目前支持的反应类型:${NC}"
    echo "  - 弹性散射"
    echo "  - 非弹性散射"
    echo "  - 转移反应"
    echo ""
    echo -e "${BOLD}文档:${NC}"
    echo "  - 英文说明: $INSTALL_DIR/README.md"
    echo "  - 中文说明: $INSTALL_DIR/README_CN.md"
    echo "  - FRESCO 手册: $INSTALL_DIR/fresco_code/man/"
    echo ""
    echo -e "${BOLD}需要帮助？${NC}"
    echo "  - GitHub: https://github.com/jinleiphys/fresco_gui"
    echo "  - 联系邮箱: jinlei@fewbody.com"
    echo ""
    echo -e "${GREEN}祝您使用愉快！${NC}"
    echo ""
}

# 主安装流程
main() {
    print_banner

    detect_os
    check_prerequisites
    choose_install_dir
    clone_repository
    run_setup
    create_shortcut
    print_instructions
}

# 运行主函数
main
