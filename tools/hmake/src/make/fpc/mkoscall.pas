(*<mkoscall.pas>
 * Hinotori make file specific operating system calls.
 * Free Pascal specific operating system calls.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - ../mktypes.pas;
 *)

{$mode objfpc}{$H+}

const   __ctUnixShellEnv     = 'SHELL';   { Unix shell environment    }
        __ctWindowsShellEnv  = 'cmd';     { Windows shell environment }
        __ctUnixShellParm    = '-c';      { Unix shell exec parm      }
        __ctWindowsShellParm = '/c';      { Windows shell exec parm   }



(**
  * Execute an command on operating system through system call;
  * @param handle A valid open makefile handle;
  * @param strCommand Command that will be executed;
  *)
function MkExecCommand( var handle : TMakeHandle; 
                        var strCommand : TIdentifierValue ) : boolean;
var
      bRet         : boolean;
      strCmdShell  : string;
      strShellParm : string;
      strOutput    : string;

begin
{$IFDEF UNIX}
  strCmdShell  := GetEnv( __ctUnixShellEnv );
  strShellParm := __ctUnixShellParm; 
{$ELSE}
  {$IFDEF WINDOWS}
  strCmdShell  := __ctWindowsShellEnv;
  strShellParm := __ctWindowsShellParm
  {$ENDIF}
{$ENDIF}

  bRet := RunCommand( strCmdShell,[strShellParm, strCommand], strOutput );

  if( bRet )  then
    WriteLn( strOutput )
  else
    handle.strLastError := 'Failed to execute [' + strCommand + ']';

  MkExecCommand := bRet; 
end;

(**
  * Return the environment variable content based on its name.
  * @param strEnvVarName The environament variable to get value;
  * @param strEnvValue Reference to required environment variable
  * value;
  *)
function MkGetEnv( strEnvVarName : TIdentifierName;
                   var strEnvValue : TFileName ) : boolean;
begin
  strEnvValue := GetEnv( strEnvVarName );

  MkGetEnv := ( strEnvValue <> '' );
end;

(**
  * Check if target files are valid to be processed;
  * @param pair Reference to the pair that will be checked;
  * The function return true if the target should be
  * processed otherwise false;
  * Rules for processing:
  * 1) If a target file does not exist, the commands will run. 
  *    If target does exist, no commands will run.
  * 2) Make decides if it should run a target. 
  *    It will only run if target doesn't exist, or prereq is newer 
  *    than target;
  *)
function MkCheckTarget( var pair : TIdentifierPair ) : boolean;
var
      bRet   : boolean;
      target : TSearchRec;
      prereq : TSearchRec;

begin
  bRet := ( FindFirst( pair.strName, faAnyFile, target ) = 0 );

  if( bRet )  then
  begin
    if( FindFirst( pair.strValue, faAnyFile, prereq ) = 0 )  then
    begin
      bRet := ( prereq.Time > target.Time );
      FindClose( prereq );
    end;

    FindClose( target );
  end
  else
    bRet := true;

  MkCheckTarget := bRet;
end;
