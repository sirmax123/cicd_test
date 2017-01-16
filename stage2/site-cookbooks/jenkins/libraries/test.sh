echo "
  import jenkins.model.*
  import hudson.model.*
  import hudson.slaves.*
  import hudson.plugins.sshslaves.*
  import java.util.ArrayList;
  import hudson.slaves.EnvironmentVariablesNodeProperty.Entry;
    List<Entry> env = new ArrayList<Entry>();
    env.add(new Entry(\"key1\",\"value1\"))
    env.add(new Entry(\"key2\",\"value2\"))
    EnvironmentVariablesNodeProperty envPro = new EnvironmentVariablesNodeProperty(env);
    Slave slave = new DumbSlave(
                  \"agent-node\",\"Agent node description\",
                  \"/Users/jenkins\",
                  \"1\",
                  Node.Mode.NORMAL,
                  \"agent-node-label\",
                  new SSHLauncher(\"10.0.2.2\",22,\"SLAVE_USER_vagrant\"
                  ,\"\",\"\",\"\",\"\",
                  0,0,0),
                  new RetentionStrategy.Always(),
                  new LinkedList())
    slave.getNodeProperties().add(envPro)
    Jenkins.instance.addNode(slave)
" 
#| java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ groovy = --username=root --password=r00tme