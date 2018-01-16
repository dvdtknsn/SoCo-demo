echo off
rem Here we restore a staging database and run a deployment rehearsal
rem For speed, this demo will create a blank staging from the production, but ideally a restore should be used

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
    echo == Validation successful! We have a valid staging database
    echo ========================================================================================================
)

IF %ERRORLEVEL% NEQ 0 (
    echo ========================================================================================================
    echo == Validation FAILED! The staging database schema  isn't consistent with production
    echo ========================================================================================================
    GOTO END
)

rem Now we apply the deployment script 

Call sqlplus SOCO_PRODUCTION/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) @Artifacts/deployment_script.sql
echo SQLPLUS exit code:%ERRORLEVEL%

rem and we should validate that production is equal to the state

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/staging_deploy_success_report.html
echo Staging Deployment Check:%ERRORLEVEL%

:END