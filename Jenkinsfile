node {  

    stage ('CI-Build')    {
        bat returnStatus: true, script:'call Tools\\CI-Build-Test.cmd'
                archiveArtifacts allowEmptyArchive: true, artifacts:'Artifacts/database_creation_script.sql, Artifacts/invalid_objects.txt'
    }
    stage ('Release-Review')    {
        def status = bat returnStatus: true, script:'call Tools\\Release-Review.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_script.sql, Artifacts/Warnings.txt, Artifacts/changes_report.html'
        if (status == 0) {
        // Success!
        }
        else
        {
            echo "Exit code: $status"
            error("Build failed because exit code $status")
        }
    }
    stage ('Release-Acceptance')    {
        bat 'call Tools\\Release-Acceptance.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_success_report.html, Artifacts/predeployment_snapshot.onp'
    }
}
