echo off
rem Run unit tests
echo == Run unit tests ==
call Tools\utPLSQL-cli\bin\utplsql run SOCO_TEST/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) -f=ut_xunit_reporter -o=Artifacts/test_results.xml
echo utplsql:%ERRORLEVEL%

:END
EXIT /B %ERRORLEVEL%