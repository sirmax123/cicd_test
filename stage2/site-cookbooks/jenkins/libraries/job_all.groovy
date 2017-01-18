// Pre-defined
def defaultRepoName = "git@10.0.1.11:cicd/petclinic.git"
def defaultBranchName = "master"


def buildJobName = "test"
def publishJobName = "up"
def createAllInOneEnvJobName = "create_all_in_one_env"
def destroyAllInOneEnvJobName = "destroy_all_in_one_node"
def registerSlaveJobName = "add_dynamic_slave"
def slaveTestJobName = "test_slave"
def deleteSlaveJobName = "delete_slave"
def deployTomcatJobName = 'deploy_tomcat'
def deployPetclinincJobName = 'deploy_petclininc'


/////



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
        ],
        [
            $class: 'ParametersDefinitionProperty', 
             parameterDefinitions: 
                [

                    [
                        $class: 'ChoiceParameterDefinition', 
                        choices: "Leave as is\nDestroy\n",
                        description: 'If deployment is successful, what to do with env? ', 
                        name: 'doDestroyonSuccess'
                    ],
                    [
                        $class: 'ChoiceParameterDefinition', 
                        choices: "Leave as is (for debug)\nDestroy failed env\nAsk\nAsk with 5 min timeout (Destroy if no reply in timeout)\n",
                        description: 'If deployment failed what to do with env?', 
                        name: 'doDestroy'
                    ]
                ]
        ],        
    ]
)




def choice = new ChoiceParameterDefinition(
                                    'Destroy failed env?',
                                    "yes\nno\n",
                                    '')

def destroySelector = ''


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

		publishArtifact = ''
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
		                	value: buildArtifact.getNumber().toString()
		            	]
		        	]
		    	)
		} //end stage("publishNexus")
		
		stage("Create All-In-One Env") {
			allInOneEnvBuild = build(job: createAllInOneEnvJobName)
		} // end of Create  All-In-One Env
	
		//Even if next steps will failed we need to destroy created env
		// so need "try block"
	
		try {
			stage("Register All-In-One Env as Slave Node") {
				allInOneEnvSlaveBuild = build(job: registerSlaveJobName)
			} //end of Register All-In-One Env as Slave Node
	

			stage("Do New-Registerd Slave Test") {
				slaveTestBuild = build(slaveTestJobName)
			}
	

			stage("Deploy Tomcat") {
				println("Not Implemented. In Progress")
				deployTomcatBuild = build(job: deployTomcatJobName)
			}

	
			stage("Deploy Petclininc") {
				
				deployPetclinicBuild = build(
											job: deployPetclinincJobName,
        									parameters:
        									[
            									[
                									$class: 'StringParameterValue',
                									name: 'ArtifactSourceBuildNumber',
                									value: buildArtifact.getNumber().toString()
            									]
        									]
											)
			}
		
			stage("Do Tests") {
				println("Do simple tests")
				// expect to get 404 on get /
				timeout(5){
					sh """
					while true;
					do
						curl -v  http://10.0.10.200/ 2>&1 | grep --color 'HTTP/1.1 404 Not Found' && break
						sleep 5
					done
					"""

				}

				// expect to get 200 on get /petclinic/vets.html
				timeout(5){
					sh """
					while true;
					do
						curl -v  http://10.0.10.200/petclinic/vets.html 2>&1 | grep --color 'HTTP/1.1 200 OK' && break
						sleep 5
					done
					"""
				}
			}
			stage("More Tests"){

				println("Place more tests here")

			}
			// Check what to do with succesfull deployment
			switch (doDestroyOnSuccess) {
				case 'Leave as is':
				    destroySelector = 'no'
				break

				case 'Destroy':
					destroySelector = 'yes'
				break
			}

				
		}
		catch(Exception e) {
			println(e)

			stage("Ask What to do next") {

				switch (doDestroy) {
				    case 'Ask':

				        destroySelector = input(
				            message: 'message',
				            parameters: [choice],
				            id: 'destroySelectorId'
				        )    
				    break
				
				    case 'Ask with 5 min timeout (Destroy if no reply in timeout)':

				    	try {
				    	
				        	timeout(5) {
				        		destroySelector = input(
				                						message: 'message',
				                						parameters: [choice],
				            							id: 'destroySelectorId'
				                						)
				        	}
				    	}

				    	catch(Exception err1) {
				    		destroySelector = 'yes'
				    		println(err1)
				    	}
				    break
				
				    case 'Leave as is (for debug)':
						destroySelector = 'no'
					break
				
				    case 'Destroy failed env':
				        destroySelector = 'yes'
				    break
				}// end swotch    
			} //  end stage("Ask What to do next") 
		// end catch
		} finally {

			if (destroySelector == 'yes') {
				println("")
	
				stage("Unregister slave") {
					println("Unregister Slave")
					deleteSlaveBuild = build(job: deleteSlaveJobName)
				}
							
				stage("Destoy All-In-One") {
					println("Destroy env")
					destroyAllInOneEnvBuild = build(job: destroyAllInOneEnvJobName)
				}

				stage("Fail this build"){
					currentBuild.result = 'FAILURE'
				}
			} //end if
		} // end fianlly
	} // end wrapper
} // end node 
