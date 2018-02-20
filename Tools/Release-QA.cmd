echo off
rem This syncs an QA database with the latest version so it can be used by a QA team to run regression tests and other manual or automated system tests.
rem There are two approaches to keep a database in sync
rem 1) Use the same process as used for deployment to Acceptance and Production
rem 2) Simply sync the latest changes to the database
rem This example will use (2). If using (1), simply duplicate the process used for Acceptance deployments on your QA database.

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_QA/demopassword@localhost/XE{SOCO_QA} /deploy
rem NOTE - This ignores any deployment warnings as these will be picked up by the Review step.


rem IF ERRORLEVEL is 0 there are no differences, which we don't expect during a deployment.
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == No changes were found to deploy! 
    echo ========================================================================================================
    rem Set the ERRORLEVEL to 1 so the job status is unstable to alert user
    SET ERRORLEVEL=1
)

rem IF ERRORLEVEL is 61 there are differences, which we expect.
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Changes were deployed. 
    echo ========================================================================================================
    rem Set the ERRORLEVEL to 0 so the build doesn't fail 
    SET ERRORLEVEL=0
)
