#!/bin/bash


set -x

clone_repo()
{
    git clone https://github.com/gdelprete/rpm-tomcat8.git
}

cleanup(){
  rm -rf ${TMP_DIR}
}


TMP_DIR=`mktemp -d`

pushd ${TMP_DIR}
pwd
clone_repo

pushd "./rpm-tomcat8"
# remove publishing
sed -i  's/publish-rpm/#publish-rpm/g' make_rpm.sh
./make_rpm.sh
rpm -Uvh rpmbuild/RPMS/noarch/*.rpm
popd
popd

cleanup


