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
                        defaultValue: '10.0.10.200', 
                        description: 'IP address of slave node', 
                        name: 'IpAddress'
                    ],
                   [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'dynamic_slaves', 
                        description: 'Credentials ID', 
                        name: 'CredentialsId'
                    ],
                   [
                        $class: 'StringParameterDefinition', 
                        defaultValue: 'dynamic-slave', 
                        description: 'Slave Name', 
                        name: 'newSlaveName'
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


def checkSlaveJobName = 'check_node'

@NonCPS
def checkNode(checkSlaveJobName){

    def checkStatus = build(
    job: checkSlaveJobName,
    parameters:
        [
            [
                $class: 'StringParameterValue',
                name: 'node',
                value: newSlaveName
            ]   
        ]
    )

}

@NonCPS
def addNewSlave(newSlaveName) {
    List<Entry> env = new ArrayList<Entry>();
    
    env.add(new Entry("key1","value1"))
    env.add(new Entry("key2","value2"))
    
    EnvironmentVariablesNodeProperty envPro = new EnvironmentVariablesNodeProperty(env);
    println('1')
    Slave slave = new DumbSlave(
                      "dynamic-slave","dynamic-slave",
                      "/root",
                      "1",
                      Node.Mode.NORMAL,
                      "dynamic-slave",
                      new SSHLauncher(IpAddress,22, CredentialsId,
                      ,"","","","",
                      0,0,0),
                      new RetentionStrategy.Always(),
                      new LinkedList()
                      )
    println('2')
    slave.getNodeProperties().add(envPro)
    println('3')
    newNode = Jenkins.instance.addNode(slave)
    println('4')
    //println(newNode)
}
addNewSlave(newSlaveName)
//node("master") {
    println('4.1 ')  
checkNode(checkSlaveJobName)
//}
println('5')
