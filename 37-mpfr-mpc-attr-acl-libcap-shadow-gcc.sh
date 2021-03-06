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
    PKG_NAME=mpfr
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --disable-static        \
                --enable-thread-safe    \
                --docdir=/usr/share/doc/mpfr
            make -j_LFS_BUILD_PROC && make html && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            if [ $? = 0 ]; then
                make install
                make install-html
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=mpc
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --disable-static        \
                --docdir=/usr/share/doc/mpc
            make -j_LFS_BUILD_PROC && make html && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            if [ $? = 0 ]; then
                make install
                make install-html
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=attr
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --disable-static        \
                --sysconfdir=/etc       \
                --docdir=/usr/share/doc/attr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=acl
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr   \
                --disable-static        \
                --docdir=/usr/share/doc/acl
            make -j_LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=libcap
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i '/install -m.*STA/d' libcap/Makefile
            make -j_LFS_BUILD_PROC prefix=/usr lib=lib && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC test && make prefix=/usr lib=lib install
            if [ $? = 0 ]; then
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=shadow
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i 's/groups$(EXEEXT) //' src/Makefile.in
            find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
            find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
            find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;
            sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
                -e 's:/var/spool/mail:/var/mail:'                 \
                -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                \
                -i etc/login.defs

            touch /usr/bin/passwd
            ./configure --sysconfdir=/etc   \
                --disable-static            \
                --with-group-name-max-length=32
            make -j_LFS_BUILD_PROC && make exec_prefix=/usr install && make -C man install-man
            if [ $? = 0 ]; then
                pwconv && grpconv
                [ $? = 0 ] || exit 99
                sed -i '/MAIL/s/yes/no/' /etc/default/useradd
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=gcc
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_3/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_3
        pushd $PKG_PATH
            rm -rfv mpfr mpc gmp
            sed -e '/static.*SIGSTKSZ/d' \
                -e 's/return kAltStackSize/return SIGSTKSZ * 4/' \
                -i libsanitizer/sanitizer_common/sanitizer_posix_libcdep.cpp
            case $(uname -m) in
                x86_64)
                    sed -e '/m64=/s/lib64/lib/' \
                        -i.orig gcc/config/i386/t-linux64
                ;;
            esac

            cd build_3
            ../configure --prefix=/usr   \
                LD=ld                    \
                --enable-languages=c,c++ \
                --disable-multilib       \
                --disable-bootstrap      \
                --with-system-zlib

            make -j_LFS_BUILD_PROC || exit 99
            ulimit -s 32768
            chown -Rv tester .
            su tester -c "PATH=$PATH make -j_LFS_BUILD_PROC -k check"
            ../contrib/test_summary | grep -A7 Summ
            read -p "查看GCC测试结果，任意键继续..."
            make install
            rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/11.2.0/include-fixed/bits/
            if [ $? = 0 ]; then
                chown -v -R root:root \
                    /usr/lib/gcc/*linux-gnu/11.2.0/include{,-fixed}
                ln -svr /usr/bin/cpp /usr/lib
                ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/11.2.0/liblto_plugin.so \
                    /usr/lib/bfd-plugins/
                echo 'int main(){}' > dummy.c
                cc dummy.c -v -Wl,--verbose &> dummy.log
                readelf -l a.out | grep ': /lib'
                grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
                read -p "gcc 应该找到所有三个 crt*.o 文件，它们应该位于 /usr/lib 目录中，任意键继续..."

                grep -B4 '^ /usr/include' dummy.log
                grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
                grep "/lib.*/libc.so.6 " dummy.log
                grep found dummy.log
                read -p "耐心的检查日志..."

                rm -v dummy.c a.out dummy.log
                mkdir -pv /usr/share/gdb/auto-load/usr/lib
                mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
