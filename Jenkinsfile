node {  

    stage ('CI-Build')    {
        bat 'call Tools\\CI-Build-Test.cmd'
        archiveArtifacts 'Tools/**/*, Artifacts/**/*, State/**/*.jar'
    }
    stage ('Release-Review')    {
        bat 'call Tools\\Release-Review.cmd'
    }

}
