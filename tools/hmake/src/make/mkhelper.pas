(*<mkhelper.pas>
 * Hinotori make helper routines for handling makefiles.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - ./make/mktypes.pas;
 *)

(**
  * Return the identifier type for a given token.
  * @param strToken The token to be checked;
  *)
function MkGetIdentifier( var strToken : TString ) : TIdentifierType;
var
      identType : TIdentifierType;
      nPosToken : integer;
      nPosRem   : integer;
      nDiff     : integer;

begin
  (* Check variables *)
  nPosToken := Pos( '=', strToken );
  nPosRem   := Pos( '#', strToken );
  nDiff     := ( nPosRem - nPosToken );

  (* Check targets and command *)
  if( nDiff = 0 )  then
  begin
    nPosToken := Pos( ':', strToken );
    nPosRem   := Pos( '#', strToken );
    nDiff     := ( nPosRem - nPosToken );

    if( nDiff = 0 )  then
    begin
      if( Length( Trim( strToken ) ) = 0 )  then
        identType := TIdentifierType.IDENT_NONE
      else
        identType := TIdentifierType.IDENT_COMMAND;
    end
    else
    begin
      if( ( ( nPosRem > 0 ) and ( nPosToken = 0 ) ) or 
          ( ( nPosRem > 0 ) and ( nDiff < 0 ) ) ) then
        identType := TIdentifierType.IDENT_REMARK
      else
      begin
        identType := TIdentifierType.IDENT_TARGETS;

        if( ( nDiff > 0 ) and ( nPosRem < nPosToken) )  then
          identType := TIdentifierType.IDENT_REMARK;
      end;
    end;
  end
  else
  begin
    if( ( ( nPosRem > 0 ) and ( nPosToken = 0 ) ) or 
        ( ( nPosRem > 0 ) and ( nDiff < 0 ) ) ) then
      identType := TIdentifierType.IDENT_REMARK
    else
    begin
      identType := TIdentifierType.IDENT_VARIABLE;

      if( ( nDiff > 0 ) and ( nPosRem < nPosToken ) )  then
        identType := TIdentifierType.IDENT_REMARK;
    end;
  end;

  MkGetIdentifier := identType;
end;
