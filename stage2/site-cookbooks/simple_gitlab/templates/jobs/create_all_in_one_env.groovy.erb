defaultRepoName = 'https://github.com/sirmax123/cicd_test.git'
defaultBranchName = 'master'


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
        [
            $class: 'ParametersDefinitionProperty', 
             parameterDefinitions: 
                [
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: defaultBranchName , 
                        description: 'Branch Name', 
                        name: 'branchName'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: defaultRepoName,
                        description: 'Source Repo', 
                        name: 'repoName'
                    ]
          		]
        ],
		disableConcurrentBuilds(), 
		[
			$class: 'JobRestrictionProperty'
		], 
		pipelineTriggers([])]
)

import org.apache.commons.lang.StringUtils

// Const
def artifactName = 'workspace.link'

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

	stage("Prepere File") {
	// Create File	
		artifactFileName = env.WORKSPACE.toString() + "/" + artifactName
		println(artifactFileName)
		sh "ls " +  env.WORKSPACE.toString() + "/" 
		sh "echo  " + env.WORKSPACE.toString() + " >> " + artifactFileName
	}


    stage("Run Vagrant"){
    	dir("stage2/jenkins_jobs/all_in_one_node") {
        	sh "pwd" 
        	sh "ls -lsa"
        	sh "id"
        	sh "whoami"
        	
        	withEnv(['PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/usr/local/bin']) {

        		vmList = sh script: "VBoxManage list  vms", returnStdout: true
        		println("vmList = " + vmList)


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
        			println(err)
        			sh "vagrant destroy --force"
        			println("-----")
        			vmList_vagrant_destroy = sh script: "VBoxManage list  vms", returnStdout: true
        			println("vmList_vagrant_destroy = \n" + vmList_vagrant_destroy)
        			vmList_diff = StringUtils.difference(vmList_vagrant_destroy, vmList);
        			println("vmList_diff = \n" + vmList_diff)
        			println("-----")
        			

        			currentBuild.result = 'FAILURE'

        		}
        	} //end withEnv
        } // end dir 
    } //end Stage Run Vagrant

	stage('Publish Artifact To Jenkins') {
		step(
			[
 				$class: 'ArtifactArchiver', 
 				artifacts: artifactName, 
 				fingerprint: true
			],
		)
	}        			
}