(*<fthelp.pas>
 * Helper functions to provide support to the file transfer network tools.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: fthelp.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/fthelp.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - sockdefs.pas;
 *)


(**
  * Command line structure parameters.
  *)
Type TCmdLineParms = Record
  bPort        : Boolean;
  bIPAddress   : Boolean;
  bHelp        : Boolean;
  nPort        : Integer;
  strIPAddress : TIPAddress;
End;



(**
  * Parse the startup program parameters, returning the
  * result in @see TCmdLineParms structure;
  * @param parms The reference to parsed parameters command-line;
  *)
Procedure ParseCmdLine( Var parms : TCmdLineParms );
Var
      nCount,
      nParmCount   : Byte;
      nCode        : Integer;
      bDecodePort  : Boolean;
      strParm      : TFileName;

Begin
  nParmCount := ParamCount;

  With parms Do
  Begin
    If( nParmCount = 0 ) Then    { Clear parms }
      bHelp := True
    Else
      bHelp := False;

    nCount := 1;
    nCode  := 1;
    nPort  := 0;
    bPort  := False;
    bIPAddress   := False;
    bDecodePort  := False;
    strIPAddress := '';

    While( nCount <= nParmCount ) Do
    Begin
      strParm := ParamStr( nCount );

      { Process possible parameters values }
      If( bIPAddress And ( strIPAddress = '' ) )  Then   { IP Address }
      Begin
        strIPAddress := strParm;
        strParm := '';
        bHelp   := False;
      End
      Else
      If( Not bPort And bDecodePort )  Then              { Port number }
      Begin
        Val( strParm, nPort, nCode );

        If( nCode <> 0 )  Then
          nCount := nParmCount
        Else
        Begin
          bHelp := False;
          bPort := True;
          bDecodePort := False;
        End;

        strParm := '';
      End;

      If( ( Length( strParm ) >= 2 ) And ( strParm[1] = '-' ) ) Then
      Begin
        Case ( strParm[2] ) Of
          'h' : Begin                    { Help }
                  bHelp := True;
                  nCount := nParmCount;
                End;
          'a' : Begin                    { IP Address }
                  bIPAddress := True;
                  bHelp := True;
                End;
          'p' : Begin                    { Port number }
                  bDecodePort := True;
                  bHelp := True;
                End;
          Else Begin                     { Invalid parms }
                 bHelp := True;
                 nCount := nParmCount;
               End;
        End;
      End;

      nCount := nCount + 1;
    End;
  End;
End;
