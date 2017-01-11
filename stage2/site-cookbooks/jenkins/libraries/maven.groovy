//import jenkins.model.*;
//import jenkins.*
//import jenkins.model.*
//import hudson.*
//import hudson.model.*
//
//a=Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0];
//
//b=(a.installations as List);
//out.println(b)
//b.add(new hudson.tasks.Maven.MavenInstallation("MAVEN3", "", []));
//
//a.installations=b
//
//a.save()
//out.println(b)
//


import hudson.tasks.Maven.MavenInstallation;
import hudson.tools.InstallSourceProperty;
import hudson.tools.ToolProperty;
import hudson.tools.ToolPropertyDescriptor;
import hudson.util.DescribableList;
import jenkins.model.*

def mavenDesc =            Jenkins.instance.getExtensionList(hudson.tasks.Maven.DescriptorImpl.class)[0]

out.println(mavenDesc)

def isp = new InstallSourceProperty()
def autoInstaller = new hudson.tasks.Maven.MavenInstaller("3.3.9")
isp.installers.add(autoInstaller)
//
def proplist = new DescribableList<ToolProperty<?>, ToolPropertyDescriptor>()
proplist.add(isp)
//
def installation = new MavenInstallation("M32", "", proplist)
//
println(mavenDesc.installations.getClass())

def installations = (mavenDesc.installations as List);
installations.add(installation)
out.println(installations)


mavenDesc.installations = installations
mavenDesc.save()
