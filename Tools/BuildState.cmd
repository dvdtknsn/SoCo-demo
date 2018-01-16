

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_PRODUCTION/demopassword@localhost/XE{SOCO_PRODUCTION} /report:Artifacts/change_report.html

echo %ERRORLEVEL%
rem IF ERRORLEVEL is 61 we set to 0 as we expect differences
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Change report change_report.html saved as an artifact
    echo ========================================================================================================
    SET ERRORLEVEL=0
    GOTO END
)

rem IF ERRORLEVEL is 0 then the migration scripts are consistent with the desired state and the build can proceed
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == No schema changes detected (migrations must be data-only)
    echo ========================================================================================================
    rem Don't fail the build if there are no schema changes as there may be data-only migrations
)

:END
EXIT /B %ERRORLEVEL%