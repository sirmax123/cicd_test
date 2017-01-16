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
                        defaultValue: 'dynamic-slave', 
                        description: 'Node', 
                        name: 'node'
                    ]
                ]
        ], 
            pipelineTriggers([])
    ]
)
import hudson.model.*
import hudson.FilePath
import hudson.model.Node
import hudson.model.Slave
import jenkins.model.Jenkins
import groovy.time.*


@NonCPS
def checkIfNodeIsOnline(node) {


    //def node  = 'dynamic-slave';
    def status = 0;
    
    Jenkins jenkins = Jenkins.instance
    def jenkinsNodes =jenkins.nodes
    println(jenkinsNodes)
    println(Hudson.instance.slaves)
    for (s in Hudson.instance.slaves ){
        
        if (s.name == node) {
            slave = s
        }
    }
    
    println "Searching for $node";
    //slave = Hudson.instance.slaves.find({it.name == node});
    println(slave)
    if (slave != null) {
        computer = slave.getComputer();
        if (computer.isOffline()) {
            println "Error! $node is offline.";
            status = 1;
            currentBuild.result = 'FAILURE'
    
    //    } else  {
    //        println "OK: $node is online";
    //        if(computer.isAcceptingTasks()) {
                  //Launch job
    //        }
        }
    } else {
        println "Slave $node not found!";
        status = 1;
        currentBuild.result = 'FAILURE'
    
    }
    println("STATUS = " + status);
}

node("master") {
    checkIfNodeIsOnline(node)
}