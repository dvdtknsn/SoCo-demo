echo off
rem Build is a useful test as it can fail if there are invalid objects
rem We start by rebuilding the TEST database
rem Run a script to drop all objects from the TEST schema

echo on
Call exit | sqlplus SOCO_TEST/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) @Tools/DropAllObjects.sql
echo off

echo == Build (populate) the database with the objects and generate a creation script and a report listing all objects. 
"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /deploy /i:sdwgvac /source State{SOCO_DEV} /target SOCO_TEST/demopassword@localhost/XE{SOCO_TEST} /sf:Artifacts/database_creation_script.sql /report:Artifacts/all_objects_report.html

echo Build database from state:%ERRORLEVEL%

rem IF ERRORLEVEL is 0 then there are no changes.
IF %ERRORLEVEL% EQU 0 (
    echo ========================================================================================================
    echo == Warning - No schema changes detected. Does the database have no schema objects?
    echo ========================================================================================================
)

rem IF ERRORLEVEL is 61 there are differences, which we expect.
IF %ERRORLEVEL% EQU 61 (
    echo ========================================================================================================
    echo == Objects were found and built. Change report all_objects_report.html saved as an artifact
    echo ========================================================================================================
    rem as wee expect differences we reset the ERRORLEVEL to 0 so the build doesn't fail 
    SET ERRORLEVEL=0
)

rem Now that we've built a test database, we can validate that the end state schema is consistent with the state

rem This is optional and is unlikely to fail, so could leave this out to reduce build time.
rem "C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_TEST/demopassword@localhost/XE{SOCO_TEST} /report:Artifacts/build_validation_report.html

rem There should be no differences
rem IF ERRORLEVEL is 0 then there are no changes.
rem IF %ERRORLEVEL% EQU 0 (
rem     echo ========================================================================================================
rem     echo == Validation successful! We have successfully built a database from the source state
rem     echo ========================================================================================================
rem     GOTO END
rem )

rem IF %ERRORLEVEL% NEQ 0 (
rem     echo ========================================================================================================
rem     echo == Validation FAILED! The build isn't consistent with the source
rem     echo ========================================================================================================
rem     GOTO END
rem )

rem Now we check for invalid objects

rem Save the script that lists invalid objects to a file
echo SELECT 'Invalid Object', object_type, object_name FROM dba_objects WHERE status != 'VALID' AND owner = 'SOCO_TEST' ORDER BY object_type; > get_invalid_objects.sql

rem Execute the script on the database
echo on
Call exit | sqlplus SOCO_TEST/demopassword@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(Host=localhost)(Port=1521))(CONNECT_DATA=(SID=XE))) @get_invalid_objects.sql > Artifacts/invalid_objects.txt
rem echo off

type Artifacts\invalid_objects.txt

rem Now search for instances of "Invalid Object"
find /c "Invalid Object" Artifacts/invalid_objects.txt
echo Find Invalid Objects:%ERRORLEVEL%
    if %ERRORLEVEL% equ 1 goto NoInvalidObjects
    echo == Warning - Invalid objects found ==
    rem Set exit code to 1 so we can set the build to unstable. Could also choose to fail the build if desirable.
    SET ERRORLEVEL=1
    goto done
    :NoInvalidObjects
    echo No invalid objects found!
    SET ERRORLEVEL=0
    goto done
    :done


:END
EXIT /B %ERRORLEVEL%