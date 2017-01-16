repoName = "https://github.com/gdelprete/rpm-tomcat8.git"
branchName = "master"

node("master"){
	stage("Cleanup") {
		step([$class: 'WsCleanup']) 
	}
		
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
//		               credentialsId: "${repoCreds}",
		               url: "${repoName}",
		               poll: true
		           ]
		       ]
		   ]
		)
	}
	stage('Build'){
		buildResult = sh script: 
		"""
			sed -i  's/publish-rpm/#publish-rpm/g' make_rpm.sh
			./make_rpm.sh
		""", 
			returnStdout: true

		println(buildResult)
	}
	stage('Publish Artifact To Jenkins') {
		step(
			[
				$class: 'ArtifactArchiver', 
				artifacts: 'rpmbuild/RPMS/noarch/*.rpm', 
				fingerprint: true
			],
		)
	}	
}
