node {  

    stage ('CI-Build')    {
        bat 'call Tools\\CI-Build-Test.cmd'
        archive 'State/**/*.jar'
    }
    stage ('Release-Review')    {
        bat 'call Tools\\Release-Review.cmd'
        archiveArtifacts 'Artifacts\Warnings.txt, Artifacts\deployment_script.sql, Artifacts\changes_report.html'
    }

}
