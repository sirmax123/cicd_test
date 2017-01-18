cat << EOF > /var/lib/tomcat8/webapps/petclinic/WEB-INF/classes/spring/data-access.properties
jdbc.initLocation=classpath:db/mysql/initDB.sql
jdbc.dataLocation=classpath:db/mysql/populateDB.sql


jpa.database=MYSQL



jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://127.0.0.1:3306/petclinic
jdbc.username=petclinic
jdbc.password=petclinic



jpa.showSql = true
EOF