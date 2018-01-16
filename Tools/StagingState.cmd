echo off
rem Here we restore a staging database and run a deployment rehearsal
rem For speed, this demo will create a blank staging from the production, but ideally a restore should be used

echo == Build staging database
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /target SOCO_STAGING/demopassword@localhost/XE{SOCO_STAGING} /deploy
echo Build Staging Database %ERRORLEVEL%

rem We abort if the deployment hasn't been successful.

rem DRIFT CHECK
rem Now that we've got a staging database, we can validate that the end state schema is consistent with production
rem If it isn't, the Restore was incorrect, production has drifted, or there was a different problem

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source SOCO_STAGING/demopassword@localhost/XE{SOCO_STAGING} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/staging_validation_report.html
rem we expect there to be no differences
rem IF ERRORLEVEL is 0 then there are no changes.
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == Comparison against production has no differences => We have a valid staging database
    echo ========================================================================================================
)

IF %ERRORLEVEL% NEQ 0 (
    echo ========================================================================================================
    echo == Validation FAILED! The staging database schema  isn't consistent with production
    echo ========================================================================================================
    GOTO END
)

rem Now we apply the deployment script 
echo == Applying deployment script to staging database

rem Note: if there are no changes, the deployment script artifact won't exist so we should check this and fail the build to avoid confusion.
if exist Artifacts/deployment_script.sql (
    rem file exists
) else (
    SET ERRORLEVEL=1
    GOTO END
)
rem echo on to better troubleshoot issues with sqlplus
echo on
Call exit | sqlplus SOCO_STAGING/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) @Artifacts/deployment_script.sql
rem echo SQLPLUS exit code:%ERRORLEVEL%

echo == Check that the deployed staging is now the same as the desired state ==
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_STAGING/demopassword@localhost/XE{SOCO_STAGING} /report:Artifacts/staging_deploy_success_report.html
echo Staging Deployment Check:%ERRORLEVEL%

:END
EXIT /B %ERRORLEVEL%