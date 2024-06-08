(*<dosutil.pas>
 * Utilities routines for using with MSXDOS 1&2 applications.
 * Compatible with (FAT12/16).
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /memory/{platform}/pointer.pas;
 * - /collectn/lnkdlist.pas;
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
procedure SplitPath( var pathList : TLinkedList; strPath : TFileName );
var
      nDirPos,
      nPathLen : byte;
      dirName  : TDirectoryName;
      pDirName : Pointer;
      bAdded   : boolean;

begin
  nPathLen := Length( strPath );
  pDirName := ToPointer( dirName );

  while( nPathLen > 0 )  do
  begin
    nDirPos := Pos( '\', strPath );

    if( nDirPos = 0 )  then
      nDirPos := nPathLen + 1;

    dirName  := Copy( strPath, 1, ( nDirPos - 1 ) );
    bAdded   := ( AddLinkedListItem( pathList, pDirName ) <> nil );
    strPath  := Copy( strPath, ( nDirPos + 1 ), ( nPathLen - nDirPos ) );
    nPathLen := Length( strPath );
  end;
end;

(**
  * Extract the file name extension;
  * @param strFileName The filename that will be splitted;
  * @param strRetFileName The filname part without the extension;
  * @param strRetExt The extension part of filename;
  *)
function SplitFileName( strFileName : TFileName;
                        var strRetFileName : TFileName;
                        var strRetExt : TFileExt ) : boolean;
var 
       nPos : integer;
begin
  nPos := Pos( '.', strFileName );

  if( nPos = 0 )  then
    nPos := Length( strFileName )
  else
    strRetExt := Copy( strFileName, ( nPos + 1 ), ( Length( strFileName ) - nPos ) );

  strRetFileName := Copy( strFileName, 1, ( nPos - 1 ) );

  SplitFileName := ( nPos > 0 );
end;

(**
  * Return if an entry specifies a drive or not.
  * @param strEntry The entry to check;
  *)
function IsDriveName( strEntry : TDirectoryName ) : boolean;
begin
  if( Length( strEntry ) > 1 ) then
    IsDriveName := ( Pos( ':', strEntry ) = 2 )
  else
    IsDriveName := False;
end;

(**
  * Check if a char array matches with a wild card;
  * @param pArray The specified array that will be checked;
  * @param pWildCard The wild card (can contain *, ?);
  * @param nMaxCount The maximum buffer count;
  *)
function EntryMatch( pArray,
                     pWildCard : PDynCharArray;
                     nMaxCount : byte ) : boolean;
var
       nCount  : byte;
       bExit,
       bMatch  : boolean;

begin
  bMatch := True;
  nCount := 0;

  (*
   * end of string delimiter for FAT entries is space #32.
   *)
  while( ( pArray^[nCount] <> #32 ) and
         ( pWildCard^[nCount] <> #32 ) and
         ( nCount < nMaxCount ) and
         bMatch ) do
  begin
    case pWildCard^[nCount] Of
      '*' : bExit := True;
      '?' : (* do nothing *)
        begin
        end;
      else
      begin
        (* Check FAT spec for this feature *)
        if( pArray^[nCount] = Char( ctInitialCharE5 ) ) then
        begin
          if( pWildCard^[nCount] <> Char( $E5 ) ) then
            bMatch := False;
        end
        else
          if( pArray^[nCount] <> pWildCard^[nCount] )  then
            bMatch := False;
      end;
    end;

    nCount := Succ( nCount );
  end;

  EntryMatch := bMatch;
end;
