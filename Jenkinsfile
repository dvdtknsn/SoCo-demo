node {  
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
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_script.sql, Artifacts/Warnings.txt, Artifacts/changes_report.html'
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
    stage ('Release-Acceptance')    {
        def status = bat returnStatus: true, script:'call Tools\\Release-Acceptance.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/acceptance_deploy_success_report.html, Artifacts/predeployment_snapshot.onp'
        if (status == 1) { // Drift detected
            currentBuild.result = 'ABORTED'
            error('Drift detected!')
        }
        echo "Exit code: $status"
    }
    stage ('Release-Production')    {
        input 'Deploy to production?'
        def status = bat returnStatus: true, script:'call Tools\\Release-Production.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/production_deploy_success_report.html'

        if (status == 1) { // Drift detected
            currentBuild.result = 'ABORTED'
            error('Drift detected!')
        }
        if (status == 2) { // No deployment script found!
            currentBuild.result = 'ABORTED'
            error('No deployment script found - something went wrong')
        }
        echo "Exit code: $status"
    }
}
