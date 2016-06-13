#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}

for component in autodock autogrid ; do
  echo "checking $component"
  cd ${WORKSPACE}/src/${component}/build-${BUILD_NUMBER}
  make check
  echo $?
  make install
done

mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       AUTODOCK_SUITE_VERSION       $VERSION
setenv       AUTODOCK_SUITE_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$::env(GCC_VERSION)
prepend-path LD_LIBRARY_PATH   $::env(AUTODOCK_SUITE_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(AUTODOCK_SUITE_DIR)/include
prepend-path CFLAGS            "-I${AUTODOCK_SUITE_DIR}/include"
prepend-path LDFLAGS           "-L${AUTODOCK_SUITE_DIR}/lib"
prepend-path PATH              $::env(AUTODOCK_SUITE_DIR)/bin
MODULE_FILE
) > modules/$VERSION-gcc-${GCC_VERSION}

mkdir -p ${CHEMISTRY_MODULES}/${NAME}
cp modules/$VERSION-gcc-${GCC_VERSION} ${CHEMISTRY_MODULES}/${NAME}/

module add ${NAME}/${VERSION}-gcc-${VERSION}
which autodock4
autodock4 --version

which autogrid4
autogrid4 --version
