echo off

echo == Rollback to state before deployment ==

rem TODO - instead of generating rollback script here, save off as artifat and allow this to be run from here if the artifact exists
rem The artifact shouldn't have been created if there are high warnings

rem exclude target schema in the scripts using /b:e
rem Just to be safe, we will abort if there are high warnings
rem For this demo I'm applying the rollback using /deploy but it might be prudent to output the script using /sf:Artifacts/rollback_script.sql and to deploy manually after review
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /abortonwarnings:high /b:hdre /i:sdwgvac /source:Artifacts/predeployment_snapshot.snp{SOCO_STAGING} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/Rollback_changes_report.html /deploy
echo Rollback ERRORLEVEL:%ERRORLEVEL%

rem If we get exit code 63, it means that rollback is risky.
rem Exit code 63 Deployment warnings above threshold. Deployment aborted.
IF %ERRORLEVEL% EQU 63 (
    echo ========================================================================================================
    echo == Rollback aborted due to high warnings. Please consider rolling back manually or from a backup.
    echo ========================================================================================================
    rem We set the ERRORLEVEL to 1, which the job will interpret as "Unstable", as rollback warnings shouldn't prevent us from choosing to deploy
    SET ERRORLEVEL=1
    GOTO END
)

rem Exit code 61 is what we expect. It means we can run the rollback with no warnings.
rem Exit code 61 Differences found.
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Rollback of production database successful!
    echo ========================================================================================================
    SET ERRORLEVEL=0
)

rem In theory we could run another comparison here to double check that production and the snapshot are equal 


:END
EXIT /B %ERRORLEVEL%