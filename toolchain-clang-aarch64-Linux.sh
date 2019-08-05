REPO=http://yumazure.oushu-tech.com:12000/oushurepo/yumrepo/internal/linux/toolchain

if [ ! -d /opt/clang ]; then
	curl -s $REPO/clang+llvm-7.1.0-aarch64-linux-gnu.tar.xz | tar xJ -C /opt
	ln -sf clang+llvm-7.1.0-aarch64-linux-gnu /opt/clang
fi
if [ ! -d /opt/dependency-clang-aarch64-Linux/ ]; then
	curl -s $REPO/dependency-clang-aarch64-Linux.tar.xz | tar xJ -C /opt
fi

export PATH=/opt/clang/bin:$PATH
export LD_LIBRARY_PATH=/opt/clang/lib:$LD_LIBRARY_PATH

export CPATH=/opt/clang/include/c++/v1/
export LIBRARY_PATH=/opt/clang/lib

unset CPPFLAGS
unset CFLAGS
export CXXFLAGS='-stdlib=libc++'
export LDFLAGS='-rtlib=compiler-rt -lgcc_s'

export CC=clang
export CXX=clang++
export LD=ld.lld

source /opt/dependency-clang-aarch64-Linux/package/env.sh
