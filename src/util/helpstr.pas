(*<helpstr.pas>
 * Helper functions to perform string manipulation.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /system/types;
 *)

(**
  * New String array type to use with the module functions.
  * TODO: IMPROVE THIS !! ADDING SUPPPORT TO A LINKED LIST APPROACH.
  *)
Type TStringArray = Array[0..5] Of TTinyString;


(**
  * Split a string into array of strings, based on a delimiter.
  * @param strValue The value to be splitted;
  * @param strDelimiter The delimiter to find in the base string;
  * @param aResult Array of Strings containing all splitted strings;
  * The function return the size of the resulted array;
  *)
Function Split( strValue, strDelimiter : TString;
                Var aResult : TStringArray ) : Integer;
Var
        nCount,
        nPos      : Integer;
Begin
  nCount := 0;

  Repeat
    nPos := Pos( strDelimiter, strValue );

    If( nPos > 0 ) Then
    Begin
      aResult[nCount] := Copy( strValue, 1, ( nPos - 1 ) );
      Delete( strValue, 1, nPos );
    End
    Else
      aResult[nCount] := strValue;

    nCount := nCount + 1;
  Until( nPos = 0 );

  Split := nCount;
End;

(**
  * Convert the specified string to an upper case string.
  * @param strString The string that will be converted;
  *)
Function UpperCase( strString : TString ) : TString;
Var
       nCount  : Byte;
Begin
  For nCount := 1 To Length( strString ) Do
    strString[nCount] := UpCase( strString[nCount] );

  UpperCase := strString;
End;
