CREATE OR REPLACE package test_bl_user_registration as
 
 -- %suite(Password tests)
 
  -- %test(validates password 1)
  procedure validate_password_strength_1;
  -- %test(validates password 2)
  procedure validate_password_strength_2;
  -- %test(validates password 3)
  procedure validate_password_strength_3;

 -- source: https://apexplained.wordpress.com/2013/07/14/introducing-unit-tests-in-plsql-with-utplsql/
end test_bl_user_registration;
/