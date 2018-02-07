rem This syncs an QA database with the latest version so it can be used by a QA team to run regression tests and other manual or automated system tests.
rem There are two approaches to keep a database in sync
rem 1) Use the same process as used for deployment to Acceptance and Production
rem 2) Simply sync the latest changes to the database
rem This example will use (2). If using (1), simply duplicate the process used for Acceptance deployments on your QA database.

"C:\Program Files\Red Gate\Schema Compare for Oracle 4\sco.exe" /i:sdwgvac /source State{SOCO_DEV} /target SOCO_QA/demopassword@localhost/XE{SOCO_QA} /deploy
rem NOTE - This ignores any deployment warnings as these will be picked up by the Review step.

