program count;

uses SysUtils;

var
  i: Integer;
  target: Integer;
begin
  i := 0;
  target := StrToInt(ParamStr(1));
  while i < target do
  begin
    i := (i + 1) or 1;
  end;
  WriteLn(i);
end.
