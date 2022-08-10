[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"
WORKSPACE=$GITHUB_WORKSPACE
HOMEPATH=~

cd $HOMEPATH
git clone https://github.com/nodejs/node.git
cd node

echo "=====[Patching Node.js]====="
git apply $WORKSPACE/handler_posix_main.patch

echo "=====[Building Node.js]====="
cp $WORKSPACE/android-configure ./
./android-configure ~/android-ndk-r21b $1 24
make -j8

