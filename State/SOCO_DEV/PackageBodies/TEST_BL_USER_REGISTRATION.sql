CREATE OR REPLACE package body test_bl_user_registration as
  
    procedure validate_password_strength_1 as
    begin
        ut.expect(bl_user_registration.validate_password_strength('ABCdef123#'), 'ABCdef123# is a strong password').to_(equal(true));
    end validate_password_strength_1;

    procedure validate_password_strength_2 as
    begin    
        ut.expect(bl_user_registration.validate_password_strength('%a1B2CD'), '%a1B2CD is a strong password').to_(equal(true));
    end validate_password_strength_2;

    procedure validate_password_strength_3 as
    begin
        ut.expect(bl_user_registration.validate_password_strength('%a1B2CD'), '%a1B2CD is a stronger password').to_(equal(true));
    end validate_password_strength_3;

end test_bl_user_registration;
/