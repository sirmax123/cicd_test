repoName= 'https://github.com/sirmax123/cicd_test.git'
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
        		sh "vagrant plugin install vagrant-hosts"
        		sh "vagrant plugin install vagrant-vbguest"
        		sh "vagrant up"
        	}
        }
   }
}