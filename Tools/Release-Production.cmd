echo off
rem Here we apply the same deployment script that has been reviewed, approved and run successfully on an acceptance or staging database
rem To check that production hasn't drifted since the acceptance database deployment, we run a second drift check.

echo == Acceptance Drift Check ==
rem We have previously saved the pre-deployment snapshot state of the acceptance database as an artifact
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source:Artifacts/predeployment_snapshot.onp{SOCO_ACCEPTANCE} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/drift_report.html

rem We expect there to be no differences, so ERRORLEVEL should be 0
IF %ERRORLEVEL% EQU 0 (
     echo ========================================================================================================
     echo == Production hasn't drifted since the deployment rehearsal
     echo ========================================================================================================
)

 IF %ERRORLEVEL% NEQ 0 (
     echo ========================================================================================================
     echo == DRIFT DETECTED! The production database schema is not at the validated starting point
     echo ========================================================================================================
    rem We set the exit code to a value that will halt the deployment process.
     SET ERRORLEVEL=1
     GOTO END
)

echo == Deployment time! ==
rem Note: if there are no changes, the deployment script artifact won't exist so we should check this and fail the build to avoid confusion.
if exist Artifacts/deployment_script.sql (
    echo == Deployment script artifact found ==
) else (
    echo == No deployment script found - are there any changes? ==
    SET ERRORLEVEL=2
    GOTO END
)
echo on
rem Here we apply the deployment script 
Call exit | sqlplus SOCO_PRODUCTION/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) @Artifacts/deployment_script.sql
echo SQLPLUS exit code:%ERRORLEVEL%
echo off
rem Finally we validate that production is equal to the state

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/production_deploy_success_report.html
echo Production Deployment Check:%ERRORLEVEL%
IF %ERRORLEVEL% NEQ 0 (
     echo ========================================================================================================
     echo == Deployment FAILED! The production database schema is not equivalent to the desired state
     echo ========================================================================================================
     GOTO END
 )
IF %ERRORLEVEL% EQU 0 (
     echo ========================================================================================================
     echo == Congratulations - Deployment was successful!
     echo ========================================================================================================
     GOTO END
 )
:END
EXIT /B %ERRORLEVEL%