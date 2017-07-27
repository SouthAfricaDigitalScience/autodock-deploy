#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
module  add gcc/${GCC_VERSION}
echo ${SOFT_DIR}
echo "All tests have passed, will now build into ${SOFT_DIR}"
for component in autodock autogrid ; do

  echo "building $component"
  mkdir -p ${WORKSPACE}/src/${component}/build-${BUILD_NUMBER}
  cd ${WORKSPACE}/src/${component}/build-${BUILD_NUMBER}
  rm -rf
  ../configure --prefix=${SOFT_DIR}-gcc-${GCC_VERSION}
  make
  make install
done
echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${CHEMISTRY}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/autodock-deploy"
module add gcc/${GCC_VERSION}
setenv AUTODOCK_SUITE_VERSION       $VERSION
setenv AUTODOCK_SUITE_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$::env(GCC_VERSION)
prepend-path PATH              $::env(AUTODOCK_SUITE_DIR)/bin
MODULE_FILE
) > ${CHEMISTRY}/${NAME}/${VERSION}-gcc-${GCC_VERSION}


echo "checking the modulefile add"
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
for executable in autodock4 autogrid4 ; do
  echo "checking pat for $executable"
  which $executable
  echo "checking $excutable executable"
  $executable --version
done
