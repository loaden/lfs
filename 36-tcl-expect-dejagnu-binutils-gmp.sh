#!/bin/bash
# QQ群：111601117、钉钉群：35948877

if [ ! -f $LFS/task.sh ]; then
    source `dirname ${BASH_SOURCE[0]}`/lfs.sh
    cp -v ${BASH_SOURCE[0]} $LFS/task.sh
    sed "s/_LFS_VERSION/$(getConf LFS_VERSION)/g" -i $LFS/task.sh
    sed "s/_LFS_BUILD_PROC/$LFS_BUILD_PROC/g" -i $LFS/task.sh
    source `dirname ${BASH_SOURCE[0]}`/chroot.sh
    rm -fv $LFS/task.sh
    exit
fi

# 来自chroot之后的调用
pushd /sources/_LFS_VERSION
    PKG_NAME=tcl
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME*src.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            SRCDIR=$(pwd)
            cd unix
            ./configure --prefix=/usr   \
                --mandir=/usr/share/man \
            $([ "$(uname -m)" = x86_64 ] && echo --enable-64bit)
            make -j_LFS_BUILD_PROC

            sed -e "s|$SRCDIR/unix|/usr/lib|" \
                -e "s|$SRCDIR|/usr/include|"  \
                -i tclConfig.sh

            sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.3|/usr/lib/tdbc1.1.3|" \
                -e "s|$SRCDIR/pkgs/tdbc1.1.3/generic|/usr/include|"    \
                -e "s|$SRCDIR/pkgs/tdbc1.1.3/library|/usr/lib/tcl8.6|" \
                -e "s|$SRCDIR/pkgs/tdbc1.1.3|/usr/include|"            \
                -i pkgs/tdbc1.1.3/tdbcConfig.sh

            sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.2|/usr/lib/itcl4.2.2|" \
                -e "s|$SRCDIR/pkgs/itcl4.2.2/generic|/usr/include|"    \
                -e "s|$SRCDIR/pkgs/itcl4.2.2|/usr/include|"            \
                -i pkgs/itcl4.2.2/itclConfig.sh

            unset SRCDIR
            make TESTSUITEFLAGS=-j_LFS_BUILD_PROC test && make install

            if [ $? = 0 ]; then
                chmod -v u+w /usr/lib/libtcl8.6.so
                make install-private-headers
                ln -sfv tclsh8.6 /usr/bin/tclsh
                mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
                touch ../_BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=expect
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --with-tcl=/usr/lib     \
                --enable-shared         \
                --mandir=/usr/share/man \
                --with-tclinclude=/usr/include
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC test && make install
            if [ $? = 0 ]; then
                ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=dejagnu
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/build/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build
        pushd $PKG_PATH/build
            ../configure --prefix=/usr
            makeinfo --html --no-split -o doc/dejagnu.html ../doc/dejagnu.texi
            makeinfo --plaintext       -o doc/dejagnu.txt  ../doc/dejagnu.texi

            make -j_LFS_BUILD_PROC install
            if [ $? = 0 ]; then
                install -v -dm755  /usr/share/doc/dejagnu-1.6.3
                install -v -m644   doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.3
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=binutils
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_3/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_3
        pushd $PKG_PATH/build_3
            expect -c "spawn ls"
            read -p "必须输出：spawn ls 才能任意键继续"
            sed -e '/R_386_TLS_LE /i \   || (TYPE) == R_386_TLS_IE \\' \
                -i $PKG_PATH/bfd/elfxx-x86.h
            ../configure --prefix=/usr  \
                --enable-gold           \
                --enable-ld=default     \
                --enable-plugins        \
                --enable-shared         \
                --disable-werror        \
                --enable-64-bit-bfd     \
                --with-system-zlib
            CUR_MAKE_JOBS=$(echo _LFS_BUILD_PROC - 1 | bc)
            make -j$CUR_MAKE_JOBS tooldir=/usr && make -j$CUR_MAKE_JOBS -k check && make tooldir=/usr install
            if [ $? = 0 ]; then
                rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=gmp
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --enable-cxx            \
                --disable-static        \
                --docdir=/usr/share/doc/gmp
            make -j_LFS_BUILD_PROC && make html && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check 2>&1 | tee gmp-check-log
            awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log
            make install
            make install-html
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
