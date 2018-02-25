node {  
		/* Begin by cleaning artifacts folder */
		try {	dir ('Artifacts') { deleteDir() } }
		catch (all)	{ echo "something went wrong with deletedir" }

	 stage ('Build')    {
		  	checkout scm
		  	def status = bat returnStatus: true, script:'call Tools\\CI-Build.cmd'
		 	archiveArtifacts allowEmptyArchive: true, artifacts:'Artifacts/database_creation_script.sql, Artifacts/invalid_objects.txt'
			if (status ==1) // invalid object detected
			  timeout(time: 3, unit: 'MINUTES') { // we will abort if there is no intervention in 3 minutes 
					input 'Invalid object(s) detected - abort or go ahead anyway?'
			  }
		 	archiveArtifacts allowEmptyArchive: true, artifacts:'Artifacts/database_creation_script.sql, Artifacts/invalid_objects.txt'
	 }
	 stage ('Unit Test')    {
		  	bat returnStatus: true, script:'call Tools\\CI-Unit-Test.cmd'
		 	def status = junit 'Artifacts/test_results.xml'
		 	archiveArtifacts allowEmptyArchive: true, artifacts:'Artifacts/test_results.xml'
	 }
	 stage ('Integration')    {
		 // nothing here - placeholder
	 }
	 stage ('QA')    {
		  def status = bat returnStatus: true, script:'call Tools\\Release-QA.cmd'
	 }
	 stage ('Deployment Artifacts')    {
		  def status = bat returnStatus: true, script:'call Tools\\Release-Review.cmd'
		  archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_script.sql, Artifacts/warnings.txt, Artifacts/deployment_report.html'
		  if (status == 0) {
		  // Success!
		  }
		  if (status == 1) {
		  // No changes to deploy so in this instance we set currentBuild.result='ABORTED' so that build status isn't marked as failed
				currentBuild.result = 'ABORTED'
				error ('No changes to deploy')   
		  }
		  if (status == 63) // If there are high warnings detected
		  {
				echo "Differences found"
			  timeout(time: 3, unit: 'MINUTES') {
					input 'High warnings detected - abort or go ahead anyway?'
			  }
				// error("Build failed because exit code $status")
		  }
		  echo "Exit code: $status"
	 }
	stage ('Acceptance')    {
		  def status = bat returnStatus: true, script:'call Tools\\Release-Acceptance.cmd'
		  archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/accept_deploy_success_report.html, Artifacts/predeployment_snapshot.onp'
		  if (status == 1) { // Drift detected
				error('Drift detected!')
		  }
		  echo "Exit code: $status"
	 }

	 stage ('Manual Approval Step'){
		  
		  // wrapping in a time out so it doesn't block the agent and simply fails the build after 5 minutes if there's no user intervention
		  timeout(time: 5, unit: 'MINUTES') {
     
		  		def userInput = input(
		  		id: 'userInput', message: 'Deploy?', parameters: [
		  		[$class: 'TextParameterDefinition', defaultValue: 'Production', description: 'Type Production to confirm deployment', name: 'Review deployment artifacts before proceeding']
		  		])
		  
		  		echo ("Env: "+userInput)
		  		if (userInput.indexOf('Production') == -1)
		  		{
					currentBuild.result = 'ABORTED'
					error('Deployment aborted')
		  		}
		  }
	 }

	 stage ('Production')    {

				def status = bat returnStatus: true, script:'call Tools\\Release-Production.cmd'
				archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/prod_deploy_success_report.html'

				if (status == 1) { // Drift detected
				 currentBuild.result = 'ABORTED'
				 error('Drift detected!')
				 }
				if (status == 2) { // No deployment script found!
					 error('No deployment script found - something went wrong')
				}
				echo "Exit code: $status"
		  
	 }   

}