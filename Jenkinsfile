node {  
		/* Begin by cleaning artifacts folder */
		try {	dir ('Artifacts') { deleteDir() } }
		catch (all)	{ echo "something went wrong with deletedir" }

	 stage ('CI-Build')    {
		  checkout scm
		  bat returnStatus: true, script:'call Tools\\CI-Build-Test.cmd'
					 archiveArtifacts allowEmptyArchive: true, artifacts:'Artifacts/database_creation_script.sql, Artifacts/invalid_objects.txt'
	 }
	 stage ('CI-Integration')    {
	 }
	 stage ('Release-QA')    {
		  def status = bat returnStatus: true, script:'call Tools\\Release-QA.cmd'
	 }
	 stage ('Release-Review')    {
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
				input 'High warnings detected - abort or go ahead anyway?'
				// error("Build failed because exit code $status")
		  }
		  echo "Exit code: $status"
	 }
	stage ('Release-Acceptance')    {
		  def status = bat returnStatus: true, script:'call Tools\\Release-Acceptance.cmd'
		  archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/accept_deploy_success_report.html, Artifacts/predeployment_snapshot.onp'
		  if (status == 1) { // Drift detected
				error('Drift detected!')
		  }
		  echo "Exit code: $status"
	 }

	 stage ('Approval'){
		  
		  // wrapping in a time out so it doens't block the agent
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

	 stage ('Release-Production')    {
//        input message: 'Deploy to Production?', ok: 'Deploy'

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