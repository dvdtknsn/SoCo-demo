CREATE OR REPLACE PACKAGE BODY ut_str
AS
   PROCEDURE ut_setup
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE ut_teardown
   IS
   BEGIN
      NULL;
   END;

   -- For each program to test...
   PROCEDURE ut_betwn IS
   BEGIN
      utAssert.eq (
         'Typical Valid Usage',
         str.betwn ('this is a string', 3, 7),
         'is is' 
         );

      utAssert.eq (
         'Test Negative Start',
         str.betwn ('this is a string', -3, 7),
         'ing'
         );

      utAssert.isNULL (
         'Start bigger than end',
         str.betwn ('this is a string', 3, 1)
         );
   END ut_betwn;

END ut_str;
/