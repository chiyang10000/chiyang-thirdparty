FROM centos:6

RUN yum install -y xz gcc wget patch ncurses-devel readline-devel
COPY toolchain-* /opt/
RUN source /opt/toolchain-clang-x86_64-Linux.sh
RUN source /opt/toolchain-gcc-x86_64-Linux.sh
