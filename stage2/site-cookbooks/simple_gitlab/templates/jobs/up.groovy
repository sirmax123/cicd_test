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
                        defaultValue: 'test', 
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
                        defaultValue: 'target/*.war, pom.xml', 
                        description: 'Source Filter', 
                        name: 'ArtifactSourceFilter'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'nexus:8081/nexus', 
                        description: 'Nexus Server Address (see /etc/hosts for "nexus" IP address)', 
                        name: 'NexusURL'
                    ],
                    [
                        $class: 'ChoiceParameterDefinition', 
                        choices: "http\nhttps\n",
                        description: 'protocol', 
                        name: 'NexusProtocol'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'petclinic-group', 
                        description: 'Nexus Group Id (WTF???)', 
                        name: 'NexusGroupId'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'petclinic-artifacr-id', 
                        description: 'Nexus Artifact Id', 
                        name: 'NexusArtifactId'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'war', 
                        description: 'Nexus Artifact Type', 
                        name: 'NexusArtifactType'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: '', 
                        description: 'Nexus Artifact Classifier', 
                        name: 'NexusArtifactClassifier'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'petclinic', 
                        description: 'Nexus Repository Name', 
                        name: 'NexusRepoName'
                    ],
                    [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'chucknorris', 
                        description: 'Link to Nexus User/Password pair (pre-configured)', 
                        name: 'NexusCredentialsId'
                    ],

                ]
        ],
        pipelineTriggers([])
    ]
)

import java.util.regex.Matcher
import java.util.regex.Pattern
import groovy.io.FileType


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

println("====== DEBUG START ========")
println("ArtifactSourceJobName = " + ArtifactSourceJobName.toString())
println("ArtifactSourceBuildNumber = " + ArtifactSourceBuildNumber.toString())
println("ArtifactSourceFilter = " + ArtifactSourceFilter.toString())
println("====== DEBUG END ==========")


node("master") {
    wrap(
        [
            $class: 'AnsiColorBuildWrapper', 
            $class: 'TimestamperBuildWrapper'
        ]
    ) {

        stage("Pre-Actions") {
    
            step(
                [
                    $class: 'hudson.plugins.chucknorris.CordellWalkerRecorder'
                ]
            );
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


        // Debug only
        //sh "rm pom.xml || true "



        //Append pom version if pom.xml exist 
        try {
            def pom = readMavenPom file:  "pom.xml"
            NexisArtifactVersion = pom.version + "-" + ArtifactSourceBuildNumber
        }
        catch (java.io.FileNotFoundException e) {
            println(e)
            NexisArtifactVersion = ArtifactSourceBuildNumber
        }
    

        stage("Find Files") {
            println(env.WORKSPACE)
            sh "pwd"
            sh "ls -lsa -r"
            ArtifactsList = []
            def WorkspaceDir = new File(env.WORKSPACE)
            WorkspaceDir.eachFileRecurse (FileType.FILES) { cur_file ->
                ArtifactsList << cur_file.toString().minus(env.WORKSPACE.toString() + "/")

            }
        } // end stage("Find Files") 


        ArtifactsList.each  { currentArtifact -> 
           stage("Upload Artifact To Nexus " + currentArtifact ) {
               nexusArtifactUploader  artifacts:
               [
                   [
                       artifactId: NexusArtifactId,
                       type: NexusArtifactType,
                       classifier: NexusArtifactClassifier,
                       file: currentArtifact
                   ]
               ],
               nexusVersion: 'nexus2',
               protocol: NexusProtocol, 
               nexusUrl: NexusURL,
               groupId: NexusGroupId,
               version: NexisArtifactVersion,
               repository: NexusRepoName,
               credentialsId: NexusCredentialsId
           } // end stage("Upload Artifact To Nexus " + currentArtifact )
           println(NexusProtocol + "://" + NexusURL+"/content/repositories/" + NexusRepoName + "/" 
                   + NexusGroupId + "/" + NexusArtifactId + "/" + NexisArtifactVersion + "/" + NexusArtifactId + "-" + NexisArtifactVersion + 
                   "." + NexusArtifactType)
        } // end list.each

        stage("Publish Link To File") {

            res = new File(env.WORKSPACE.toString() + "/nexus.link").createNewFile()
            def resultFile = new File(env.WORKSPACE.toString() + "/nexus.link")
            resultFile.write(NexusProtocol + "://" + NexusURL+"/content/repositories/" + NexusRepoName + "/" 
                   + NexusGroupId + "/" + NexusArtifactId + "/" + NexisArtifactVersion + "/" + NexusArtifactId + "-" + NexisArtifactVersion + 
                   "." + NexusArtifactType)
        }
        stage('Publish Artifact To Jenkins') {
            step(
                [
                    $class: 'ArtifactArchiver', 
                    artifacts: 'nexus.link', 
                    fingerprint: true
                ],
            )
        }
    } 
}