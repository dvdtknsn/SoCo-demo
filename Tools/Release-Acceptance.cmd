echo off
rem Here we restore a staging or acceptance database and run a deployment rehearsal
rem For speed, this demo will create a blank acceptance from the production, but ideally a restore should be used

echo == Build staging database ==
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /target SOCO_ACCEPTANCE/demopassword@localhost/XE{SOCO_ACCEPTANCE} /deploy
echo Build Acceptance Database %ERRORLEVEL%

rem We abort if the deployment hasn't been successful.

rem DRIFT CHECK
rem Now that we've got a database, we can validate that the end state schema is consistent with production
rem If it isn't, the Restore was incorrect, production has drifted, or there was a different problem
echo == Check that the restored acceptance database is equivalent to production ==
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source SOCO_ACCEPTANCE/demopassword@localhost/XE{SOCO_ACCEPTANCE} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/acceptance_validation_report.html
echo staging vs production check:%ERRORLEVEL%
rem we expect there to be no differences
rem IF ERRORLEVEL is 0 then there are no changes.
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == Comparison against production has no differences => We have a valid acceptance database
    echo ========================================================================================================
    rem Now we create a snapshot artifact of acceptance so we can use this "schema version" for the drift check and roll back later. 
    "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source SOCO_ACCEPTANCE/demopassword@localhost/XE{SOCO_ACCEPTANCE} /snapshot:Artifacts/predeployment_snapshot.onp 
)

IF %ERRORLEVEL% NEQ 0 (
    echo ========================================================================================================
    echo == Validation FAILED! The acceptance database schema  isn't consistent with production
    echo ========================================================================================================
    GOTO END
)

rem Now we apply the deployment script 
echo == Applying deployment script to the acceptance database ==

rem Note: if there are no changes, the deployment script artifact won't exist so we should check this and fail the build to avoid confusion.
if exist Artifacts/deployment_script.sql (
    echo == Deployment script artifact found ==
) else (
    echo == No deployment script found - it's possible that there are no changes to deploy! ==
    SET ERRORLEVEL=1
    GOTO END
)
rem It's useful to switch echo on to troubleshoot any issues with sqlplus
echo on
Call exit | sqlplus SOCO_ACCEPTANCE/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) @Artifacts/deployment_script.sql
echo off
echo == Check that the deployed acceptance database is now the same as the desired state ==
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_ACCEPTANCE/demopassword@localhost/XE{SOCO_ACCEPTANCE} /report:Artifacts/deployment_success_report.html
echo Acceptance Deployment Check:%ERRORLEVEL%

echo == Rollback check ==
rem Here we find out if there are any warnings associated with a rollback (ie is it possible without data loss?) by generating warnings
rem exclude target schema in the scripts using /b:e
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /abortonwarnings:high /b:hdre /i:sdwgvac /source:Artifacts/predeployment_snapshot.onp{SOCO_ACCEPTANCE} /target SOCO_ACCEPTANCE/demopassword@localhost/XE{SOCO_ACCEPTANCE} /report:Artifacts/Rollback_changes_report.html /sf:Artifacts/rollback_script.sql > Artifacts\rollback_warnings.txt
echo Acceptance Rollback Warnings ERRORLEVEL:%ERRORLEVEL%

rem Exit code 61 is what we expect. It means we can run the rollback with no warnings.
rem Exit code 61 Differences found.
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Rollback test on acceptance database successful!
    echo ========================================================================================================
    SET ERRORLEVEL=0
)

rem If we get exit code 63, it means that rollback is risky.
rem Exit code 63 Deployment warnings above threshold. Deployment aborted.
IF %ERRORLEVEL% EQU 63 (
    echo ========================================================================================================
    echo == Rollback has high warnings. A rollback to the snapshot may not be possible.
    echo ========================================================================================================
    rem To alert the user we could set the ERRORLEVEL to 1, which the Jenkins job will interpret as "Unstable".
    rem However, rollback warnings shouldn't stop us from deploying as we should be taking backups anyway.
    SET ERRORLEVEL=0
    GOTO END
)

rem TODO - If we want to fully test the rollback here we could apply the rollback script and check the resulting database against the predeployment_snapshot.onp snapshot

:END
EXIT /B %ERRORLEVEL%