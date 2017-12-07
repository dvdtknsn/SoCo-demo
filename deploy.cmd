

Tools\sco.exe /source Scriptsfolder{DOERTE_DEV} /target DOERTE_PROD/demopassword@localhost/XE{DOERTE_PROD} /deployallobjects /sf:%1\state_deploymentscript.sql /report:%1\change_report.html

echo %ERRORLEVEL%
rem IF ERRORLEVEL is 61 then all is good as we expect changes.
IF %ERRORLEVEL% EQU 61 (
    set ERRORLEVEL=0
    GOTO END
)

rem IF ERRORLEVEL is 0 then it's gone wrong so set errorlevel to make build step fail
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == No changes found to deploy !!!!  Aborting build...
    echo ========================================================================================================
    set ERRORLEVEL=1
)

:END
EXIT /B %ERRORLEVEL%


