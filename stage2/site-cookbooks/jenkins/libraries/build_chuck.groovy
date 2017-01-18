repoName = 'https://github.com/szhem/chucknorris-plugin'
branchName = 'jenkins-pipeline'



node("master") {
	wrap([$class: 'AnsiColorBuildWrapper', $class: 'TimestamperBuildWrapper']) {

        stage ('git checkout') {
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
	                       url: "${repoName}",
	                       poll: true
	                   ]
	               ]
	           ]
	        )
    	} // end stage ('git checkout') 

		stage("Build Chuck") {
    	    withMaven(maven: 'M3') 
        	{
        	    // Run the maven build 
        	    sh "mvn clean install"
        	}
    	} // end stage("Build Chuck")

    	stage('Publish Artifact To Jenkins') {
    		sh """
				cp target/chucknorris.hpi /var/lib/jenkins/plugins
    		"""
    	} //end stage('Publish Artifact To Jenkins')
	} // end wrap
} // end node