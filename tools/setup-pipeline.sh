#!/bin/bash
################################################################################
# setup-pipeline.sh - CachyOS VM Complete Analysis Pipeline Setup
################################################################################
#
# @purpose: Complete environment setup for static analysis pipeline
#   - Compiles LLVM/Clang from source with Ivy Bridge optimizations
#   - Builds analysis tools (cppcheck, cflow, Graphviz)
#   - Sets up llama.cpp for local LLM preprocessing
#   - Creates pipeline scripts for multi-repo analysis
#   - Optimizes for Xeon E5-2697 v2 (Ivy Bridge, AVX + FMA)
#
# @workflow: 7-phase pipeline setup
#   Phase 1: Environment Configuration
#     └─> Set compiler flags for Ivy Bridge architecture
#     └─> Configure PATH with local binaries
#
#   Phase 2: System Dependencies
#     └─> Update CachyOS base system
#     └─> Install build tools and analysis dependencies
#     └─> Install Python packages via Pacman
#
#   Phase 3: LLVM/Clang Compilation
#     └─> Clone llvm-project from GitHub
#     └─> Build with Ninja (X86 target only)
#     └─> Install clang-tidy for static analysis
#
#   Phase 4: cppcheck Compilation
#     └─> Clone cppcheck from GitHub
#     └─> Build with CMake and install system-wide
#
#   Phase 5: llama.cpp Compilation
#     └─> Clone llama.cpp for local LLM inference
#     └─> Build with Ivy Bridge optimizations
#
#   Phase 6: Graphviz Compilation
#     └─> Clone from GitLab source
#     └─> Build for large call graph visualization
#     └─> Install to ~/.local prefix
#
#   Phase 7: Pipeline Scripts Creation
#     └─> Create clone_repo.sh for repository management
#     └─> Create run_static.sh for analysis execution
#     └─> Create combine.py for data aggregation
#     └─> Create run_llm_local.sh for LLM preprocessing
#
# @dependencies: CachyOS-specific setup
#   System requirements:
#     - CachyOS VM with base-devel
#     - Bash 4.0+, set -e for error propagation
#     - sudo access for pacman and system installs
#     - 24 CPU cores (Xeon E5-2697 v2)
#     - ~20GB disk space for compilation artifacts
#
#   File structure:
#     - ~/Shared/analysis/ - Main working directory
#     - ~/.local/bin - User-local binaries
#     - ~/yay - AUR helper installation directory
#
#   Network:
#     - GitHub access for LLVM, cppcheck, llama.cpp
#     - GitLab access for Graphviz
#     - AUR access for yay and cflow
#
# @gotchas: Architecture and performance considerations
#   Ivy Bridge Specific:
#     - Must use -march=ivybridge (not native on VM)
#     - AVX supported, AVX2 NOT supported (Haswell+)
#     - FMA instructions available and enabled
#     - Performance: ~60min total compilation time
#
#   Memory Requirements:
#     - LLVM compilation peaks at ~8GB RAM
#     - Parallel builds (-j24) can OOM on <16GB systems
#     - Consider -j12 if running other services
#     - Ninja is memory-hungry during link phase
#
#   Path Dependencies:
#     - Scripts assume ~/Shared/analysis/ exists
#     - Tilde expansion works in Bash but not in Make
#     - Some tools need $HOME explicitly quoted
#     - Generated scripts use absolute paths
#
#   AUR Limitations:
#     - yay install requires manual confirmation
#     - cflow only available via AUR on Arch/CachyOS
#     - AUR builds can break on system updates
#     - Consider caching AUR packages separately
#
#   Compilation Flags:
#     - -ffast-math may affect floating-point precision
#     - -funroll-loops increases binary size
#     - Flags apply to ALL compiled tools uniformly
#     - Some projects ignore CFLAGS (check Makefiles)
#
#   Tool Versions:
#     - LLVM trunk may have breaking API changes
#     - cppcheck releases are stable but slow
#     - llama.cpp changes model format frequently
#     - Pin versions for reproducible builds
#
# USAGE:
#   ./setup-pipeline.sh
#   # No arguments - full automated setup
#   # Expected runtime: ~60 minutes
#
# OUTPUT:
#   Compiled binaries:
#     - ~/Shared/analysis/llvm-project/build/bin/clang-tidy
#     - /usr/local/bin/cppcheck
#     - ~/Shared/analysis/llama.cpp/main
#     - ~/.local/bin/dot (Graphviz)
#
#   Pipeline scripts:
#     - ~/Shared/analysis/pipeline/clone_repo.sh
#     - ~/Shared/analysis/pipeline/run_static.sh
#     - ~/Shared/analysis/pipeline/combine.py
#     - ~/Shared/analysis/pipeline/run_llm_local.sh
#
#   Directory structure:
#     ~/Shared/analysis/
#       ├── repos/           # Cloned repositories
#       ├── pipeline/        # Analysis scripts
#       ├── outputs/
#       │   ├── raw/         # Per-tool outputs
#       │   ├── combined/    # JSON bundles
#       │   └── final/       # LLM results
#       └── models/gguf/     # LLM model files
#
# RELATED SCRIPTS:
#   - clone_repo.sh - Repository cloning (auto-generated)
#   - run_static.sh - Multi-tool analysis executor (auto-generated)
#   - combine.py - Data aggregation utility (auto-generated)
#   - run_llm_local.sh - Local LLM preprocessing (auto-generated)
#
################################################################################

set -e  # Exit on any error

# ============================================
# PHASE 1: Environment Configuration
# @purpose: Set Ivy Bridge compiler optimizations
# @why: VM requires explicit architecture targeting
# @method: Export CFLAGS/CXXFLAGS for all builds
# @output: Environment variables for compilation
# @gotcha: -march=ivybridge must be set (not auto-detected in VM)
# ============================================

echo "[INFO] Setting compiler flags for Ivy Bridge"

# WHY: Xeon E5-2697 v2 is Ivy Bridge (AVX + FMA, no AVX2)
# -march=ivybridge: Explicit CPU targeting for VM
# -mfma: Enable Fused Multiply-Add instructions
# -ffast-math: Aggressive floating-point optimizations
# -funroll-loops: Unroll loops for better IPC
export CFLAGS="-O3 -march=ivybridge -mfma -ffast-math -funroll-loops"
export CXXFLAGS="$CFLAGS"

# WHY: Ensure user-compiled binaries take precedence
export PATH="$HOME/.local/bin:$PATH"

# ============================================
# PHASE 2: System Dependencies
# @purpose: Install base packages and analysis tools
# @why: CachyOS minimal install lacks build dependencies
# @method: Use pacman for system packages, yay for AUR
# @output: System-wide tool installation
# @gotcha: yay requires manual install from AUR
# ============================================

echo "[INFO] Updating system & installing base packages"
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel git wget curl python cmake ninja

echo "[INFO] Installing analysis tools dependencies"
# WHY: Mix of pre-built (clang/llvm) and source-compiled versions
# We install clang/llvm here for dependencies, recompile in Phase 3
sudo pacman -S --noconfirm clang llvm cppcheck doxygen graphviz universal-ctags tree-sitter-cli

echo "[INFO] Installing cflow via AUR using yay"
# WHY: cflow only available via AUR on Arch-based distros
if ! command -v yay &> /dev/null; then
    echo "[INFO] Installing yay..."
    sudo pacman -S --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay
    makepkg -si --noconfirm
fi
yay -S --noconfirm cflow

echo "[INFO] Installing Python packages via Pacman (system-wide)"
# WHY: Avoid pip/venv complexity - use CachyOS native packages
sudo pacman -S --noconfirm python-jinja python-pandas python-networkx

# ============================================
# PHASE 3: LLVM/Clang/Clang-Tidy Compilation
# @purpose: Build optimized LLVM toolchain from source
# @why: Pacman version not optimized for Ivy Bridge
# @method: Clone trunk, build with Ninja, X86-only target
# @output: ~/Shared/analysis/llvm-project/build/bin/*
# @gotcha: Ninja link phase can OOM on <16GB RAM
# ============================================

echo "[INFO] Compiling LLVM/Clang/Clang-Tidy"

# WHY: Check if already cloned to avoid re-download
if [ ! -d "$HOME/Shared/analysis/llvm-project" ]; then
    git clone https://github.com/llvm/llvm-project.git "$HOME/Shared/analysis/llvm-project"
fi

mkdir -p "$HOME/Shared/analysis/llvm-project/build"
cd "$HOME/Shared/analysis/llvm-project/build"

# WHY: Ninja is faster than Make for LLVM builds
# WHY: X86-only reduces build time by ~40% vs all targets
# WHY: clang-tools-extra includes clang-tidy
cmake -G "Ninja" ../llvm \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS"

# WHY: -j24 matches CPU core count (Xeon E5-2697 v2)
ninja -j24
echo "[INFO] LLVM/Clang compiled"

# ============================================
# PHASE 4: cppcheck Compilation
# @purpose: Build cppcheck from source for latest version
# @why: Pacman version may lag behind upstream releases
# @method: CMake build with system-wide install
# @output: /usr/local/bin/cppcheck
# @gotcha: Requires sudo for system install
# ============================================

echo "[INFO] Compiling cppcheck"

if [ ! -d "$HOME/Shared/analysis/cppcheck" ]; then
    git clone https://github.com/danmar/cppcheck.git "$HOME/Shared/analysis/cppcheck"
fi

cd "$HOME/Shared/analysis/cppcheck"
cmake -DCMAKE_BUILD_TYPE=Release .
make -j24
sudo make install

# ============================================
# PHASE 5: llama.cpp Compilation
# @purpose: Build local LLM for code preprocessing
# @why: Enable offline analysis without API costs
# @method: Make build with Ivy Bridge optimizations
# @output: ~/Shared/analysis/llama.cpp/main
# @gotcha: Model format changes frequently - pin versions
# ============================================

echo "[INFO] Compiling llama.cpp (local LLM)"

if [ ! -d "$HOME/Shared/analysis/llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp "$HOME/Shared/analysis/llama.cpp"
fi

cd "$HOME/Shared/analysis/llama.cpp"
# WHY: Clean build ensures flags are applied correctly
make clean
make CFLAGS="$CFLAGS"

# ============================================
# PHASE 6: Graphviz Compilation
# @purpose: Build Graphviz for large call graph rendering
# @why: Large codebases exceed default Graphviz limits
# @method: Autoconf build with user-local install
# @output: ~/.local/bin/dot
# @gotcha: Configure requires autogen.sh first
# ============================================

echo "[INFO] Compiling Graphviz"

if [ ! -d "$HOME/Shared/analysis/graphviz" ]; then
    git clone https://gitlab.com/graphviz/graphviz.git "$HOME/Shared/analysis/graphviz"
fi

cd "$HOME/Shared/analysis/graphviz"

# WHY: GitLab source requires autogen before configure
./autogen.sh

# WHY: --prefix=$HOME/.local avoids sudo requirement
./configure CFLAGS="$CFLAGS" --prefix="$HOME/.local"
make -j24
make install

# ============================================
# PHASE 7: Pipeline Setup
# @purpose: Create directory structure and analysis scripts
# @why: Standardize multi-repo analysis workflow
# @method: Generate scripts via heredocs
# @output: 4 executable scripts in ~/Shared/analysis/pipeline/
# @gotcha: Heredoc variables expand unless quoted with 'EOF'
# ============================================

echo "[INFO] Creating pipeline directories"
mkdir -p ~/Shared/analysis/{repos,pipeline,outputs/raw,outputs/combined,outputs/final,models/gguf}

# ============================================
# SCRIPT 1: clone_repo.sh
# @purpose: Clone repository for analysis
# @why: Standardize repo naming and location
# ============================================

cat <<'EOF' > ~/Shared/analysis/pipeline/clone_repo.sh
#!/bin/bash
set -e
REPO_URL=$1
REPO_NAME=$2
if [ -z "$REPO_URL" ] || [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo_url> <repo_name>"
    exit 1
fi
mkdir -p ~/Shared/analysis/repos/"$REPO_NAME"
git clone "$REPO_URL" ~/Shared/analysis/repos/"$REPO_NAME"
echo "Cloned $REPO_URL into repos/$REPO_NAME"
EOF
chmod +x ~/Shared/analysis/pipeline/clone_repo.sh

# ============================================
# SCRIPT 2: run_static.sh
# @purpose: Execute all static analysis tools on a repository
# @why: Automate multi-tool analysis workflow
# @output: Raw tool outputs in outputs/raw/REPO_NAME/
# ============================================

cat <<'EOF' > ~/Shared/analysis/pipeline/run_static.sh
#!/bin/bash
set -e
REPO_NAME=$1
if [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo_name>"
    exit 1
fi
REPO_DIR=~/Shared/analysis/repos/"$REPO_NAME"
OUT_DIR=~/Shared/analysis/outputs/raw/"$REPO_NAME"
mkdir -p "$OUT_DIR"

echo "[1] Listing .c/.h files"
find "$REPO_DIR" -name '*.c' -o -name '*.h' > "$OUT_DIR/files.txt"

echo "[2] Call graph (cflow)"
# WHY: -b generates backwards call tree
cflow -b $(cat "$OUT_DIR/files.txt") > "$OUT_DIR/cflow.txt"

echo "[3] Tags (ctags)"
# WHY: -x produces cross-reference format, +p includes prototypes
ctags -x --c-kinds=+p --fields=+n $(cat "$OUT_DIR/files.txt") > "$OUT_DIR/ctags.txt"

echo "[4] clang-tidy"
# WHY: -checks=* runs all available checks
clang-tidy -checks=* $(cat "$OUT_DIR/files.txt") -- > "$OUT_DIR/clang-tidy.txt"

echo "[5] cppcheck"
# WHY: --enable=all includes style, performance, portability checks
cppcheck --enable=all --xml --xml-version=2 "$REPO_DIR" 2> "$OUT_DIR/cppcheck.xml"

echo "[6] AST dumps"
# WHY: JSON format for programmatic analysis
for f in $(cat "$OUT_DIR/files.txt" | grep '\.c$'); do
    clang -Xclang -ast-dump=json -fsyntax-only "$f" > "$OUT_DIR/$(basename "$f").ast.json"
done

echo "[7] Cyclomatic complexity"
# WHY: -C measures complexity per function
lizard -C "$REPO_DIR" > "$OUT_DIR/complexity.txt"
EOF
chmod +x ~/Shared/analysis/pipeline/run_static.sh

# ============================================
# SCRIPT 3: combine.py
# @purpose: Aggregate all tool outputs into single JSON bundle
# @why: Simplify data ingestion for LLM preprocessing
# @output: outputs/combined/REPO_NAME/bundle.json
# ============================================

cat <<'EOF' > ~/Shared/analysis/pipeline/combine.py
import json, glob, os, sys
if len(sys.argv) != 2:
    print("Usage: python combine.py <repo_name>")
    sys.exit(1)
repo_name = sys.argv[1]
out_dir = f"../outputs/raw/{repo_name}"
combined_dir = f"../outputs/combined/{repo_name}"
os.makedirs(combined_dir, exist_ok=True)
bundle = {
    "files": open(f"{out_dir}/files.txt").read().splitlines(),
    "callgraph": open(f"{out_dir}/cflow.txt").read(),
    "ctags": open(f"{out_dir}/ctags.txt").read(),
    "clang_tidy": open(f"{out_dir}/clang-tidy.txt").read(),
    "cppcheck": open(f"{out_dir}/cppcheck.xml").read(),
    "complexity": open(f"{out_dir}/complexity.txt").read(),
    "ast": {}
}
for f in glob.glob(f"{out_dir}/*.ast.json"):
    key = os.path.basename(f).replace(".ast.json","")
    bundle["ast"][key] = json.loads(open(f).read())
with open(f"{combined_dir}/bundle.json","w") as f:
    json.dump(bundle,f,indent=2)
print(f"[INFO] Bundle created at {combined_dir}/bundle.json")
EOF

# ============================================
# SCRIPT 4: run_llm_local.sh
# @purpose: Run local LLM for code summarization
# @why: Generate compressed semantic maps offline
# @output: outputs/final/REPO_NAME/llm_summary.txt
# @gotcha: Requires GGUF model file in models/gguf/
# ============================================

cat <<'EOF' > ~/Shared/analysis/pipeline/run_llm_local.sh
#!/bin/bash
set -e
REPO_NAME=$1
if [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo_name>"
    exit 1
fi
BUNDLE=../outputs/combined/"$REPO_NAME"/bundle.json
MODEL=../models/gguf/phi3-mini.gguf
mkdir -p ../outputs/final/"$REPO_NAME"
echo "[INFO] Running local LLM for preprocessing $REPO_NAME"

# WHY: --threads 24 matches CPU cores
# WHY: --ctx-size 8192 accommodates large bundles
# WHY: --batch-size 2048 optimizes throughput
~/Shared/analysis/llama.cpp/main -m "$MODEL" \
    --threads 24 \
    --ctx-size 8192 \
    --batch-size 2048 \
    -p "Summarize codebase bundle and produce compressed semantic map." \
    < "$BUNDLE" \
    > ../outputs/final/"$REPO_NAME"/llm_summary.txt
echo "[INFO] Local LLM preprocessing complete for $REPO_NAME"
EOF
chmod +x ~/Shared/analysis/pipeline/run_llm_local.sh

# ============================================
# Setup Complete
# ============================================

echo "[INFO] Full setup + compilation pipeline ready. Start by cloning a repo:"
echo "bash ~/Shared/analysis/pipeline/clone_repo.sh https://github.com/openssl/openssl.git openssl"
