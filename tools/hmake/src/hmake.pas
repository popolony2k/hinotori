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
{$i ..\..\..\src\util\helpstr.pas}
{$i .\mkbuild.pas}


(**
  * Print hanle help message;
  *)
procedure PrintHelp;
begin
  WriteLn;
  WriteLn( 'Usage - hmake <makefile>' );
  WriteLn( '<makefile> - The file name (with path) of a valid makefile to process;');
  WriteLn;
end;


{ Main program }

var 
       handle : TMakeHandle;

begin
  WriteLn( 'hmake - Hinotori MakeFile processor.' );
  WriteLn( 'CopyLeft (c) since 2024 by Hinotori team.' );

  if( ParamCount = 0 )  then
    PrintHelp()
  else
  begin
    if( MkOpen( ParamStr( 1 ), handle ) ) then
    begin
      if( MkBuild( handle ) )  then
      begin
        __PrintDebug( handle );   { TODO: TEST ONLY }

        if( not MkClose( handle ) ) then
          WriteLn( 'Error to close make file' );
        
        WriteLn( 'Build success' );
      end
      else
      begin
        WriteLn( 'Build failed with following error:' );
        WriteLn( '[' + handle.strLastError + ']');
      end;
    end
    else
      WriteLn( 'Error to open make file' );
  end;
end.
