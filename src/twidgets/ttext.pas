(*<ttext.pas>
 * Text user interface widgets implementation.
 * Implements text based widgets.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /system/systypes.pas;
 * - /timer/sleep.pas;
 * - /util/helpchar.pas;
 * - /bios/msxbios.pas;
 * - /console/conio.pas;
 *)


(**
  * Retrieve the user keyboard input as string.
  * @param nX The X-Axis coordinate to positioning the cursor;
  * @param nY The Y-Axis coordinate to positioning the cursor;
  * @param strRet The reference to string that will receive the
  * user keyboard input;
  * @param nMaxSize The maximum size for return string data;
  * @param bForceHexa Force the input to be Hexadecimal values only;
  * @param bForceNumber Force the input to be numeric values only;
  *)
function GetString( nX, nY : integer;
                    var strRet : TShortString;
                    nMaxSize : byte;
                    bForceHexa,
                    bForceNumber : boolean ) : integer;
var
     nCounter,
     nKeyCode : byte;
     bSetPos,
     bExit    : boolean;
     strTmp   : TShortString;

begin
  strTmp   := strRet;
  nCounter := 1;
  bExit    := false;
  _GotoXY( nX, nY );

  while( not bExit ) do
  begin
    bSetPos  := false;
    nKeyCode := byte( ReadKey );

    case( nKeyCode ) of
      ctKbBackSpace :  if( nCounter > 1 )  then
                       begin
                         _GotoXY( ( nX + nCounter - 2 ), nY );

                         if( bForceHexa or bForceNumber )  then
                         begin
                           Write( '0' );
                           strTmp[nCounter] := '0';
                           nCounter := ( nCounter - 1 );
                         end
                         else
                         begin
                           Write( ' ' );
                           nCounter  := ( nCounter - 1 );
                           strTmp[0] := char( nCounter );
                         end;

                         _GotoXY( ( nX + nCounter - 1 ), nY );
                       end;
      ctKbKeyUp,
      ctKbKeyDown,
      ctKbKeyLeft,
      ctKbKeyRight,
      ctKbReturn,
      ctKbSelect,
      ctKbEsc,
      ctKbTab       :  begin
                         if( nCounter <= nMaxSize )  then
                           strTmp[0] := char( nCounter )
                         else
                           strTmp[0] := char( nMaxSize );

                         { Update the return buffer }
                         if( nKeyCode <> ctKbEsc ) then
                         begin
                           if( Length( strTmp ) < nMaxSize )  then
                             Move( strTmp[1], strRet[1], Length( strTmp ) )
                           else
                             strRet := strTmp;
                         end
                         else
                         begin
                           _GotoXY( nX, nY );
                           Write( strRet );
                           bSetPos := true;
                         end;

                         bExit := true;
                       end;
      else
        if( ( nCounter <= nMaxSize ) and
            ( nKeyCode <> ctKbBackSpace ) )  then
        begin
          _GotoXY( ( nX + nCounter - 1 ), nY );

          if( bForceHexa or bForceNumber )  then
          begin
            { Letter only }
            if( ( UpCase( char( nKeyCode ) ) in [#65..#70] ) and
                not bForceNumber )  then
            begin
              strTmp[nCounter] := UpCase( char( nKeyCode ) );
              Write( strTmp[nCounter] );
              nCounter := nCounter + 1;
              bSetPos  := true;
            end
            else
              if( nKeyCode in [48..57] )  then { Numeric only }
              begin
                strTmp[nCounter] := char( nKeyCode );
                Write( strTmp[nCounter] );
                nCounter := nCounter + 1;
                bSetPos  := true;
              end;
          end
          else
          begin
            strTmp[nCounter] := char( nKeyCode );
            Write( strTmp[nCounter] );
            nCounter := nCounter + 1;
            bSetPos  := true;
          end;
        end;
    end;

    if( bSetPos )  then
      _GotoXY( ( nX + nCounter - 2 ), nY );
  end;

  GetString := nKeyCode;
end;

(**
  * Print a text blinking on the specified position, waiting
  * for the user keyboard input to continue processing;
  * @param nX The coordinate in the X-Axis on screen;
  * @param nY The coordinate in the Y-Axis on screen;
  * @param strMessage String that will be displayed;
  *)
procedure WaitBlinking( nX, nY : integer; var strMessage : TShortString );
const
       ctDelayJiffy = 20;       { Blink delay in JIFFY }
var
       nCount   : byte;
       chChar   : char;
       strEmpty : TShortString;

begin
  strEmpty[0] := char( Length( strMessage ) );
  FillChar( strEmpty[1], Length( strMessage ), ' ' );

  while( not( KeyPressed ) ) do
  begin
    _GotoXY( nX, nY );
    Write( strMessage );
    Sleep( ctDelayJiffy );
    _GotoXY( nX, nY );
    Write( strEmpty );
    Sleep( ctDelayJiffy );
  end;

  chChar := ReadKey; { Clear keyboard buffer }
end;
