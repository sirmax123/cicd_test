


for P in `cat my_plugins_uniq`
do
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://10.0.1.10:8080/ install-plugin "${P}" --username=root --password=r00tme
done


#http://pghalliday.com/jenkins/groovy/sonar/chef/configuration/management/2014/09/21/some-useful-jenkins-groovy-scripts.html#appendix