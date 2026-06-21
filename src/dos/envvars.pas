(*<envvars.pas>
 * MSXDOS2 environment variables functions handling.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /dos/msxdos.pas;
 * - /dos/msxdos2.pas;
 *)

(**
  * Set data value to a specified environment variable.
  * @param strEnvVar The environment variable to set data;
  * @param strValue The environment variable data content;
  * The function return True if the operation was successfull,
  * otherwise false.
  *)
function SetEnv( strEnvVar, strValue : TFileName ) : boolean;
var
        szValue,
        szEnv        : array[0..ctMaxPath] of char;
        regs         : TRegs;
        nPos         : byte;
begin
  for nPos := 1 to Length( strEnvVar ) do
    szEnv[nPos - 1] := strEnvVar[nPos];

  szEnv[nPos] := #0;

  for nPos := 1 to Length( strValue ) do
    szValue[nPos - 1] := strValue[nPos];

  szValue[nPos] := #0;

  with regs do
  begin
    C  := ctSetEnvironmentItem;
    HL := Addr( szEnv );
    DE := Addr( szValue );
  end;

  MSXBDOS( regs );

  SetEnv := ( regs.A = 0 );
end;

(**
  * Get value of specified environment variable.
  * @param strEnvVar The environment variable to get data;
  *)
function GetEnv( strEnvVar : TFileName ) : TFileName;
var
        szValue,
        szEnv        : array[0..ctMaxPath] of char;
        regs         : TRegs;
        nPos         : byte;
begin
  for nPos := 1 to Length( strEnvVar ) do
    szEnv[nPos - 1] := strEnvVar[nPos];

  szEnv[nPos] := #0;
  szValue[0]  := #0;

  with regs do
  begin
    B  := sizeof( szValue );
    C  := ctGetEnvironmentItem;
    HL := Addr( szEnv );
    DE := Addr( szValue );
  end;

  MSXBDOS( regs );

  nPos := Pos( #0, szValue );

  if( nPos <> 1 )  then
  begin
    Move( szValue, strEnvVar[1], nPos );
    strEnvVar[0] := char( nPos );
  end
  else
    strEnvVar := '';

  GetEnv := strEnvVar;
end;
