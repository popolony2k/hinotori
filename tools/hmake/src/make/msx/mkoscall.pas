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
 * - /dos/msxdos.pas;
 * - /dos/msxdos2.pas;
 * - /dos/envvars.pas;
 * - /dos/dos2find.pas;
 * - ../mktypes.pas;
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
  *    If target does exist, no commands will run (target is up o date).
  * 2) Make decides if it should run a target.
  *    It will only run if target doesn't exist, or prereq is newer
  *    than target;
  *)
function MkCheckTarget( var pair : TIdentifierPair ) : boolean;
var
      bRet   : boolean;
      target : TMSXFileInfo;
      preReq : TMSXFileInfo;

begin
  (* bRet = true  → target is up-to-date; skip execution.
     bRet = false → target needs rebuilding; execute commands. *)
  bRet := MSXFindFirst( pair.strName, ctFindAnyAttr, target );

  (* Directories must never be treated as up-to-date target files. *)
  if( bRet )  then
    bRet := ( ( target.nAttr and ctAttrDirectory ) = 0 );

  (* Target file exists; check whether a prerequisite file is newer. *)
  if( bRet and ( pair.strValue <> '' ) )  then
  begin
    if( MSXFindFirst( pair.strValue, ctFindAnyAttr, preReq ) )  then
    begin
      if( ( preReq.nAttr and ctAttrDirectory ) = 0 )  then
        if( MSXTimeStampNewer( preReq, target ) )  then
          bRet := false;
    end;
  end;

  MkCheckTarget := bRet;
end;

(**
  * Expand a glob pattern and return a space-separated list of matching files.
  * Zero matches produces an empty result string — this is NOT an error.
  * @param strPattern The glob pattern to expand (e.g. "*.c" or "src/*.c");
  * @param strResult  Receives the space-separated list of matching filenames;
  * The function always returns true.
  *)
function MkWildcard( var strPattern : TIdentifierValue;
                     var strResult  : TIdentifierValue ) : boolean;
var
      info    : TMSXFileInfo;
      strDir  : TIdentifierValue;
      strAcc  : TIdentifierValue;
      strName : TFileName;
      nIdx    : integer;
      bFound  : boolean;

begin
  strResult := '';
  strDir    := '';
  strAcc    := '';

  for nIdx := Length( strPattern ) downto 1 do
  begin
    if( ( strPattern[nIdx] = '/' ) or ( strPattern[nIdx] = '\' ) )  then
    begin
      strDir := Copy( strPattern, 1, nIdx );
      break;
    end;
  end;

  bFound := MSXFindFirst( strPattern, ctFindAnyAttr, info );

  while( bFound )  do
  begin
    if( ( info.nAttr and ctAttrDirectory ) = 0 )  then
    begin
      strName := MSXFindInfoName( info );

      if( strAcc <> '' )  then
        strAcc := strAcc + ' ';
      strAcc := strAcc + strDir + strName;
    end;

    bFound := MSXFindNext( info );
  end;

  strResult  := strAcc;
  MkWildcard := true;
end;
