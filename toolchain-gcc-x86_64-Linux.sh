REPO=http://yumazure.oushu-tech.com:12000/oushurepo/yumrepo/internal/linux/toolchain

if [ ! -d /opt/gcc ]; then
	curl -s $REPO/gcc-7.4.0-x86_64-linux-sles11.4.tar.xz | tar xJ -C /opt
	ln -sf gcc-7.4.0-x86_64-linux-sles11.4 /opt/gcc
fi
if [ ! -d /opt/cmake ]; then
	curl -s $REPO/cmake-3.12.4-Linux-x86_64.tar.gz | tar xz -C /opt
	ln -sf cmake-3.12.4-Linux-x86_64 /opt/cmake
fi
if [ ! -d /opt/dependency-gcc-x86_64-Linux/ ]; then
       curl -s $REPO/dependency-gcc-x86_64-Linux.tar.gz | tar xz -C /opt
fi

export PATH=/opt/gcc/bin:/opt/cmake/bin:$PATH
export LD_LIBRARY_PATH=/opt/gcc/lib64/:$LD_LIBRARY_PATH

export CPATH=/opt/gcc/include/c++/7.4.0/:/opt/gcc/include/c++/7.4.0/x86_64-pc-linux-gnu/
export LIBRARY_PATH=/opt/gcc/lib64/

unset CPPFLAGS
export CFLAGS='-std=gnu11 -fno-use-linker-plugin'
export CXXFLAGS='-fpermissive -fno-use-linker-plugin'
unset LDFLAGS

export CC=gcc
export CXX=g++
export LD=ld

source /opt/dependency-gcc-x86_64-Linux/package/env.sh
