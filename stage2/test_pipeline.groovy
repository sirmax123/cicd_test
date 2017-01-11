properties(
    [
        [
            $class: 'JobRestrictionProperty'
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
                    ],
                   [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'petclinic-war', 
                        description: 'artifactId', 
                        name: 'artifactId'
                    ],
                   [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'petclinic-group-id', 
                        description: 'groupId', 
                        name: 'groupId'
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


//
//try {
//    upstreamBuildName =  currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause).properties.upstreamProject
//    upstreamBuildNumber =  currentBuild.rawBuild.getCause(hudson.model.Cause$UpstreamCause).properties.upstreamBuild
//
//
//    println(upstreamBuildName)
//    println(upstreamBuildNumber)
//    
//    currentBuild.displayName = "${env.BUILD_NUMBER}-${upstreamBuildName}-${upstreamBuildNumber}"
//    currentBuild.description = "${env.BUILD_NUMBER}-${upstreamBuildName}-${upstreamBuildNumber}"
//}
//catch (java.lang.NullPointerException e) {
//    println("No upstream job found")
//    
//}



try {
    specificCause = currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause).properties
//    currentBuild.description = ${env.BUILD_NUMBER}-${upstreamBuildName}
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

        def pom = readMavenPom file:  "pom.xml"
        println("==============")
        println(pom)
        println("==============")

        withMaven(maven: 'M3') 
        {

            // Run the maven build


        
            sh "mvn clean install"
        }

        step(
            [
                $class: 'ArtifactArchiver', 
                artifacts: '**/target/*.war', 
                fingerprint: true
            ]
        )
        //step($class: hudson.plugins.chucknorris.CordellWalkerRecorder)
        
        stage('Publish') {
            
            
        
        nexusPublisher nexusInstanceId: 'nexus', 
        nexusRepositoryId: 'test-repo4', 
        packages: 
        [
            [
                $class: 'MavenPackage', 
                mavenAssetList: 
                [
                    [
                        classifier: '', extension: '', filePath: 'target/petclinic.war'
                    ]
                ], 
                mavenCoordinate: 
                [
                    artifactId: artifactId, 
                    groupId: groupId, 
                    packaging: 'war', 
                    version: pom.version.toString() + "-" + env.BUILD_NUMBER.toString()                ]
            ]
        ]

   }
        
    }
}