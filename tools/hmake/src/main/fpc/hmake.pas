(*<hmake.pas>
 * Hinotori main hmake make file processor (FPC).
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - /memory/pointer.pas;
 * - /util/helpstr.pas;
 * - ../../make/mktypes.pas;
 * - ../../make/mkhelper.pas;
 * - ../../make/mkbuild.pas;
 * - ../../make/mkfile.pas;
 * - ../../make/mkbuild.pas;
 * - ../../make/fpc/mkoscall.pas;
 * - ../../make/mkexec.pas;
 *)

program hmake;

uses dos;

{$i ..\..\..\..\..\src\system\types.pas}
{$i ..\..\..\..\..\src\collectn\lnkdlist.pas}
{$i ..\..\..\..\..\src\memory\pointer.pas}
{$i ..\..\..\..\..\src\util\helpstr.pas}
{$i ..\..\make\mktypes.pas}
{$i ..\..\make\mkhelper.pas}
{$i ..\..\make\mkutils.pas}
{$i ..\..\make\mkfile.pas}
{$i ..\..\make\mkbuild.pas}
{$i ..\..\make\fpc\mkoscall.pas}
{$i ..\..\make\mkexec.pas}
{$i ..\hmakerun.pas}


(**
  * Main application entry point.
  *)
begin
  Run;
end.