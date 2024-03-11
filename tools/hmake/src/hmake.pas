(*<hmake.pas>
 * Hinotori make file processor.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - ./mkbuild.pas;
 *)

program hmake;

{$i ..\..\..\src\system\types.pas}
{$i ..\..\..\src\collectn\lnkdlist.pas}
{$i .\mkbuild.pas}


{ Main program }


begin
  WriteLn( 'hmake - MakeFile processor.' );
  WriteLn( 'CopyLeft (c) since 2024 by Hinotori team.' );
end.
