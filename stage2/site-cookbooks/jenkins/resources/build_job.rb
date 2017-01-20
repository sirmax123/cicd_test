property :admin_user, String, default: ''
property :admin_password, String, default: ''
property :jenkins_url, String, default: 'http://127.0.0.1:8080/'

property :name, String

action :build do
  groovy_code_lib = """
    import hudson.model.*
    import hudson.AbortException
    import hudson.console.HyperlinkNote
    import java.util.concurrent.CancellationException

    def job = Hudson.instance.getJob('#{name}')
    def anotherBuild
    try {
        def future = job.scheduleBuild2(0)
        println \\\"Waiting for the completion of \\\" + HyperlinkNote.encodeTo('/' + job.url, job.fullDisplayName)
        anotherBuild = future.get()
    } catch (CancellationException x) {
        throw new AbortException(\\\"${job.fullDisplayName} aborted.\\\")
    }
    println HyperlinkNote.encodeTo('/' + anotherBuild.url, anotherBuild.fullDisplayName) + \\\" completed. Result was \\\" + anotherBuild.result
  """

  groovy_code =   """
  echo \"
    #{groovy_code_lib}
  \"  """
  
  puts(groovy_code)
  
  if admin_password.length > 0 && admin_user.length > 0
    jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url} groovy = --username=#{admin_user} --password=#{admin_password}"
  else
    jenkins_cli = get_jenkins_cli() + " -s #{jenkins_url} groovy = "
  end

  cmd = "#{groovy_code} | #{jenkins_cli}"
  res = `#{cmd}`
end


action :delete do
  puts("Not implemented")
end
