(*<helpstr.pas>
 * Helper functions to perform string manipulation.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types;
 * - /memory/pointer.pas;
 * - /collectn/lnkdlist.pas;
 *)

(**
  * New String array type to use with the module functions.
  *)
(* Deprecated *) type TStringArray = array[0..5] of TTinyString;


(**
  * Split a string into array of strings, based on a delimiter.
  * @param strValue The value to be splitted;
  * @param strDelimiter The delimiter to find in the base string;
  * @param aResult array of Strings containing all splitted strings;
  * The function return the size of the resulted array;
  *)
(* Deprecated *) function Split( strValue, strDelimiter : TString;
                var aResult : TStringArray ) : integer;
var
        nCount,
        nPos      : integer;
begin
  nCount := 0;

  repeat
    nPos := Pos( strDelimiter, strValue );

    if( nPos > 0 ) then
    begin
      aResult[nCount] := Copy( strValue, 1, ( nPos - 1 ) );
      Delete( strValue, 1, nPos );
    end
    else
      aResult[nCount] := strValue;

    nCount := nCount + 1;
  until( nPos = 0 );

  Split := nCount;
end;

(**
  * Split a string into array of strings, based on a delimiter.
  * @param strValue The value to be splitted;
  * @param strDelimiter The delimiter to find in the base string;
  * @param aResult linked list containing all splitted strings;
  * This linked list passed as parameter must be initialized 
  * previously by CreateLinkedList function; 
  * The function return the size of the resulted list;
  *)
function SplitString( strValue, strDelimiter : TString;
                      var aResult : TLinkedList ) : integer;
var
        nPos      : integer;
        strTemp   : TString;

begin
  repeat
    nPos := Pos( strDelimiter, strValue );

    if( nPos > 0 ) then
    begin
      strTemp := Copy( strValue, 1, ( nPos - 1 ) );

      if( AddLinkedListItem( aResult, ToPointer( strTemp ) ) <> nil ) then
        Delete( strValue, 1, nPos )
      else
        nPos := -1;
    end
    else
    begin
      if( aResult.nListSize > 0 )  then
        if( AddLinkedListItem( aResult, ToPointer( strValue ) ) = nil ) then
          nPos := -1;
    end;
  until( nPos <= 0 );

  SplitString := aResult.nListSize;
end;

(**
  * Convert the specified string to an upper case string.
  * @param strString The string that will be converted;
  *)
function UpperCase( var strString : TString ) : TString;
var
       nCount  : Byte;
begin
  for nCount := 1 to Length( strString ) do
    strString[nCount] := UpCase( strString[nCount] );

  UpperCase := strString;
end;

(**
  * Trim leading ad trailing spaces of a string;
  * @param strText The text to be trimmed;
  *)
function Trim( strText: TString ) : TString;
var
      nFirstPos, 
      nLastPos    : integer;

begin
  nFirstPos := 1;
  nLastPos  := Length( strText );

  while( ( nFirstPos <= nLastPos ) and ( strText[nFirstPos] = #32 ) ) do
    nFirstPos := Succ( nFirstPos );

  while( ( nLastPos >= 1 ) and ( strText[nLastPos] = #32 ) ) do
    nLastPos := Pred( nLastPos );

  Trim := Copy( strText, nFirstPos, ( nLastPos - nFirstPos + 1 ) );
end;

(**
  * Remove all occurences of specified charater from string.
  * @param strSource The string where all character occurrences will be 
  * removed;
  * @param chChar The character that will be removed;
  *)
function RemoveChar( strSource : TString; chChar : char ) : TString;
var 
      nCount  : integer;

begin
  for nCount := 1 to Length( strSource ) do 
  begin
    if( strSource[nCount] = chChar ) then 
    begin
      Delete( strSource, nCount, 1 );
    end;
  end;

  RemoveChar := strSource;
end;