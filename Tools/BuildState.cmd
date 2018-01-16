echo off
rem Build is a useful test as it can fail if there are invalid objects

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_TEST/demopassword@localhost/XE{SOCO_TEST} /report:Artifacts/changes_report.html

echo %ERRORLEVEL%

rem IF ERRORLEVEL is 0 then there are no changes.
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == No schema changes detected (migrations must be data-only)
    echo ========================================================================================================
)


rem IF ERRORLEVEL is 61 we set to 0 as we expect differences
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Change report changes_report.html saved as an artifact
    echo ========================================================================================================
    rem as wee expect differences we reset the ERRORLEVEL to 0 so the build doesn't fail 
    SET ERRORLEVEL=0
)

rem Now that we've built a test database, we can validate that the end state schema is consistent with the state

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_TEST/demopassword@localhost/XE{SOCO_TEST} /report:Artifacts/build_validation_report.html
rem we expect there to be no differences
rem IF ERRORLEVEL is 0 then there are no changes.
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == Validation successful! We have successfully built a database from the source state
    echo ========================================================================================================
    GOTO END
)

IF %ERRORLEVEL% NEQ 0 (
    echo ========================================================================================================
    echo == Validation FAILED! The build isn't consistent with the source
    echo ========================================================================================================
    GOTO END
)


:END
EXIT /B %ERRORLEVEL%