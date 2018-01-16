rem Here we apply the same deployment script that has been reviewed, approved and run successfully on the staging database
rem With the state model, as the database doesn't contain information about the state it was at last deployment, 
rem it isn't possible to check for drift at this time. To address this, run sco.exe against production on a schedule and capture the state
rem each time, comparing it to the last.

rem If you are running the staging rehearsal as part of an automated process, the production deployment may be some time afterwards,
rem so we can at least check that production hasn't drifted since the staging deployment.

rem drift check against staging
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source SOCO_STAGING/demopassword@localhost/XE{SOCO_STAGING} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/staging_validation_report.html
rem we expect there to be no differences
rem IF ERRORLEVEL is 0 then there are no changes.
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == Validation successful! Production hasn't drifted since the staging deployment rehearsal
    echo ========================================================================================================
)

IF %ERRORLEVEL% NEQ 0 (
    echo ========================================================================================================
    echo == Validation FAILED! The production database schema is no longer consistent with production
    echo ========================================================================================================
    GOTO END
)


rem sqlplus TODO - run deployment script


:END