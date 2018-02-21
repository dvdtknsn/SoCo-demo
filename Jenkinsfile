node {  


    stage ('CI-Build')    {
        checkout scm
    try{
		 dir ('Artifacts')
	    deleteDir() /* clean artifacts folder */
	 }
	 catch
	 {
		 echo "something went wrong with deletedir"
	 }

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
        // No changes to deploy so we want to abrot but without failing the build
            echo "No changes to deploy"
            currentBuild.result = 'ABORTED'
        }
        if (status == 63) // If there are high warnings detected
        {
            echo "Differences found"
            input 'High warnings detected - abort or go ahead anyway?'
            // error("Build failed because exit code $status")
        }
        echo "Exit code: $status"
    }

}