yum install -y rpm-build rpmdevtools readline-devel ncurses-devel gdbm-devel tcl-devel openssl-devel db4-devel byacc libyaml-devel libffi-devel make
rpmdev-setuptree
cd ~/rpmbuild/SOURCES
RUBY_VER=ruby-1.9.3
RUBY_SUBVER=p545
wget http://ftp.ruby-lang.org/pub/ruby/1.9/${RUBY_VER}-${RUBY_SUBVER}.tar.gz
cd ~/rpmbuild/SPECS
wget https://raw.github.com/imeyer/${RUBY_VER}-rpm/master/ruby19.spec
rpmbuild -bb ruby19.spec
ARCH=`uname -m`
KERNEL_REL=`uname -r`
KERNEL_TMP=${KERNEL_REL%.$ARCH}
DISTRIB=${KERNEL_TMP##*.}
yum -y localinstall ~/rpmbuild/RPMS/${ARCH}/${RUBY_VER}${RUBY_SUBVER}-1.${DISTRIB}.${ARCH}.rpm



