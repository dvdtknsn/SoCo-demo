echo off

echo ==  We generate the deployment preview script artifact here (if there are changes) ==

rem exclude target schema in the scripts using /b:e
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /abortonwarnings:high /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /sf:Artifacts/deployment_script.sql > Artifacts\Warnings.txt

echo Warnings exit code:%ERRORLEVEL%
rem If the exit code is 63, the deployment warnings exceed the allowable threshold (eg, data loos may occur)
rem This means that it is recommended to review, customize the script and do a manual deployment

IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == No schema changes to deploy
    echo ========================================================================================================
    rem If desirable we halt the build process at this stage - in Jenkins can set to "unstable"
    SET ERRORLEVEL=1
    GOTO END
)

IF %ERRORLEVEL% EQU 63 (
    echo ========================================================================================================
    echo == High Severity Warnings Detected! Aborting the build. 
    echo == Review the deployment script and consider deploying manually, or adopting a migrations-based deployment approach.
    echo ========================================================================================================
    rem We need to run the same comparison without /abortonwarnings to generate the deployment script (as warnings abort the generation of the deployment script)
    rem It is still useful to have the deployment script artifact for troublshooting purposes, or as a starting point for a manual deployment
    rem We exclude target schema in the scripts using /b:e
    "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /sf:Artifacts/deployment_script.sql
    GOTO END
)

IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Schema changes found to deploy - generating deployment script for review
    echo ========================================================================================================
    SET ERRORLEVEL=0
    rem We need to run the same comparison without /abortonwarnings to generate the deployment script (as warnings abort the generation of the deployment script)
    rem We exclude target schema in the scripts using /b:e
    "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /sf:Artifacts/deployment_script.sql
    GOTO END
)

:END
EXIT /B %ERRORLEVEL%