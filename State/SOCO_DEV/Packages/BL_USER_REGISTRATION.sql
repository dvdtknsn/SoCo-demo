CREATE OR REPLACE package bl_user_registration as
    function validate_password_strength(in_password in varchar2) 
    return boolean;
end bl_user_registration;
/