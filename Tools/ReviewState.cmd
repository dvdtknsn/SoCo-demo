echo off

echo ==  We generate the deployment preview script artifact here (if there are changes) ==

rem exclude target schema in the scripts using /b:e
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /abortonwarnings:high /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /sf:Artifacts/deployment_script.sql > Artifacts\Warnings.txt

echo Warnings exit code:%ERRORLEVEL%
rem If the exit code is 63, the deployment warnings exceed the allowable threshold
rem This means that it is recommended to do a manual deployment, or consider adopting a migrations-based deployment approach

IF %ERRORLEVEL% EQU 63 (
    echo ========================================================================================================
    echo == High Severity Warnings Detected! Aborting the build. 
    echo == Review the deployment script and consider deploying manually, or adopting a migrations-based deployment approach.
    echo ========================================================================================================
    GOTO END
)

rem If there are no warnings we run the same comparison to generate the deployment script (as warnings abort the generation of the deployment script)
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Schema changes found to deploy - generating deployment script for review
    echo ========================================================================================================
    rem exclude target schema in the scripts using /b:e
    "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /b:hdre /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/changes_report.html /sf:Artifacts/deployment_script.sql
    SET ERRORLEVEL=0
    GOTO END
)

IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == No schema changes to deploy
    echo ========================================================================================================
    rem If required, halt the build process at this stage
    SET ERRORLEVEL=1
    GOTO END
)

:END
EXIT /B %ERRORLEVEL%