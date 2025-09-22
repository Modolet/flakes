{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    xwin

    clang_17
    lld_17
    llvm_17

    # 辅助工具
    cmake
    git
    pkg-config

    # Windows交叉编译支持
    windows.mingw_w64_pthreads
  ];

  # 3. 设置环境变量和编译器配置
  shellHook = ''
    # 设置xwin工作目录
    export XWIN_CACHE_DIR="$PWD/.xwin-cache"
    mkdir -p "$XWIN_CACHE_DIR"
    
    # 下载Windows SDK和运行时库（首次运行时需要）
    if [ ! -d "$XWIN_CACHE_DIR/crt" ]; then
      echo "正在下载Windows SDK和CRT..."
      xwin --accept-license splat --output "$XWIN_CACHE_DIR"
    fi
    
    # 设置Windows SDK路径
    export WINDOWS_SDK_PATH="$XWIN_CACHE_DIR"
    export WINDOWS_INCLUDE_PATH="$XWIN_CACHE_DIR/crt/include:$XWIN_CACHE_DIR/sdk/include/ucrt:$XWIN_CACHE_DIR/sdk/include/um:$XWIN_CACHE_DIR/sdk/include/shared"
    export WINDOWS_LIB_PATH="$XWIN_CACHE_DIR/crt/lib/x86_64:$XWIN_CACHE_DIR/sdk/lib/ucrt/x86_64:$XWIN_CACHE_DIR/sdk/lib/um/x86_64"
    
    # 设置编译器为clang-cl
    export CC="clang-cl"
    export CXX="clang-cl"
    export LD="lld-link"
    export AR="llvm-ar"
    export RANLIB="llvm-ranlib"
    
    # 设置目标架构
    export TARGET="x86_64-pc-windows-msvc"
    
    # 设置clang-cl参数
    export CFLAGS="-target x86_64-pc-windows-msvc -fuse-ld=lld-link -Wno-unused-command-line-argument"
    export CXXFLAGS="-target x86_64-pc-windows-msvc -fuse-ld=lld-link -Wno-unused-command-line-argument"
    
    # 设置包含路径
    export INCLUDE="$WINDOWS_INCLUDE_PATH"
    export LIB="$WINDOWS_LIB_PATH"
    
    # 设置CMake工具链文件路径（如果使用CMake）
    export CMAKE_TOOLCHAIN_FILE="$PWD/clang-cl-msvc.cmake"
    
    echo "Windows交叉编译环境已配置完成！"
    echo "编译器: clang-cl"
    echo "目标平台: x86_64-pc-windows-msvc"
    echo "SDK路径: $WINDOWS_SDK_PATH"
  '';
}
