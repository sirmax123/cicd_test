def createAllInOneEnvJobName = "create_all_in_one_env"

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
                        $class: 'StringParameterDefinition',
                        defaultValue: createAllInOneEnvJobName, 
                        description: 'Job Name', 
                        name: 'ArtifactSourceJobName'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: '', 
                        description: 'Build Number (Last succesful build will be used if not set)', 
                        name: 'ArtifactSourceBuildNumber'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'workspace.link', 
                        description: '', 
                        name: 'ArtifactSourceFilter'
                    ]

                ]
        ],
        pipelineTriggers([])
    ]
)

println("====== DEBUG START ========")
println("ArtifactSourceJobName = " + ArtifactSourceJobName.toString())
println("ArtifactSourceBuildNumber = " + ArtifactSourceBuildNumber.toString())
println("====== DEBUG END ==========")

node("vagrant") {

	stage("Cleanup") {
		step([$class: 'WsCleanup']) 
	}

    stage("Copy Artifact From Jenkins") {
   
        if  (ArtifactSourceBuildNumber ==~ /\d+/  ) {
            println("ArtifactSourceBuildNumber is set.")
            CopyArtifactSelector = [
                $class: 'SpecificBuildSelector',
                buildNumber: ArtifactSourceBuildNumber
            ]
        } else {
           println("ArtifactSourceBuildNumber is NOT set, use LastCompletedBuildSelector")
           CopyArtifactSelector = [ $class: 'LastCompletedBuildSelector']
           ArtifactSourceBuildNumber = 'LastCompletedBuild'
        }


        step(
            [
                $class: 'CopyArtifact',
                projectName: ArtifactSourceJobName,
                filter: ArtifactSourceFilter,
                selector: CopyArtifactSelector
            ]
        );
    } // end stage("Copy Artifact From Jenkins")
    
    stage("Destroy Vagrant Env") {
    	println("====== DEBUG START ========")
    	sh "ls " + env.WORKSPACE +"/" + ArtifactSourceFilter
    	sh "cat " + env.WORKSPACE +"/" + ArtifactSourceFilter
    	
    	// dir() and File  does not work correctly on mac os  so need try/catch
    	// need to find better workaround


    	try {
    		String fileContents = new File(env.WORKSPACE +"/" + ArtifactSourceFilter).text
    		println(fileContents)
    	} catch (Exception err) {
    		println(err)
    		fileContents =  sh(script: "cat " + env.WORKSPACE +"/" + ArtifactSourceFilter, returnStdout: true)
    	}
    	println(fileContents)
    	println("====== DEBUG END ==========")

    	withEnv(['PATH=${PATH}:/usr/local/bin']) {
        	try {
        		dir(fileContents.trim() + "/stage2/jenkins_jobs/all_in_one_node/"){
        			sh "vagrant destroy --force"
        		}	
        	} catch (Exception err) {
        		println("Error found")
        		println(err)
	        	sh "cd " + fileContents.trim() + "/stage2/jenkins_jobs/all_in_one_node/ " + " && vagrant destroy --force"
        	}
    	}
	} // end of stage("Destroy Vagrant Env")
}



//job_name = 'add_dynamic_slave'
//i = 0
//jobs = Jenkins.instance.getAllItems()
//
//
//println(Jenkins.instance.getJob(job_name).lastBuild);
//
//for (job in jobs) {
////	println(job)
//	if (job.name == job_name ) {
//		println(job)
//		lastBuild = job.getLastBuild()
//		println(lastBuild)
//		lastSuccessfulBuild = job.getLastSuccessfulBuild()
//		println(lastSuccessfulBuild)
//		println(lastSuccessfulBuild.result)
//		i = 1
////		lastSuccessfulBuild.properties.each { p -> 
////			println("==== " + i.toString() + "=======")
////			println(p)
////			i = i + 1
////		}
//
////		i = 1
////		lastSuccessfulBuild.properties.environment.each { e-> 
//
////			println("----" + i.toString() + "----")	
////			println(e)
////			i = i + 1
////		}
//		for (k in lastSuccessfulBuild.properties.environment) {
//			println(k)
//		}
//		for (kk in lastSuccessfulBuild.properties) {
//			println(kk)
//		}
//
//		println(lastSuccessfulBuild.workspace.toString())
//
//	}
//}
