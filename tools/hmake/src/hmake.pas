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
 * - /memory/pointer.pas;
 * - /util/helpstr.pas;
 * - ./make/mktypes.pas;
 * - ./make/mkhelper.pas;
 * - ./make/mkbuild.pas;
 * - ./make/mkfile.pas;
 * - ./make/mkbuild.pas;
 * - ./make/fpc/mkoscmd.pas   (depemds on archtecture)
 * - ./make/msx/mkoscmd.pas   (depends on archtecture)
 * - ./make/mkexec.pas;
 *)

program hmake;

{$i ..\..\..\src\system\types.pas}
{$i ..\..\..\src\collectn\lnkdlist.pas}
{$i ..\..\..\src\memory\pointer.pas}
{$i ..\..\..\src\util\helpstr.pas}
{$i .\make\mktypes.pas}
{$i .\make\mkhelper.pas}
{$i .\make\mkutils.pas}
{$i .\make\mkfile.pas}
{$i .\make\mkbuild.pas}
{$i .\make\fpc\mkoscmd.pas}
{i .\make\msx\mkoscmd.pas}
{$i .\make\mkexec.pas}

(**
  * Command line parameter processing.
  *)
type TCmdLineParms = record
  strMakeFile : TFileName;
  strTarget   : TTinyString;
  strError    : TString;
  bDebugMode  : boolean;
end;

(**
  * Print help message;
  *)
procedure PrintHelp;
begin
  WriteLn;
  WriteLn( 'Usage - hmake [-h] [-f <makefile>] [<target>]' );
  WriteLn( '  [-h] Optional. Print this help screen.' );
  WriteLn( '  [-d] Optional. Show makefile build/execution debug information.' );
  WriteLn( '    Show all variables, targets and step processing execution.' );
  WriteLn( '  [-f <makefile>] Optional. Set the makefile that will be' );
  WriteLn( '    processed. If not informed a file named makefile on current' );
  WriteLn( '    directory will be processed, if exists.' );
  WriteLn( '  [targets] Optional. The target that will be processed.' );
  WriteLn( '    If not informed, the default target be used.');
  WriteLn;
end;

(**
  * Get the command line passed as parameters.
  * @param parms The data structure that will received all parameters received.
  * The function return true if there's something to be processed or false
  * to PrintHelp message;
  *)
function GetCmdLineParms( var parms : TCmdLineParms ) : boolean;
var
      bRet    : boolean;
      nCount  : byte;

begin
  parms.strMakeFile := '.\Makefile';
  parms.bDebugMode  := false;
  bRet   := true;
  nCount := 1; 

  while( nCount <= ParamCount ) do
  begin
    case ParamStr( nCount ) of
      '-h' :
      begin 
        bRet   := false;
        nCount := ParamCount;
      end;

      '-d' :
      begin 
        parms.bDebugMode := true;
      end;

      '-f' :
      begin
        if( ParamCount > nCount )  then
        begin
          nCount := Succ( nCount );
          parms.strMakeFile := ParamStr( nCount )
        end
        else
          parms.strError := 'Missing Makefile name parameter';
      end;

      else
        parms.strTarget := ParamStr( nCount );
    end;

    nCount := Succ( nCount );
  end;

  GetCmdLineParms := bRet;
end;


{ Main program }
var 
       handle : TMakeHandle;
       parms  : TCmdLineParms;

begin
  WriteLn( 'hmake - Hinotori MakeFile processor.' );
  WriteLn( 'CopyLeft (c) since 2024 by Hinotori team.' );

  if( not GetCmdLineParms( parms ) )  then
    PrintHelp()
  else
  begin
    MkInit( handle );

    handle.bDebugMode := parms.bDebugMode;

    if( MkOpen( parms.strMakeFile, handle ) ) then
    begin
      if( MkBuild( handle ) )  then
      begin
        if( parms.bDebugMode )  then
          PrintDebug( handle );

        if( not MkClose( handle ) ) then
          WriteLn( 'Error to close make file' );

        WriteLn( 'Build success' );
 
        if( MkExecute( handle, parms.strTarget ) )  then        
          WriteLn( 'Execute success' )
        else
        begin
          WriteLn( 'Execute failed with following error:' );
          WriteLn( handle.strLastError );
        end;
      end
      else
      begin
        WriteLn( 'Build failed with following error:' );
        WriteLn( 'Line (', handle.nLastLine, ') - ', handle.strLastError );
      end;
    end
    else
      WriteLn( 'Error to open make file [' + parms.strMakeFile + ']' );

    MkDestroy( handle );
  end;
end.
