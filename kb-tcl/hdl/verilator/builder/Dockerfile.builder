FROM rleys/builder:rocky9

# ccache
RUN dnf install -y epel-release
RUN dnf install -y --enablerepo=devel --enablerepo=epel mold ccache numactl autoconf flex bison help2man python3 git libfl-devel

#RUN dnf install -y --enablerepo=devel --enablerepo=epel mingw64-gcc mingw64-cpp mingw64-gcc-c++ mingw64-winpthreads-static mingw32-pkg-config mingw32-libxml2-static
RUN dnf install -y --enablerepo=devel mingw64-gcc mingw64-cpp mingw64-gcc-c++ mingw64-winpthreads-static

    