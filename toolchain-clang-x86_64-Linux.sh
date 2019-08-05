REPO=http://yumazure.oushu-tech.com:12000/oushurepo/yumrepo/internal/linux/toolchain

if [ ! -d /opt/clang ]; then
	curl -s $REPO/clang+llvm-8.0.1-x86_64-linux-sles11.3.tar.xz | tar xJ -C /opt
	ln -sf clang+llvm-8.0.1-x86_64-linux-sles11.3 /opt/clang
fi
if [ ! -d /opt/cmake ]; then
	curl -s $REPO/cmake-3.12.4-Linux-x86_64.tar.gz | tar xz -C /opt
	ln -sf cmake-3.12.4-Linux-x86_64 /opt/cmake
fi
if [ ! -d /opt/dependency-clang-x86_64-Linux/ ]; then
	curl -s $REPO/dependency-clang-x86_64-Linux.tar.gz | tar xz -C /opt
fi

export PATH=/opt/clang/bin:/opt/cmake/bin:$PATH
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

source /opt/dependency-clang-x86_64-Linux/package/env.sh
