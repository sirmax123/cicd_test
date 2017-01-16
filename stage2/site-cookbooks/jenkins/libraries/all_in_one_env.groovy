repoName = 'https://github.com/sirmax123/cicd_test.git'
branchName = 'master'


properties(
	[
		[
			$class: 'BuildDiscarderProperty', 
			strategy: 
				[
					$class: 'LogRotator', 
					artifactDaysToKeepStr: '3', 
					artifactNumToKeepStr: '3', 
					daysToKeepStr: '3', 
					numToKeepStr: '3'
				]
		], 
		disableConcurrentBuilds(), 
		[
			$class: 'JobRestrictionProperty'
		], 
		pipelineTriggers([])]
)

import org.apache.commons.lang.StringUtils



node("vagrant"){
	stage("Cleanup") {
		step([$class: 'WsCleanup']) 
	}

	stage ('git checkout') {
		checkout(
		   [
		       $class: 'GitSCM',
		       branches: [[name: "${branchName}"]],
		       doGenerateSubmoduleConfigurations: false,
		       extensions: [],
		       submoduleCfg: [],
		       userRemoteConfigs:
		       [
		           [
//		               credentialsId: "${repoCreds}",
		               url: "${repoName}",
		               poll: true
		           ]
		       ]
		   ]
		)
	}
    stage("test"){
    	dir("stage2/jenkins_jobs/all_in_one_node") {
        	sh "pwd; ls -lsa; id; whoami"
        	withEnv(['PATH=${PATH}:/usr/local/bin']) {

        		vmList = sh script: "VBoxManage list  vms", returnStdout: true
        		println(vmList)


        		sh "vagrant plugin install vagrant-hosts"
        		sh "vagrant plugin install vagrant-vbguest"
        		try {
        			sh "vagrant up"
        			vmList_vagrant_up = sh script: "VBoxManage list  vms", returnStdout: true
        			println("vmList_vagrant_up = " + vmList_vagrant_up)
        			println("vmList = " + vmList)
        			vmList_diff = StringUtils.difference(vmList_vagrant_up, vmList);
        			println("vmList_diff = " + vmList_diff)

			    } catch (Exception err) {
        			println("Error found")
        			//sh "vagrant destroy --force"
        			println("-----")
        			vmList_vagrant_destroy = sh script: "VBoxManage list  vms", returnStdout: true
        			println("vmList_vagrant_destroy = \n" + vmList_vagrant_destroy)
        			vmList_diff = StringUtils.difference(vmList_vagrant_destroy, vmList);
        			println("vmList_diff = \n" + vmList_diff)
        			println("-----")
        			

        			currentBuild.result = 'FAILURE'

        		}
        	}
        }
   }
}