(*<envvars.pas>
 * MSXDOS2 environment variables functions handling.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: envvars.pas 134 2020-09-11 02:44:57Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-09-10 23:44:57 -0300 (Thu, 10 Sep 2020) $
  * $Revision: 134 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/envvars.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxdos.pas;
 * - msxdos2.pas;
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
