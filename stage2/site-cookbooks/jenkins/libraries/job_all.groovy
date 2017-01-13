def buildJobName = 'test'
def publishJobName = 'up'

def defaultRepoName = 'git@10.0.1.11:cicd/petclinic.git'
def defaultBranchName = 'master'

node("master") {

	stage("BUILD"){
		buildArtifact = build(
			job: buildJobName,
	    	parameters:
	        	[
	            	[
	                	$class: 'StringParameterValue',
	                	name: 'repoName',
	                	value: defaultRepoName
	            	],
	            	[
	                	$class: 'StringParameterValue',
	                	name: 'branchName',
	                	value: defaultBranchName
	            	]

	        	]
	    	)
	}

	println(buildArtifacts.getId())
	println(buildArtifacts.getNumber())

}