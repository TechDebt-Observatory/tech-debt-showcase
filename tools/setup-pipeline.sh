#!/bin/bash
set -e
# --------------------------------------------------------
# Full Setup + Compile + Pipeline for Xeon E5-2697 v2
# Target: CachyOS VM (Ivy Bridge, AVX + FMA)
# Supports multiple repos (start with OpenSSL)
# --------------------------------------------------------

# -------------------------------
# 1. Environment variables
# -------------------------------
echo "[INFO] Setting compiler flags for Ivy Bridge"
export CFLAGS="-O3 -march=ivybridge -mfma -ffast-math -funroll-loops"
export CXXFLAGS="$CFLAGS"
export PATH="$HOME/.local/bin:$PATH"

# -------------------------------
# 2. Update system & install dependencies
# -------------------------------
echo "[INFO] Updating system & installing base packages"
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm base-devel git wget curl python cmake ninja

echo "[INFO] Installing analysis tools dependencies"
sudo pacman -S --noconfirm clang llvm cppcheck doxygen graphviz universal-ctags tree-sitter-cli

echo "[INFO] Installing cflow via AUR using yay"
if ! command -v yay &> /dev/null; then
    echo "[INFO] Installing yay..."
    sudo pacman -S --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git ~/yay
    cd ~/yay
    makepkg -si --noconfirm
fi
yay -S --noconfirm cflow

echo "[INFO] Installing Python packages via Pacman (system-wide)"
sudo pacman -S --noconfirm python-jinja python-pandas python-networkx

# -------------------------------
# 3. Compile LLVM/Clang/Clang-Tidy from source
# -------------------------------
echo "[INFO] Compiling LLVM/Clang/Clang-Tidy"
if [ ! -d "$HOME/Shared/analysis/llvm-project" ]; then
    git clone https://github.com/llvm/llvm-project.git $HOME/Shared/analysis/llvm-project
fi
mkdir -p $HOME/Shared/analysis/llvm-project/build
cd $HOME/Shared/analysis/llvm-project/build

cmake -G "Ninja" ../llvm \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DCMAKE_C_FLAGS="$CFLAGS" \
    -DCMAKE_CXX_FLAGS="$CXXFLAGS"

ninja -j24
echo "[INFO] LLVM/Clang compiled"

# -------------------------------
# 4. Compile cppcheck from source
# -------------------------------
echo "[INFO] Compiling cppcheck"
if [ ! -d "$HOME/Shared/analysis/cppcheck" ]; then
    git clone https://github.com/danmar/cppcheck.git $HOME/Shared/analysis/cppcheck
fi
cd $HOME/Shared/analysis/cppcheck
cmake -DCMAKE_BUILD_TYPE=Release .
make -j24
sudo make install

# -------------------------------
# 5. Compile llama.cpp (local LLM)
# -------------------------------
echo "[INFO] Compiling llama.cpp (local LLM)"
if [ ! -d "$HOME/Shared/analysis/llama.cpp" ]; then
    git clone https://github.com/ggerganov/llama.cpp $HOME/Shared/analysis/llama.cpp
fi
cd $HOME/Shared/analysis/llama.cpp
make clean
make CFLAGS="$CFLAGS"

# -------------------------------
# 6. Optional: Compile Graphviz (for large call graphs)
# -------------------------------
echo "[INFO] Compiling Graphviz"
if [ ! -d "$HOME/Shared/analysis/graphviz" ]; then
    git clone https://gitlab.com/graphviz/graphviz.git $HOME/Shared/analysis/graphviz
fi
cd $HOME/Shared/analysis/graphviz
./autogen.sh
./configure CFLAGS="$CFLAGS" --prefix=$HOME/.local
make -j24
make install

# -------------------------------
# 7. Setup pipeline directories
# -------------------------------
echo "[INFO] Creating pipeline directories"
mkdir -p ~/Shared/analysis/{repos,pipeline,outputs/raw,outputs/combined,outputs/final,models/gguf}

# -------------------------------
# 8. Setup pipeline scripts
# -------------------------------

# clone_repo.sh
cat <<'EOF' > ~/Shared/analysis/pipeline/clone_repo.sh
#!/bin/bash
set -e
REPO_URL=$1
REPO_NAME=$2
if [ -z "$REPO_URL" ] || [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo_url> <repo_name>"
    exit 1
fi
mkdir -p ~/Shared/analysis/repos/$REPO_NAME
git clone $REPO_URL ~/Shared/analysis/repos/$REPO_NAME
echo "Cloned $REPO_URL into repos/$REPO_NAME"
EOF
chmod +x ~/Shared/analysis/pipeline/clone_repo.sh

# run_static.sh
cat <<'EOF' > ~/Shared/analysis/pipeline/run_static.sh
#!/bin/bash
set -e
REPO_NAME=$1
if [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo_name>"
    exit 1
fi
REPO_DIR=~/Shared/analysis/repos/$REPO_NAME
OUT_DIR=~/Shared/analysis/outputs/raw/$REPO_NAME
mkdir -p $OUT_DIR

echo "[1] Listing .c/.h files"
find $REPO_DIR -name '*.c' -o -name '*.h' > $OUT_DIR/files.txt

echo "[2] Call graph (cflow)"
cflow -b $(cat $OUT_DIR/files.txt) > $OUT_DIR/cflow.txt

echo "[3] Tags (ctags)"
ctags -x --c-kinds=+p --fields=+n $(cat $OUT_DIR/files.txt) > $OUT_DIR/ctags.txt

echo "[4] clang-tidy"
clang-tidy -checks=* $(cat $OUT_DIR/files.txt) -- > $OUT_DIR/clang-tidy.txt

echo "[5] cppcheck"
cppcheck --enable=all --xml --xml-version=2 $REPO_DIR 2> $OUT_DIR/cppcheck.xml

echo "[6] AST dumps"
for f in $(cat $OUT_DIR/files.txt | grep '\.c$'); do
    clang -Xclang -ast-dump=json -fsyntax-only $f > $OUT_DIR/$(basename $f).ast.json
done

echo "[7] Cyclomatic complexity"
lizard -C $REPO_DIR > $OUT_DIR/complexity.txt
EOF
chmod +x ~/Shared/analysis/pipeline/run_static.sh

# combine.py
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

# run_llm_local.sh
cat <<'EOF' > ~/Shared/analysis/pipeline/run_llm_local.sh
#!/bin/bash
set -e
REPO_NAME=$1
if [ -z "$REPO_NAME" ]; then
    echo "Usage: $0 <repo_name>"
    exit 1
fi
BUNDLE=../outputs/combined/$REPO_NAME/bundle.json
MODEL=../models/gguf/phi3-mini.gguf
mkdir -p ../outputs/final/$REPO_NAME
echo "[INFO] Running local LLM for preprocessing $REPO_NAME"
~/Shared/analysis/llama.cpp/main -m $MODEL \
    --threads 24 \
    --ctx-size 8192 \
    --batch-size 2048 \
    -p "Summarize codebase bundle and produce compressed semantic map." \
    < $BUNDLE \
    > ../outputs/final/$REPO_NAME/llm_summary.txt
echo "[INFO] Local LLM preprocessing complete for $REPO_NAME"
EOF
chmod +x ~/Shared/analysis/pipeline/run_llm_local.sh

echo "[INFO] Full setup + compilation pipeline ready. Start by cloning a repo:"
echo "bash ~/Shared/analysis/pipeline/clone_repo.sh https://github.com/openssl/openssl.git openssl"
