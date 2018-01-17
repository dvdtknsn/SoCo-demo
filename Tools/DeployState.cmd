echo off
rem Here we apply the same deployment script that has been reviewed, approved and run successfully on the staging database
rem With the state model, as the database doesn't contain information about the state it was at last deployment, 
rem it isn't possible to check for drift at this time. To address this, run sco.exe against production on a schedule and capture the state
rem each time, comparing it to the last.

rem If you are running the staging rehearsal as part of an automated process, the production deployment may be some time afterwards,
rem so we can at least check that production hasn't drifted since the staging deployment.

echo == Staging Drift Check ==
rem drift check against staging
rem TODO - we need to have saved the pre-state of staging so we can do this check
rem "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source PreStagingState{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/staging_validation_report.html
rem we expect there to be no differences
rem IF ERRORLEVEL is 0 then there are no changes.
rem IF %ERRORLEVEL% EQU 0 (
rem     echo ========================================================================================================
rem     echo == Validation successful! Production hasn't drifted since the staging deployment rehearsal
rem     echo ========================================================================================================
rem )

rem IF %ERRORLEVEL% NEQ 0 (
rem     echo ========================================================================================================
rem     echo == Validation FAILED! The production database schema is no longer consistent with production
rem     echo ========================================================================================================
rem     GOTO END
rem )

echo == Deployment time! ==
rem Note: if there are no changes, the deployment script artifact won't exist so we should check this and fail the build to avoid confusion.
if exist Artifacts/deployment_script.sql (
    echo == Deployment script artifact found ==
) else (
    echo == No deployment script found - are there any changes? ==
    SET ERRORLEVEL=1
    GOTO END
)
echo on
rem Now we apply the deployment script 
Call exit | sqlplus SOCO_PRODUCTION/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) @Artifacts/deployment_script.sql
echo SQLPLUS exit code:%ERRORLEVEL%
echo off
rem and we should validate that production is equal to the state

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