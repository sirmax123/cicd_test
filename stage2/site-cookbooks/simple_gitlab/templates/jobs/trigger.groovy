


properties(
	[
		[
			$class: 'BuildDiscarderProperty', 
			strategy:
				[
					$class: 'LogRotator', artifactDaysToKeepStr: '3', artifactNumToKeepStr: '3', daysToKeepStr: '3', numToKeepStr: '3'
				]
		], 
		disableConcurrentBuilds(), 
    	pipelineTriggers(
    		[
        		[
        			$class: "SCMTrigger", scmpoll_spec: "H/1 * * * *"
        		],
    		]
		)
	]
)


// Pre-defined
def repoName = "git@10.0.1.11:cicd/petclinic.git"
def branchName = ""
def repoCreds = 'jenkins_main_ssh_key'



def defaultRepoName = "git@10.0.1.11:cicd/petclinic.git"
def defaultBranchName = "master"

// Vgrant File is stored in separate repo
def defaultAllInOneRepoName = 'https://github.com/sirmax123/cicd_test.git'
def defaultAllInOneBranchName = 'master'

// Dynamic slave params
def defaultSlaveIpAddress = '10.0.10.200'
def defaultSlaveCredentialsId = 'dynamic_slaves'
def defaultSlaveName = 'dynamic-slave'





def realBuildJobName = 'all'

node("master"){
	stage ('git checkout')
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
               		credentialsId: "${repoCreds}",
               		url: "${repoName}",
               		poll: true
           		]
       		]
    	]
	)


    buildAll = build(
		job: realBuildJobName,
		parameters:
			[

				[
				    $class: 'StringParameterValue', 
				    value: "Leave as is",
				    name: 'doDestroyonSuccess'
				],
				[
				    $class: 'StringParameterValue', 
				    value: "Leave as is (for debug)",

				    name: 'doDestroy'
				],
				[
				    $class: 'StringParameterValue', 
				    value: defaultBranchName , 
				    name: 'branchName'
				],
				[
				    $class: 'StringParameterValue', 
				    value: defaultRepoName,
				    name: 'repoName'
				],
				[
				    $class: 'StringParameterValue', 
				    value: defaultAllInOneBranchName , 
				    name: 'allInOneBranchName'
				],
				[
				    $class: 'StringParameterValue', 
				    value: defaultAllInOneRepoName,
				    name: 'allInOneRepoName'
				],
				[
				    $class: 'StringParameterValue', 
				    value: defaultSlaveIpAddress, 
				    name: 'slaveIpAddress'
				],
				[
				    $class: 'StringParameterValue', 
				    value: defaultSlaveCredentialsId, 
				    name: 'slaveCredentialsId'
				],
				[
				    $class: 'StringParameterValue',
				    value: defaultSlaveName, 
				    name: 'slaveName'
				]
			]    	
    	)
}