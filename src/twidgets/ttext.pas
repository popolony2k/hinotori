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
Function GetString( nX, nY : Integer;
                    Var strRet : TShortString;
                    nMaxSize : Byte;
                    bForceHexa,
                    bForceNumber : Boolean ) : Integer;
Var
     nCounter,
     nKeyCode : Byte;
     bSetPos,
     bExit    : Boolean;
     strTmp   : TShortString;

Begin
  strTmp   := strRet;
  nCounter := 1;
  bExit    := False;
  _GotoXY( nX, nY );

  While( Not bExit ) Do
  Begin
    bSetPos  := False;
    nKeyCode := Byte( ReadKey );

    Case( nKeyCode ) Of
      ctKbBackSpace :  If( nCounter > 1 )  Then
                       Begin
                         _GotoXY( ( nX + nCounter - 2 ), nY );

                         If( bForceHexa Or bForceNumber )  Then
                         Begin
                           Write( '0' );
                           strTmp[nCounter] := '0';
                           nCounter := ( nCounter - 1 );
                         End
                         Else
                         Begin
                           Write( ' ' );
                           nCounter  := ( nCounter - 1 );
                           strTmp[0] := Char( nCounter );
                         End;

                         _GotoXY( ( nX + nCounter - 1 ), nY );
                       End;
      ctKbKeyUp,
      ctKbKeyDown,
      ctKbKeyLeft,
      ctKbKeyRight,
      ctKbReturn,
      ctKbSelect,
      ctKbEsc,
      ctKbTab       :  Begin
                         If( nCounter <= nMaxSize )  Then
                           strTmp[0] := Char( nCounter )
                         Else
                           strTmp[0] := Char( nMaxSize );

                         { Update the return buffer }
                         If( nKeyCode <> ctKbEsc ) Then
                         Begin
                           If( Length( strTmp ) < nMaxSize )  Then
                             Move( strTmp[1], strRet[1], Length( strTmp ) )
                           Else
                             strRet := strTmp;
                         End
                         Else
                         Begin
                           _GotoXY( nX, nY );
                           Write( strRet );
                           bSetPos := True;
                         End;

                         bExit := True;
                       End;
      Else
        If( ( nCounter <= nMaxSize ) And
            ( nKeyCode <> ctKbBackSpace ) )  Then
        Begin
          _GotoXY( ( nX + nCounter - 1 ), nY );

          If( bForceHexa Or bForceNumber )  Then
          Begin
            { Letter only }
            If( ( UpCase( Char( nKeyCode ) ) In [#65..#70] ) And
                Not bForceNumber )  Then
            Begin
              strTmp[nCounter] := UpCase( Char( nKeyCode ) );
              Write( strTmp[nCounter] );
              nCounter := nCounter + 1;
              bSetPos  := True;
            End
            Else
              If( nKeyCode In [48..57] )  Then { Numeric only }
              Begin
                strTmp[nCounter] := Char( nKeyCode );
                Write( strTmp[nCounter] );
                nCounter := nCounter + 1;
                bSetPos  := True;
              End;
          End
          Else
          Begin
            strTmp[nCounter] := Char( nKeyCode );
            Write( strTmp[nCounter] );
            nCounter := nCounter + 1;
            bSetPos  := True;
          End;
        End;
    End;

    If( bSetPos )  Then
      _GotoXY( ( nX + nCounter - 2 ), nY );
  End;

  GetString := nKeyCode;
End;

(**
  * Print a text blinking on the specified position, waiting
  * for the user keyboard input to continue processing;
  * @param nX The coordinate in the X-Axis on screen;
  * @param nY The coordinate in the Y-Axis on screen;
  * @param strMessage String that will be displayed;
  *)
Procedure WaitBlinking( nX, nY : Integer; Var strMessage : TShortString );
Const
       ctDelayJiffy = 20;       { Blink delay in JIFFY }
Var
       nCount   : Byte;
       chChar   : Char;
       strEmpty : TShortString;

Begin
  strEmpty[0] := Char( Length( strMessage ) );
  FillChar( strEmpty[1], Length( strMessage ), ' ' );

  While( Not( KeyPressed ) ) Do
  Begin
    _GotoXY( nX, nY );
    Write( strMessage );
    Sleep( ctDelayJiffy );
    _GotoXY( nX, nY );
    Write( strEmpty );
    Sleep( ctDelayJiffy );
  End;

  chChar := ReadKey; { Clear keyboard buffer }
End;
