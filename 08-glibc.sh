#!/bin/bash
# 维护：Yuchen Deng QQ群：19346666、111601117

source `dirname ${BASH_SOURCE[0]}`/lfs.sh

pushd $LFS/sources/$(getConf LFS_VERSION)
    [ "$CLEAN" ] && rm -rf $(find . -maxdepth 1 -type d -name "glibc-*")
    tar --keep-newer-files -xf $(find . -maxdepth 1 -type f -name glibc-*.tar.*) 2>/dev/null
    cd $(find . -maxdepth 1 -type d -name "glibc-*")
    [ -f PATCHED ] && patch -p1 -R < $(find .. -maxdepth 1 -type f -name glibc-*.patch)
    patch -p1 < $(find .. -maxdepth 1 -type f -name glibc-*.patch)
    touch PATCHED

    mkdir -v build
    cd build

    case $(uname -m) in
        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
        ;;
        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
        ;;
    esac

    echo "rootsbindir=/usr/sbin" > configparms

    ../configure                            \
        --prefix=/usr                       \
        --host=$LFS_TGT                     \
        --build=$(../scripts/config.guess)  \
        --enable-kernel=3.2                 \
        --with-headers=$LFS/usr/include     \
        libc_cv_slibdir=/usr/lib
    make -j 1
    make DESTDIR=$LFS install

    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
    echo 'int main(){}' > dummy.c
    $LFS_TGT-gcc dummy.c
    readelf -l a.out | grep '/ld-linux'
    [ ! $? ] && echo OK && $LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders
    rm -v dummy.c a.out
popd
