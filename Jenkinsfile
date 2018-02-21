node {  
    stage ('CI-Build')    {
        checkout scm

        bat returnStatus: true, script:'call Tools\\CI-Build-Test.cmd'
                archiveArtifacts allowEmptyArchive: true, artifacts:'Artifacts/database_creation_script.sql, Artifacts/invalid_objects.txt'
    }
    stage ('Release-Review')    {
        def status = bat returnStatus: true, script:'call Tools\\Release-Review.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_script.sql, Artifacts/Warnings.txt, Artifacts/changes_report.html'
        if (status == 0) {
        // Success!
        }
        if (status == 1) {
        // No changes to deploy
            echo "No changes to deploy"
            currentBuild.result = 'ABORTED'
            error('Stopping early…')
        return
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
        bat 'call Tools\\Release-Acceptance.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_success_report.html, Artifacts/predeployment_snapshot.onp'
    }
    stage ('Deploy Approval')    {
        input 'Deploy to production?'
    }
    node {
        stage ('Release-Production')    {
            bat 'call Tools\\Release-Production.cmd'
            archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/production_deploy_success_report.html'
        }
    }
}
