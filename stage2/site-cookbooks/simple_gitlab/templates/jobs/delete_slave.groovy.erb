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
                    artifactDaysToKeepStr: '3', 
                    artifactNumToKeepStr: '3', 
                    daysToKeepStr: '3', 
                    numToKeepStr: '3'
                ]
        ],
        [
            $class: 'ParametersDefinitionProperty', 
             parameterDefinitions: 
                [
                   [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'dynamic-slave', 
                        description: 'Slave Name', 
                        name: 'slaveName'
                    ]

                ]
        ], 
            pipelineTriggers([])
    ]
)


import jenkins.model.*
import hudson.model.*
import hudson.slaves.*
import hudson.plugins.sshslaves.*
import java.util.ArrayList;
import hudson.slaves.EnvironmentVariablesNodeProperty.Entry;
  

@NonCPS
def deleteSlave(slaveName){
	for (slaveToDelete in hudson.model.Hudson.instance.slaves) {
		if (slaveToDelete.name == slaveName) {	
			println('Shutting down node!!!!');
			slaveToDelete.getComputer().setTemporarilyOffline(true,null);
			slaveToDelete.getComputer().doDoDelete();
		}
	}
}

deleteSlave(slaveName)

