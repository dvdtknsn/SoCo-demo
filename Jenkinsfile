node {  

    stage ('CI-Build')    {
        bat 'call Tools\\CI-Build-Test.cmd'
        archive 'State/**/*.jar'
        archiveArtifacts 'Tools/**/*, Artifacts/**/*, State/**/*.jar'
    }
    stage ('Release-Review')    {
        bat 'call Tools\\Release-Review.cmd'
    }

}
