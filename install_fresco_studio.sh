#!/bin/bash
#
# FRESCO Studio Installer (English Version)
# Automatic installation script for macOS and Linux
#
# Usage: chmod +x install_fresco_studio.sh && ./install_fresco_studio.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Print banner
print_banner() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                               ║${NC}"
    echo -e "${CYAN}║${NC}   ${BOLD}FRESCO Studio Installer${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   Modern GUI for FRESCO Coupled Channels Calculations         ${CYAN}║${NC}"
    echo -e "${CYAN}║                                                               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Print step
print_step() {
    echo -e "${BLUE}==>${NC} ${BOLD}$1${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Print warning
print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Print error
print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        print_error "Unsupported operating system: $OSTYPE"
        echo "This installer supports macOS and Linux only."
        echo "Windows users: Please use WSL (Windows Subsystem for Linux)"
        exit 1
    fi
    print_success "Detected OS: $OS"
}

# Install git automatically
install_git() {
    print_step "Installing Git..."

    if [[ "$OS" == "macos" ]]; then
        # Check if Xcode CLI tools are installed
        if ! xcode-select -p &>/dev/null; then
            echo "Installing Xcode Command Line Tools (this may take a few minutes)..."
            xcode-select --install 2>/dev/null || true
            # Wait for installation to complete
            echo "Please complete the Xcode Command Line Tools installation in the popup window."
            echo "Press Enter after the installation is complete..."
            read -r
        fi
        # Git should now be available via Xcode CLI tools
        if command_exists git; then
            print_success "Git installed successfully!"
        else
            print_error "Git installation failed. Please install manually."
            exit 1
        fi
    else
        # Linux
        if command_exists apt-get; then
            echo "Using apt-get to install git..."
            sudo apt-get update && sudo apt-get install -y git
        elif command_exists yum; then
            echo "Using yum to install git..."
            sudo yum install -y git
        elif command_exists dnf; then
            echo "Using dnf to install git..."
            sudo dnf install -y git
        elif command_exists pacman; then
            echo "Using pacman to install git..."
            sudo pacman -S --noconfirm git
        elif command_exists zypper; then
            echo "Using zypper to install git..."
            sudo zypper install -y git
        else
            print_error "Could not detect package manager. Please install git manually."
            exit 1
        fi

        if command_exists git; then
            print_success "Git installed successfully!"
        else
            print_error "Git installation failed."
            exit 1
        fi
    fi
}

# Install Fortran compiler automatically
install_gfortran() {
    print_step "Installing Fortran compiler (gfortran)..."

    if [[ "$OS" == "macos" ]]; then
        # Check if Homebrew is installed
        if ! command_exists brew; then
            echo "Homebrew not found. Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for this session
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f "/usr/local/bin/brew" ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
        echo "Installing gcc (includes gfortran) via Homebrew..."
        brew install gcc
        if command_exists gfortran; then
            print_success "gfortran installed successfully!"
        else
            print_error "gfortran installation failed."
            exit 1
        fi
    else
        # Linux
        if command_exists apt-get; then
            echo "Using apt-get to install gfortran..."
            sudo apt-get update && sudo apt-get install -y gfortran
        elif command_exists yum; then
            echo "Using yum to install gfortran..."
            sudo yum install -y gcc-gfortran
        elif command_exists dnf; then
            echo "Using dnf to install gfortran..."
            sudo dnf install -y gcc-gfortran
        elif command_exists pacman; then
            echo "Using pacman to install gfortran..."
            sudo pacman -S --noconfirm gcc-fortran
        elif command_exists zypper; then
            echo "Using zypper to install gfortran..."
            sudo zypper install -y gcc-fortran
        else
            print_error "Could not detect package manager. Please install gfortran manually."
            exit 1
        fi

        if command_exists gfortran; then
            print_success "gfortran installed successfully!"
        else
            print_error "gfortran installation failed."
            exit 1
        fi
    fi
}

# Install Miniconda automatically
install_conda() {
    print_step "Installing Miniconda..."

    MINICONDA_DIR="$HOME/miniconda3"

    if [[ "$OS" == "macos" ]]; then
        # Detect architecture
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh"
        else
            MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-x86_64.sh"
        fi
    else
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
    fi

    echo "Downloading Miniconda..."
    curl -fsSL "$MINICONDA_URL" -o /tmp/miniconda.sh

    echo "Installing Miniconda to $MINICONDA_DIR..."
    bash /tmp/miniconda.sh -b -p "$MINICONDA_DIR"
    rm /tmp/miniconda.sh

    # Initialize conda for this session
    export PATH="$MINICONDA_DIR/bin:$PATH"
    source "$MINICONDA_DIR/etc/profile.d/conda.sh"

    # Initialize conda for future sessions
    "$MINICONDA_DIR/bin/conda" init bash 2>/dev/null || true
    "$MINICONDA_DIR/bin/conda" init zsh 2>/dev/null || true

    if command_exists conda; then
        print_success "Miniconda installed successfully!"
        print_warning "Note: You may need to restart your terminal for conda to work in future sessions."
    else
        print_error "Miniconda installation failed."
        exit 1
    fi
}

# Check prerequisites and install if missing
check_prerequisites() {
    print_step "Checking prerequisites..."

    # Check for git
    if ! command_exists git; then
        print_warning "Git not found"
        read -p "Do you want to install Git automatically? (y/n): " INSTALL_GIT
        if [[ "$INSTALL_GIT" =~ ^[Yy]$ ]]; then
            install_git
        else
            print_error "Git is required. Please install it manually and run this script again."
            exit 1
        fi
    else
        print_success "Git is installed"
    fi

    # Check for gfortran
    if ! command_exists gfortran; then
        print_warning "Fortran compiler (gfortran) not found"
        read -p "Do you want to install gfortran automatically? (y/n): " INSTALL_GFORTRAN
        if [[ "$INSTALL_GFORTRAN" =~ ^[Yy]$ ]]; then
            install_gfortran
        else
            print_error "gfortran is required to compile FRESCO. Please install it manually and run this script again."
            exit 1
        fi
    else
        print_success "Fortran compiler (gfortran) is installed"
    fi

    # Check for conda
    if ! command_exists conda; then
        print_warning "Conda not found"
        read -p "Do you want to install Miniconda automatically? (y/n): " INSTALL_CONDA
        if [[ "$INSTALL_CONDA" =~ ^[Yy]$ ]]; then
            install_conda
        else
            print_error "Conda is required. Please install it manually and run this script again."
            echo "Download from: https://docs.conda.io/en/latest/miniconda.html"
            exit 1
        fi
    else
        print_success "Conda is installed"
    fi

    print_success "All prerequisites are installed!"
}

# Choose installation directory
choose_install_dir() {
    print_step "Choosing installation directory..."

    # Default directory
    DEFAULT_DIR="$HOME/fresco_gui"

    echo ""
    echo "Where would you like to install FRESCO Studio?"
    echo "  Default: $DEFAULT_DIR"
    echo ""
    read -p "Press Enter for default, or enter a custom path: " CUSTOM_DIR

    if [ -z "$CUSTOM_DIR" ]; then
        INSTALL_DIR="$DEFAULT_DIR"
    else
        INSTALL_DIR="$CUSTOM_DIR"
    fi

    # Check if directory already exists
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "Directory already exists: $INSTALL_DIR"
        read -p "Do you want to remove it and reinstall? (y/n): " REMOVE_OLD
        if [[ "$REMOVE_OLD" =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            print_success "Old installation removed"
        else
            print_error "Installation cancelled. Please choose a different directory."
            exit 1
        fi
    fi

    print_success "Installation directory: $INSTALL_DIR"
}

# Clone repository
clone_repository() {
    print_step "Downloading FRESCO Studio..."

    git clone https://github.com/jinleiphys/fresco_gui.git "$INSTALL_DIR"

    print_success "Downloaded successfully!"
}

# Run setup
run_setup() {
    print_step "Setting up FRESCO Studio..."

    cd "$INSTALL_DIR"

    # Make setup script executable
    chmod +x setup_gui.sh

    # Run setup
    ./setup_gui.sh

    print_success "Setup completed!"
}

# Create desktop shortcut (macOS only)
create_shortcut() {
    if [[ "$OS" == "macos" ]]; then
        print_step "Creating application shortcut..."

        # Create a simple .command file for easy launching
        SHORTCUT="$HOME/Desktop/FRESCO Studio.command"
        cat > "$SHORTCUT" << EOF
#!/bin/bash
cd "$INSTALL_DIR"
./run_fresco_gui.sh
EOF
        chmod +x "$SHORTCUT"
        print_success "Created shortcut on Desktop: FRESCO Studio.command"
    fi
}

# Print usage instructions
print_instructions() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}${BOLD}Installation Complete!${NC}                                     ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}FRESCO Studio has been installed to:${NC}"
    echo "  $INSTALL_DIR"
    echo ""
    echo -e "${BOLD}To run FRESCO Studio:${NC}"
    echo ""
    echo "  Option 1: Use the launcher script"
    echo -e "    ${CYAN}cd $INSTALL_DIR${NC}"
    echo -e "    ${CYAN}./run_fresco_gui.sh${NC}"
    echo ""
    echo "  Option 2: Run manually"
    echo -e "    ${CYAN}conda activate fresco_gui${NC}"
    echo -e "    ${CYAN}cd $INSTALL_DIR/fresco_gui${NC}"
    echo -e "    ${CYAN}python main.py${NC}"
    echo ""
    if [[ "$OS" == "macos" ]]; then
        echo "  Option 3: Double-click 'FRESCO Studio.command' on your Desktop"
        echo ""
    fi
    echo -e "${BOLD}Quick Start Guide:${NC}"
    echo ""
    echo "  1. Launch FRESCO Studio using one of the methods above"
    echo ""
    echo "  2. In the wizard, enter a reaction equation:"
    echo "     - Elastic scattering:   p+ni58"
    echo "     - Inelastic scattering: p+ni58 (with excited states)"
    echo "     - Transfer reaction:    c12(d,p)c13"
    echo ""
    echo "  3. Follow the wizard steps to configure your calculation"
    echo ""
    echo "  4. Click 'Run' to execute FRESCO and view results"
    echo ""
    echo -e "${BOLD}Currently Supported Reaction Types:${NC}"
    echo "  - Elastic Scattering"
    echo "  - Inelastic Scattering"
    echo "  - Transfer Reactions"
    echo ""
    echo -e "${BOLD}Documentation:${NC}"
    echo "  - README: $INSTALL_DIR/README.md"
    echo "  - Chinese: $INSTALL_DIR/README_CN.md"
    echo "  - FRESCO manual: $INSTALL_DIR/fresco_code/man/"
    echo ""
    echo -e "${BOLD}Need Help?${NC}"
    echo "  - GitHub: https://github.com/jinleiphys/fresco_gui"
    echo "  - Contact: jinlei@fewbody.com"
    echo ""
    echo -e "${GREEN}Enjoy using FRESCO Studio!${NC}"
    echo ""
}

# Main installation process
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

# Run main function
main
