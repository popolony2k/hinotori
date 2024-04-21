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
  {$IFDEF UNIX }
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
