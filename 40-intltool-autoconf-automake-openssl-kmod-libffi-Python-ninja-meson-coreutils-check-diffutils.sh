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
    PKG_NAME=intltool
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            sed -i 's:\\\${:\\\$\\{:' intltool-update.in
            ./configure --prefix=/usr
            make && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=autoconf
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr
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
    PKG_NAME=automake
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr --docdir=/usr/share/doc/automake
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
    PKG_NAME=openssl
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./config --prefix=/usr    \
                --openssldir=/etc/ssl \
                --libdir=lib          \
                shared                \
                zlib-dynamic
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC test
            if [ $? = 0 ]; then
                sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
                make MANSUFFIX=ssl install
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=kmod
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr  \
                --sysconfdir=/etc      \
                --with-openssl         \
                --with-xz              \
                --with-zstd            \
                --with-zlib
            make -j_LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                for target in depmod insmod modinfo modprobe rmmod; do
                    ln -sfv ../bin/kmod /usr/sbin/$target
                done
                ln -sfv kmod /usr/bin/lsmod
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=elfutils
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr        \
                --disable-debuginfod         \
                --enable-libdebuginfod=dummy
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check
            if [ $? = 0 ]; then
                make -C libelf install
                install -vm644 config/libelf.pc /usr/lib/pkgconfig
                rm /usr/lib/libelf.a
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=libffi
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr  \
                --disable-static       \
                --with-gcc-arch=native \
                --disable-exec-static-tramp
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
    PKG_NAME=Python
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/build_2/_BUILD_DONE ]; then
        mkdir -pv $PKG_PATH/build_2
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr   \
                --enable-shared         \
                --with-system-expat     \
                --with-system-ffi       \
                --with-ensurepip=yes    \
                --enable-optimizations
            make -j_LFS_BUILD_PROC && make install
            if [ $? = 0 ]; then
                touch build_2/_BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=ninja
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            python3 configure.py --bootstrap
            if [ $? = 0 ]; then
                ./ninja ninja_test
                ./ninja_test --gtest_filter=-SubprocessTest.SetWithLots
                install -vm755 ninja /usr/bin/
                install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=meson
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            python3 setup.py build
            if [ $? = 0 ]; then
                python3 setup.py install --root=dest
                cp -rv dest/* /
                install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
                install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson
                touch _BUILD_DONE
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=coreutils
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            .autoreconf -fiv
            FORCE_UNSAFE_CONFIGURE=1 ./configure    \
                --prefix=/usr                       \
                --enable-no-install-program=kill,uptime
            make -j_LFS_BUILD_PROC || exit 99
            make NON_ROOT_USERNAME=tester check-root
            echo "dummy:x:102:tester" >> /etc/group
            chown -Rv tester .
            su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
            sed -i '/dummy/d' /etc/group
            make install
            if [ $? = 0 ]; then
                mv -v /usr/bin/chroot /usr/sbin
                mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
                sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd

pushd /sources/_LFS_VERSION
    PKG_NAME=check
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        tar -xpvf $(find . -maxdepth 1 -type f -name "$PKG_NAME-*.tar.*")
        PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE ]; then
        pushd $PKG_PATH
            ./configure --prefix=/usr --disable-static
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
    PKG_NAME=diffutils
    PKG_PATH=$(find . -maxdepth 1 -type d -name "$PKG_NAME-*")
    if [ -z $PKG_PATH ]; then
        exit 1
    fi

    if [ ! -f $PKG_PATH/_BUILD_DONE_2 ]; then
        pushd $PKG_PATH
            make distclean
            ./configure --prefix=/usr
            make -j_LFS_BUILD_PROC && make TESTSUITEFLAGS=-j_LFS_BUILD_PROC check && make install
            if [ $? = 0 ]; then
                touch _BUILD_DONE_2
            else
                pwd
                exit 1
            fi
        popd
    fi
popd
