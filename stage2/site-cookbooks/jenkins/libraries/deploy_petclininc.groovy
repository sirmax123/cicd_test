def uploadToNexusJobName = 'up'

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
                        defaultValue: uploadToNexusJobName, 
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
                        defaultValue: 'http://10.0.1.12:8081/', 
                        description: 'nexusIpAddress', 
                        name: 'nexusIpAddress'
                    ],

                ]
        ],
        pipelineTriggers([])
    ]
)

println("====== DEBUG START ========")
println("ArtifactSourceJobName = " + ArtifactSourceJobName.toString())
println("ArtifactSourceBuildNumber = " + ArtifactSourceBuildNumber.toString())
println("====== DEBUG END ==========")


def ArtifactSourceFilter = '*'

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

    stage("Download") {
    	println("Download")

// toDo - do in groovy way, not shell way 
        nexusArtifactLink = sh(
                                script: "cat nexus.link | sed 's#http://nexus:8081/#" + nexusIpAddress + "#g'",
                                returnStdout: true
                            )

        println("Link: " + nexusArtifactLink)
        sh(script: "wget " + nexusArtifactLink)
    }
    stage("Deploy") {
    	println("Deploy")
        sh "rm -rf /usr/share/tomcat8/webapps/petclinic*"
        sh "cp petclinic*.war /usr/share/tomcat8/webapps/petclinic.war"
    }

    stage("ReStart Tomcat") {
        timeout(3) {
            sh """
                while true;
                do
                    service  tomcat8 restart && break
                    sleep 3
                done
            """
        }
    }

    stage("Wait") {
        timeout(3) {
            sh """
            while true; 
            do
                test -f  /var/lib/tomcat8/webapps/petclinic/WEB-INF/classes/spring/data-access.properties && break || sleep 5
            done
            """
        }
    }


    stage("fix db config")
    sh """
    cat << EOF > /var/lib/tomcat8/webapps/petclinic/WEB-INF/classes/spring/data-access.properties
jdbc.initLocation=classpath:db/mysql/initDB.sql
jdbc.dataLocation=classpath:db/mysql/populateDB.sql


jpa.database=MYSQL



jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://127.0.0.1:3306/petclinic
jdbc.username=petclinic
jdbc.password=petclinic



jpa.showSql = true
EOF

sleep 15 
    """

    stage("ReStart Tomcat 2") {
        // try 3 min
        timeout(3) {
            sh """
                while true;
                do
                    service  tomcat8 stop && break
                done
            """
        }

        timeout(3) {
            sh """
                while true;
                do
                    service  tomcat8 start && break
                done
            """
        }


    }

    stage("Test It") {
        sh "curl -v http://127.0.0.1/petclinic/ "
    }
}