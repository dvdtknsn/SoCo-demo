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
    stage ('Release-Acceptance')    {
        def status = bat returnStatus: true, script:'call Tools\\Release-Acceptance.cmd'
        archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/accept_deploy_success_report.html, Artifacts/predeployment_snapshot.onp'
        if (status == 1) { // Drift detected
            currentBuild.result = 'ABORTED'
            error('Drift detected!')
        }
        echo "Exit code: $status"
    }
    stage ('Release-Production')    {
//        input message: 'Deploy to Production?', ok: 'Deploy'
        def userInput = input(
        id: 'userInput', message: 'Deploy?', parameters: [
        [$class: 'TextParameterDefinition', defaultValue: 'QA', description: 'QA, Production', name: 'env']
        ])
        echo ("Env: "+userInput)
        echo ("QA index"+userInput.indexOf('QA') )
        echo ("Production index"+userInput.indexOf('Production') )
        if (userInput.indexOf('QA') !=0)
        {
            def status = bat returnStatus: true, script:'call Tools\\Release-QA.cmd'
        }
        if (userInput.indexOf('Production') !=0)
        {
            def status = bat returnStatus: true, script:'call Tools\\Release-Production.cmd'
            archiveArtifacts allowEmptyArchive: true, artifacts: 'Artifacts/prod_deploy_success_report.html'

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
}
