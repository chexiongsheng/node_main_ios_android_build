[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"
WORKSPACE=$GITHUB_WORKSPACE
HOMEPATH=~

cd $HOMEPATH
git clone https://github.com/nodejs/node.git
cd node

echo "=====[Patching Node.js]====="
git apply $WORKSPACE/ios_ninja_compile_for_main.patch
git apply $WORKSPACE/handler_posix_main.patch
git apply $WORKSPACE/rm_platform_darwin_cc_for_ios_main.patch
git apply $WORKSPACE/disable_executable_for_ios_main.patch

echo "=====[ fetch ninja for mac ]====="
wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-mac.zip
unzip ninja-mac.zip

echo "=====[Building libnode]====="
HOST_OS="mac"
HOST_ARCH="x86_64"
export CC_host=$(command -v clang)
export CXX_host=$(command -v clang++)

export CC="$(xcrun -sdk iphoneos -find clang)"
export CXX="$(xcrun -sdk iphoneos -find clang++)"
export AR="$(xcrun -sdk iphoneos -find ar)"
export AS="$(xcrun -sdk iphoneos -find as)"
export LD="$(xcrun -sdk iphoneos -find ld)"
export LIBTOOL="$(xcrun -sdk iphoneos -find libtool)"
export STRIP="$(xcrun -sdk iphoneos -find strip)"
export RANLIB="$(xcrun -sdk iphoneos -find ranlib)"

export SDK=`xcrun --sdk iphoneos --show-sdk-path`

export CXXFLAGS="-std=c++17 -O -arch arm64 -isysroot $SDK" 
export CFLAGS="-O -arch arm64 -isysroot $SDK" 

export CXXFLAGS_host="-DV8_HOST_ARCH_X64 -std=c++17" 
export CFLAGS_host="" 

GYP_DEFINES="target_arch=arm64"
GYP_DEFINES+=" v8_target_arch=arm64"
GYP_DEFINES+=" ios_target_arch=arm64"
GYP_DEFINES+=" host_os=$HOST_OS OS=ios"
export GYP_DEFINES

if [ -f "configure" ]; then
    ./configure \
        --ninja \
        --dest-cpu=arm64 \
        --dest-os=ios \
        --without-snapshot \
        --openssl-no-asm \
        --shared \
        --with-intl=none \
        --no-browser-globals \
        --cross-compiling
fi

./ninja -j 8 -w dupbuild=warn -C out/Release
