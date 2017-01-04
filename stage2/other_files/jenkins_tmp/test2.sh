echo '
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("root","r00tme")

hudsonRealm.createAccount("root1","r00tme")


instance.setSecurityRealm(hudsonRealm)

strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)


instance.save()





Jenkins.instance.pluginManager.plugins.each{
    plugin -> 
	println ("${plugin.getDisplayName()} (${plugin.getShortName()}): ${plugin.getVersion()}")
}


println "Running plugin enumerator"
println ""
def plugins = jenkins.model.Jenkins.instance.getPluginManager().getPlugins()
plugins.each {println "${it.getShortName()} - ${it.getVersion()}"}
println ""
println "Total number of plugins: ${plugins.size()}"
' |  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://10.0.1.10:8080/ groovy = --username=root --password=r00tme


#http://pghalliday.com/jenkins/groovy/sonar/chef/configuration/management/2014/09/21/some-useful-jenkins-groovy-scripts.html#appendix