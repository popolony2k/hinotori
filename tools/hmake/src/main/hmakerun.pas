(*<hmakerun.pas>
 * Hinotori make file application runner routines.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - /memory/{platform}/pointer.pas;  (depends on archtecture)
 * - /util/helpstr.pas;
 * - ./make/mktypes.pas;
 * - ./make/mkhelper.pas;
 * - ./make/mkbuild.pas;
 * - ./make/mkfile.pas;
 * - ./make/mkbuild.pas;
 * - ./make/{platform}/mkoscall.pas   (depends on archtecture)
 * - ./make/mkexec.pas;
 *)

(**
  * Command line parameter processing.
  *)
type TCmdLineParms = record
  strMakeFile    : TFileName;
  pUsrTargetList : PLinkedList;
  strError       : TString;
  bDebugMode     : boolean;
  bSilentMode    : boolean;
end;

(**
  * Print help message;
  *)
procedure PrintHelp;
begin
  WriteLn;
  WriteLn( 'Usage - hmake [-h] [-f <makefile>] [<target>]' );
  WriteLn( '  [-h] Optional. Print this help screen.' );
  WriteLn( '  [-d] Optional. Show makefile build/execution debug information. (Default=false)' );
  WriteLn( '    Show all variables, targets and step processing execution.' );
  WriteLn( '  [-s] Optional. Silent target execution command output. (Default = true)' );
  WriteLn( '    All target execution output are not shown when this option is set.' );
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
      strParm : TIdentifierName;

begin
  parms.strMakeFile := '.\Makefile';
  parms.bDebugMode  := false;
  parms.bSilentMode := false;
  bRet   := true;
  nCount := 1;

  New( parms.pUsrTargetList );
  CreateLinkedList( parms.pUsrTargetList^, sizeof( TIdentifierName ) );

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

      '-s' :
      begin 
        parms.bSilentMode := true;
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
      begin
        strParm := ParamStr( nCount );
        if( AddLinkedListItem( parms.pUsrTargetList^, 
                                ToPointer( strParm ) ) = nil ) then
          parms.strError := 'Not enough memory to create target list';
      end;
    end;

    nCount := Succ( nCount );
  end;

  GetCmdLineParms := bRet;
end;

(**
  * Main application entry-point.
  * @param chCSI The control sequence introducer specific
  * for the OS that is running hmake;
  *)
procedure Run( chCSI : char );
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

    handle.chCSI := chCSI;
    handle.bDebugMode  := parms.bDebugMode;
    handle.bSilentMode := parms.bSilentMode;
    handle.pUsrTargetList := parms.pUsrTargetList;

    if( MkOpen( parms.strMakeFile, handle ) ) then
    begin
      if( MkBuild( handle ) )  then
      begin
        if( parms.bDebugMode )  then
          MkPrintDebug( handle );

        if( not MkClose( handle ) ) then
          WriteLn( 'hmake: Error to close make file' );
  
        if( not MkExecute( handle ) )  then        
        begin
          if( handle.nLastLine >= 0 )  then
          begin
            WriteLn( 'hmake: Execute failed with following error.' );
            Write( 'Line (', handle.nLastLine, ') - ' );
          end;

          WriteLn( handle.strLastError );
        end;
      end
      else
      begin
        if( handle.nLastLine >= 0 )  then
        begin
          WriteLn( 'hmake: Build failed with following error.' );
          Write( 'Line (', handle.nLastLine, ') - ' );
        end;
        
        WriteLn( handle.strLastError );
      end;
    end
    else
      WriteLn( 'hmake: Error to open make file [' + parms.strMakeFile + ']' );

    MkDestroy( handle );
  end;
end;
