{$ifdef fpc}
        {$mode objfpc}
{$endif}

uses SysUtils;

begin
   try
        raise Exception.Create('a')
   except
        on E: Exception do begin end
   end;
end.