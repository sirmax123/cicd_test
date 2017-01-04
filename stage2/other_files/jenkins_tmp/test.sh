
echo 'hudson.security.AuthorizationStrategy$Unsecured'  |java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://10.0.1.10:8080/ groovy =



echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("user2", "password123")'  |java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://10.0.1.10:8080/ groovy =