{$ifdef fpc}
        {$mode objfpc}
{$endif}

uses SysUtils;

begin
   raise Exception.Create('a')
end.