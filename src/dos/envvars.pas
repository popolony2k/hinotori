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
Function SetEnv( strEnvVar, strValue : TFileName ) : Boolean;
Var
        szValue,
        szEnv        : Array[0..ctMaxPath] Of Char;
        regs         : TRegs;
        nPos         : Byte;
Begin
  For nPos := 1 To Length( strEnvVar ) Do
    szEnv[nPos - 1] := strEnvVar[nPos];

  szEnv[nPos] := #0;

  For nPos := 1 To Length( strValue ) Do
    szValue[nPos - 1] := strValue[nPos];

  szValue[nPos] := #0;

  With regs Do
  Begin
    C  := ctSetEnvironmentItem;
    HL := Addr( szEnv );
    DE := Addr( szValue );
  End;

  MSXBDOS( regs );

  SetEnv := ( regs.A = 0 );
End;

(**
  * Get value of specified environment variable.
  * @param strEnvVar The environment variable to get data;
  *)
Function GetEnv( strEnvVar : TFileName ) : TFileName;
Var
        szValue,
        szEnv        : Array[0..ctMaxPath] Of Char;
        regs         : TRegs;
        nPos         : Byte;
Begin
  For nPos := 1 To Length( strEnvVar ) Do
    szEnv[nPos - 1] := strEnvVar[nPos];

  szEnv[nPos] := #0;
  szValue[0]  := #0;

  With regs Do
  Begin
    B  := SizeOf( szValue );
    C  := ctGetEnvironmentItem;
    HL := Addr( szEnv );
    DE := Addr( szValue );
  End;

  MSXBDOS( regs );

  nPos := Pos( #0, szValue );

  If( nPos <> 1 )  Then
  Begin
    Move( szValue, strEnvVar[1], nPos );
    strEnvVar[0] := Char( nPos );
  End
  Else
    strEnvVar := '';

  GetEnv := strEnvVar;
End;
