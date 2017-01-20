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
                        defaultValue: 'build_tomcat', 
                        description: 'Job Name', 
                        name: 'ArtifactSourceJobName'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: '', 
                        description: 'Build Number (Last succesful build will be used if not set)', 
                        name: 'ArtifactSourceBuildNumber'
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


def ArtifactSourceFilter = 'rpmbuild/RPMS/noarch/tomcat8*noarch.rpm'

node("dynamic-slave") {
	
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

			// println(Jenkins.instance.getJob(ArtifactSourceJobName).lastSuccessfulBuild);
			// Build tomcat if not built before
			if ( ! Jenkins.instance.getJob(ArtifactSourceJobName).lastSuccessfulBuild ) {
				tomcatBuild = build(ArtifactSourceJobName)
			}

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

    stage("Install Tomcat") {
    	sh """
    		rpm -qa | grep tomcat8 || \
    		yum \
    		-y install \
    		rpmbuild/RPMS/noarch/tomcat8-8.0.24-1.noarch.rpm
        	"""
    }
    stage("Add tomcat to autostart") {
    	sh "chkconfig"
    	println("===================")
    	sh "chkconfig | grep tomcat8"
    	println("===================")
    	sh "chkconfig tomcat8 on"
    	println("===================")
    	sh "chkconfig | grep tomcat8"
    	println("===================")

    }

    stage("Start Tomcat") {
    	sh """
    	   service  tomcat8 start
    	   """
    }

}