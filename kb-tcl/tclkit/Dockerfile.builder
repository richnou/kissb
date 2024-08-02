FROM rleys/builder:rocky8

RUN dnf install -y --enablerepo=devel libcurl-devel bc bzip2 tcl libX11-devel mingw64-gcc mingw64-cpp mingw64-gcc-c++ mingw64-winpthreads-static mingw32-pkg-config mingw32-libxml2-static libxml2-static libxml2-devel libxslt-devel