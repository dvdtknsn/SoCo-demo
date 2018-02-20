node {  

    stage ('CI-Build')    {
        bat 'call Tools\\CI-Build-Test.cmd'
                archiveArtifacts 'Artifacts/database_creation_script.sql'
    }
    stage ('Release-Review')    {
        bat 'call Tools\\Release-Review.cmd'
        post {
            archiveArtifacts 'Artifacts/Warnings.txt, Artifacts/deployment_script.sql, Artifacts/changes_report.html'
        }
    }

}
