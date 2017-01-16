property :admin_user, String
property :admin_password, String
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'

property :credentials, String
property :host, String
property :label, String
property :description, String, default: 'Description'

## remove hardcode like home etc.
action :create do
  groovy_code_lib = """
    import jenkins.model.*
    import hudson.model.*
    import hudson.slaves.*
    import hudson.plugins.sshslaves.*
    import java.util.ArrayList;
    import hudson.slaves.EnvironmentVariablesNodeProperty.Entry;

      List<Entry> env = new ArrayList<Entry>();
      env.add(new Entry(\\\"key1\\\",\\\"value1\\\"))
      env.add(new Entry(\\\"key2\\\",\\\"value2\\\"))
      EnvironmentVariablesNodeProperty envPro = new EnvironmentVariablesNodeProperty(env);
      Slave slave = new DumbSlave(
                    \\\"#{name}\\\",\\\"#{description}\\\",
                    \\\"/Users/jenkins\\\",
                    \\\"1\\\",
                    Node.Mode.NORMAL,
                    \\\"#{label}\\\",
                    new SSHLauncher(\\\"#{host}\\\",22,\\\"#{credentials}\\\",
                                    \\\"\\\",\\\"\\\",\\\"\\\",\\\"\\\",
                                    0,0,0),
//https://go.cloudbees.com/docs/support-kb-articles/CloudBees-Jenkins-Enterprise/Start-and-stop-EC2-instances-from-Pipeline.html
                    new RetentionStrategy.Always(),
                    new LinkedList())
      slave.getNodeProperties().add(envPro)
      Jenkins.instance.addNode(slave)  
  """
  
  groovy_code =   """
  echo \"
    #{groovy_code_lib}
  \"  """
  
  puts(groovy_code)
  
  jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url} groovy = --username=#{admin_user} --password=#{admin_password}"

  cmd = "#{groovy_code} | #{jenkins_cli}"
  res = `#{cmd}`
end


action :delete do
  puts("Not implemented")
end
