(*<mkoscall.pas>
 * Hinotori make file specific operating system calls.
 * TP3.3f MSX specific operating system calls.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 *)


(**
  * Execute an command on operating system through system call;
  * @param handle A valid open makefile handle;
  * @param strCommand Command that will be executed;
  *)
function MkExecCommand( var handle : TMakeHandle; 
                        var strCommand : TIdentifierValue ) : boolean;
var
      bRet   : boolean;

begin
  bRet := true;
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
  MkGetEnv := false;
end;
