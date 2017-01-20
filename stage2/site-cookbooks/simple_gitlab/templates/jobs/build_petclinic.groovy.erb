properties(
    [
        [
            $class: 'JobRestrictionProperty'
        ],
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
                        defaultValue: 'master', 
                        description: 'Branch Name', 
                        name: 'branchName'
                    ],
                   [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'git@10.0.1.11:cicd/petclinic.git', 
                        description: 'Source Repo', 
                        name: 'repoName'
                    ]
                ]
        ], 
            pipelineTriggers([])
    ]
)

repoCreds = 'jenkins_main_ssh_key'

node ("master") {   
    step([$class: 'hudson.plugins.chucknorris.CordellWalkerRecorder'])
    wrap([$class: 'AnsiColorBuildWrapper', $class: 'TimestamperBuildWrapper']) {


        try {
            upstreamBuildName =  currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause).properties.upstreamProject
            upstreamBuildNumber =  currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause).properties.upstreamBuild
            println(upstreamBuildName)
            println(upstreamBuildNumber)
                
            currentBuild.displayName = "${env.BUILD_NUMBER}-UpstreamJob=${upstreamBuildName}-UpstreamBuildNumber=${upstreamBuildNumber}"
            currentBuild.description = currentBuild.displayName
        }
        catch (java.lang.NullPointerException e) {
            println("No upstream job found")    
        }



        try {
            specificCause = currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause).properties
            println(specificCause.userId)
            currentBuild.displayName = "${env.BUILD_NUMBER}-startedBy: ${specificCause.userId}"
            currentBuild.description = "${env.BUILD_NUMBER}-startedBy: ${specificCause.userId}"
        } 
        catch (java.lang.NullPointerException e) {
            println("No user found")
        }

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
        stage('Build')

//        def pom = readMavenPom file:  "pom.xml"
//
//        println("==============")
//        println(pom)
//        println("==============")

        withMaven(maven: 'M3') 
        {
            // Run the maven build 
            sh "sed -i  's#<!-- <dependency> <groupId>mysql</groupId> <artifactId>mysql-connector-java</artifactId> <version>\${mysql.version}</version> </dependency> -->#<dependency> <groupId>mysql</groupId> <artifactId>mysql-connector-java</artifactId> <version>\${mysql.version}</version> </dependency>#' pom.xml"
            sh "sed -i \"s#GRANT ALL PRIVILEGES ON petclinic.* TO pc@localhost IDENTIFIED BY 'pc';# #\" src/main/resources/db/mysql/initDB.sql"
            sh "mvn clean install"
        }

        stage('Publish Artifact To Jenkins')
        step(
            [
                $class: 'ArtifactArchiver', 
                artifacts: '**/target/*.war, pom.xml', 
                fingerprint: true
            ],
        )
    }
}
