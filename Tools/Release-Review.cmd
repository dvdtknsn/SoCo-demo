echo off
rem  We generate the deployment preview script artifact here

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /abortonwarnings:high /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /scriptfile:Artifacts/deployment_script.sql > Artifacts\Warnings.txt
rem Note that for this demo example /b:e is used to exclude the target schema in the deployment script

echo Warnings exit code:%ERRORLEVEL%
rem In the unlikely event that the exit code is 63, this mean that a deployment warning has exceeded the allowable threshold (eg, data loss may have been detected)
rem If this occurs it is recommended to review the script, customize it, and perform a manual deployment

IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == No schema changes to deploy
    echo ========================================================================================================
    rem If desirable we halt the build process at this stage.
    SET ERRORLEVEL=1
    GOTO END
)

IF %ERRORLEVEL% EQU 63 (
    echo ========================================================================================================
    echo == High Severity Warnings Detected! Aborting the build. 
    echo == Review the deployment script and consider deploying manually.
    echo ========================================================================================================
    rem Here we run the same comparison without /abortonwarnings to generate the deployment script as warnings abort the generation of the deployment script
    rem It is useful to keep the deployment script artifact for troublshooting purposes, or as the starting point for a manual deployment
    "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /sf:Artifacts/deployment_script.sql
    rem Set the exit code back to 63 as the previous invocaion of sco.exe will reset this.
    SET ERRORLEVEL=63
    GOTO END
)

rem This is the happy path where we've identified changes and not detected any high warnings
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Schema changes found to deploy - generating deployment script for review
    echo ========================================================================================================
    rem Set ERROLEVEL to 0 so the build job doesn't fail
    SET ERRORLEVEL=0
    rem "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /sf:Artifacts/deployment_script.sql
    GOTO END
)

:END
EXIT /B %ERRORLEVEL%