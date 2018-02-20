node {  

    stage ('CI-Build')    {
        bat returnStatus: true, script:'call Tools\\CI-Build-Test.cmd'
                archiveArtifacts allowEmptyArchive: true, artifacts:'Artifacts/database_creation_script.sql, Artifacts/invalid_objects.txt'
    }
    stage ('Release-Review')    {
        bat returnStatus: true, script:'call Tools\\Release-Review.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_script.sql'
    }
    stage ('Release-Acceptance')    {
        bat 'call Tools\\Release-Acceptance.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/deployment_success_report.html, Artifacts/predeployment_snapshot.onp'
    }
}
