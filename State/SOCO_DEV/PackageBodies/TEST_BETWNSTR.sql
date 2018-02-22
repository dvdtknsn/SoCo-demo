CREATE OR REPLACE package body test_betwnstr as

  procedure basic_usage is
  begin
    ut.expect( betwnstr( '1234567', 2, 5 ) ).to_equal('2345x');
  end;

  procedure zero_start_position is
  begin
    ut.expect( betwnstr( '1234567', 0, 5 ) ).to_equal('12345');
  end;

end;
/