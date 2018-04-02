#!/usr/bin/env bash

if [ -z "$1" ];then
  exec echo -e "

Build khs1994-docker/lnmp deb or rpm

Usage:

$ cli/build.sh deb \${TAG}

$ cli/build.sh rpm \${TAG}

Example:

$ cli/build.sh deb v18.05

$ cli/build.sh rpm v18.06-rc1

"
fi

set -ex

if [ -f khs1994-robot.enc ];then exit 1; fi

_deb(){
  cd cli/deb

  sed -i "s#KHS1994_DOCKER_VERSION#${VERSION}#g" DEBIAN/control

  rm -rf data/.gitignore data/* README.md

  # https://github.com/khs1994-docker/lnmp/archive/v18.05.tar.gz
  # wget -O lnmp.tar.gz https://github.com/khs1994-docker/lnmp/archive/v${VERSION}.tar.gz

  # tar -zxvf lnmp.tar.gz ; mv lnmp-${VERSION} data/lnmp

  git clone -b v${VERSION} --depth=1 --recursive https://github.com/khs1994-docker/lnmp.git data/lnmp

  # rm git

  sudo rm -rf data/lnmp/.git

  sudo rm -rf data/lnmp/config/nginx/.git

  sudo rm -rf data/lnmp/config/httpd/.git

  sudo rm -rf data/lnmp/app/demo/.git

  chmod -R 755 DEBIAN

  cd .. ; dpkg-deb -b deb khs1994-docker-lnmp_${VERSION}_amd64.deb
}

_rpm(){
  cd cli/rpm

  sed -i "s#KHS1994_DOCKER_VERSION#${VERSION}#g" DEBIAN/control

  rm -rf data/.gitignore data/* README.md

  # wget -O lnmp.tar.gz https://github.com/khs1994-docker/lnmp/archive/v${VERSION}.tar.gz

  # tar -zxvf lnmp.tar.gz ; mv lnmp-${VERSION} data/lnmp

  cd .. ; rpmbuild -bb --target=amd64 SPECS/codeblocks.spec
}

command=$1

VERSION=$( echo $2 | cut -d "v" -f 2 )

shift

_$command $VERSION
