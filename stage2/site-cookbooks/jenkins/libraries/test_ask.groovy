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
                        choices: "Ask\nAsk with 5 min timeout (default: destroy)\nDestroy\nDo not destroy\n",
                        description: 'Do destoy?', 
                        name: 'doDestroy'
                    ]

                ]
        ],
        pipelineTriggers([])
    ]
)

def choice = new ChoiceParameterDefinition(
                                    'Destroy failed env',
                                    "yes\nno\n",
                                    '12345')


stage("ask") {


switch (doDestroy) {
    case 'Ask':
        res = 'Ask'
    break

    case 'Ask with 5 min timeout (default: destroy)':
        res = 'Ask with 5 min timeout (default: destroy)'

        timeout(1) {
        def destroySelector = input(
                                message: 'message',
                                parameters: [choice],
                                id: 'destroySelectorId'
                                )
        }

    break

    case 'Destroy':
        res = 'Destroy'
    break

    case 'Do not destroy':
        res = 'Do not destroy'
    break
}   

println(destroySelector)

println(res)    
}