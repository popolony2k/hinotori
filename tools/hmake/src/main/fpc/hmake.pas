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
 * - /memory/{platform}/pointer.pas;  (depends on architecture)
 * - /dos/dosutil.pas;
 * - /util/helpstr.pas;
 * - ../../make/mktypes.pas;
 * - ../../make/{platform}/mkoscall.pas;   (depends on architecture)
 * - ../../make/mkhelper.pas;
 * - ../../make/mkbuild.pas;
 * - ../../make/mkfile.pas;
 * - ../../make/mkbuild.pas;
 * - ../../make/mkexec.pas;
 * - ../hmakerun.pas;
 *)

program hmake;

uses dos, process, sysutils;

{$i ..\..\..\..\..\src\system\types.pas}
{$i ..\..\..\..\..\src\collectn\lnkdlist.pas}
{$i ..\..\..\..\..\src\memory\fpc\pointer.pas}
{$i ..\..\..\..\..\src\dos\dosutil.pas}
{$i ..\..\..\..\..\src\util\helpstr.pas}
{$i ..\..\make\mktypes.pas}
{$i ..\..\make\fpc\mkoscall.pas}
{$i ..\..\make\mkhelper.pas}
{$i ..\..\make\mkutils.pas}
{$i ..\..\make\mkfile.pas}
{$i ..\..\make\mkbuild.pas}
{$i ..\..\make\mkexec.pas}
{$i ..\hmakerun.pas}


(**
  * Main application entry point.
  *)
begin
  Run ( ctCSI_UNIX );
end.