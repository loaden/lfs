#!/bin/bash
# QQ群：111601117、钉钉群：35948877

# step1
# 完成环境检测、挂载、lfs纯净环境创建和源码下载与校验
#

echo KILL 01-version-check.sh ...
bash `dirname ${BASH_SOURCE[0]}`/../01-version-check.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo KILL 02-mount.sh ...
bash `dirname ${BASH_SOURCE[0]}`/../02-mount.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo KILL 03-dir-users.sh ...
bash `dirname ${BASH_SOURCE[0]}`/../03-dir-users.sh
[ $? = 0 ] || exit 2
echo DONE
echo

echo KILL 04-prepare-srcs.sh ...
bash `dirname ${BASH_SOURCE[0]}`/../04-prepare-srcs.sh
[ $? = 0 ] || exit 2
echo DONE
echo
