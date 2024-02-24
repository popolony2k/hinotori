(*<dosutil.pas>
 * Utilities routines for using with MSXDOS 1&2 applications.
 * Compatible with (FAT12/16).
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: dosutil.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/dosutil.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - lnkdlist.pas;
 *)


(**
  * Module constants and definitions.
  *)
Const
            ctInitialCharE5 = $05;       { The first entry's char is $E5 }


(**
  * Split an entered directory path into small pieces.
  * @param pathList An empty @see TLinkedLink previously created;
  * @param strPath The path that will be splitted;
  *)
Procedure SplitPath( Var pathList : TLinkedList; strPath : TFileName );
Var
      nDirPos,
      nPathLen : Byte;
      dirName  : TDirectoryName;
      pDirName : Pointer;
      bAdded   : Boolean;

Begin
  nPathLen := Length( strPath );
  pDirName := Ptr( Addr( dirName ) );

  While( nPathLen > 0 )  Do
  Begin
    nDirPos := Pos( '\', strPath );

    If( nDirPos = 0 )  Then
      nDirPos := nPathLen + 1;

    dirName  := Copy( strPath, 1, ( nDirPos - 1 ) );
    bAdded   := AddLinkedListItem( pathList, pDirName );
    strPath  := Copy( strPath, ( nDirPos + 1 ), ( nPathLen - nDirPos ) );
    nPathLen := Length( strPath );
  End;
End;

(**
  * Return if an entry specifies a drive or not.
  * @param strEntry The entry to check;
  *)
Function IsDriveName( strEntry : TDirectoryName ) : Boolean;
Begin
  If( Length( strEntry ) > 1 ) Then
    IsDriveName := ( Pos( ':', strEntry ) = 2 )
  Else
    IsDriveName := False;
End;

(**
  * Check if a char array matches with a wild card;
  * @param pArray The specified array that will be checked;
  * @param pWildCard The wild card (can contain *, ?);
  * @param nMaxCount The maximum buffer count;
  *)
Function EntryMatch( pArray,
                     pWildCard : PDynCharArray;
                     nMaxCount : Byte ) : Boolean;
Var
       nCount  : Byte;
       bExit,
       bMatch  : Boolean;

Begin
  bMatch := True;
  nCount := 0;

  (*
   * End of string delimiter for FAT entries is space #32.
   *)
  While( ( pArray^[nCount] <> #32 ) And
         ( pWildCard^[nCount] <> #32 ) And
         ( nCount < nMaxCount ) And
         bMatch ) Do
  Begin
    Case pWildCard^[nCount] Of
      '*' : bExit := True;
      '?' : (* Do nothing *)
        Begin
        End;
      Else
      Begin
        (* Check FAT spec for this feature *)
        If( pArray^[nCount] = Char( ctInitialCharE5 ) ) Then
        Begin
          If( pWildCard^[nCount] <> Char( $E5 ) ) Then
            bMatch := False;
        End
        Else
          If( pArray^[nCount] <> pWildCard^[nCount] )  Then
            bMatch := False;
      End;
    End;

    nCount := Succ( nCount );
  End;

  EntryMatch := bMatch;
End;
