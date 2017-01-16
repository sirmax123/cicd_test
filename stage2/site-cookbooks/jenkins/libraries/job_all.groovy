def buildJobName = 'test'
def publishJobName = 'up'

def defaultRepoName = 'git@10.0.1.11:cicd/petclinic.git'
def defaultBranchName = 'master'



properties(
    [
        [
            $class: 'BuildDiscarderProperty', 
            strategy: 
                [
                    $class: 'LogRotator', 
                    artifactDaysToKeepStr: '5', 
                    artifactNumToKeepStr: '5', 
                    daysToKeepStr: '5', 
                    numToKeepStr: '5'
                ]
        ]
    ]
)






node("master") {
	wrap([$class: 'AnsiColorBuildWrapper', $class: 'TimestamperBuildWrapper']) {

		step([$class: 'hudson.plugins.chucknorris.CordellWalkerRecorder'])
	
		def buildArtifact = ''
		def publishArtifact = ''

	
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
		} //end stage("BUILD")
	
		println(buildArtifact.getId())
		println(buildArtifact.getNumber())
		println(buildArtifact)


		stage("publishNexus"){
			publishArtifact = build(
				job: publishJobName,
		    	parameters:
		        	[
		            	[
		                	$class: 'StringParameterValue',
		                	name: 'ArtifactSourceJobName',
		                	value: buildJobName
		            	],
		            	[
		                	$class: 'StringParameterValue',
		                	name: 'ArtifactSourceBuildNumber',
		                	value: buildArtifact.getNumber()
		            	]
		        	]
		    	)
		} //end stage("publishNexus")
	} // end wrapper
} // end node 