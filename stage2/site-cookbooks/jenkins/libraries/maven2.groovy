import hudson.tasks.Maven.MavenInstallation;
import hudson.tools.InstallSourceProperty;
import hudson.tools.ToolProperty;
import hudson.tools.ToolPropertyDescriptor;
import hudson.util.DescribableList;
import jenkins.model.*


// Try to do this code idempotent (to be able to use it in chef)

def addMavenIfNotExist(String mavenName, String mavenVersion) {
// Workaround? Class name is depends on installation name and looks like
// MavenInstallation[<name here>], e.g. MavenInstallation[M3] if name of maven is M3

  expectedClassName = "MavenInstallation["+ mavenName + "]"


  def mavenDesc = jenkins.model.Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0]

  boolean isInstalled = false

  for ( currentInstallation in mavenDesc.installations ) {
    currentInstallationName = currentInstallation.toString()

    if (currentInstallationName == expectedClassName ) {
      //out.println("Alredy installed")
      isInstalled = true
      //out.println(isInstalled)
    }
    else {
      out.println("Not installed")
      //out.println(isInstalled)
    }
    //out.println("=======================")
    //out.println(currentInstallation.getProperties().toString())
  }


  //out.println(isInstalled)
  if (! isInstalled) {
    out.println('Installing')
    def currentInstallSourceProperty = new InstallSourceProperty()
    def autoInstaller = new hudson.tasks.Maven.MavenInstaller("3.3.9")
    currentInstallSourceProperty.installers.add(autoInstaller)
    //
    def proplist = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
    proplist.add(currentInstallSourceProperty)
    //
    def installation = new MavenInstallation(mavenName, "", proplist)
    def installations = (mavenDesc.installations as List);
    installations.add(installation)
    out.println(installations)


    mavenDesc.installations = installations
    mavenDesc.save()
  } else {
    out.println('Maven ' + mavenName + ' already installed')
  }
}

addMavenIfNotExist('M33333', '3.3.3')