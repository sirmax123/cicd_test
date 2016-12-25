#!/bin/bash

set -x


TMP_DIR=`mktemp -d`

pushd ${TMP_DIR}

git clone https://github.com/CloudBees-community/spring-petclinic.git

pushd spring-petclinic

sed -i  's#<!-- <dependency> <groupId>mysql</groupId> <artifactId>mysql-connector-java</artifactId> <version>${mysql.version}</version> </dependency> -->#<dependency> <groupId>mysql</groupId> <artifactId>mysql-connector-java</artifactId> <version>${mysql.version}</version> </dependency>#' pom.xml && \

sed -i "s#GRANT ALL PRIVILEGES ON petclinic.* TO pc@localhost IDENTIFIED BY 'pc';# #" src/main/resources/db/mysql/initDB.sql

mvn package && \
cp -f  /tmp/data-access.properties  src/main/resources/spring/data-access.properties && \
mvn package -Dmaven.test.skip=true && \
cp target/petclinic.war   /var/lib/tomcat8/webapps && \
service tomcat8 restart
popd
popd
