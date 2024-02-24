(*<intrtest.pas>
 * Interrupt routine test.
 *
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: intrtest.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/intrtest.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - intr.pas;
 * - types.pas;
 * - msxbios.pas;
 * - conio.pas;
 * - tprogres.pas;
 *)

{$i intr.pas}
{$i types.pas}
{$i msxbios.pas}
{$i conio.pas}
{$i tprogres.pas}

Type TUserEntry = Record
 bFirstInit  : Boolean;
 nX, nY      : Byte;
 nStick      : Byte;
End;


(**
  * Status handling.
  * Joystick command management.
  * User presentation.
  *)
Procedure __InterruptHandler( nParm : Integer ); { App. interrupt handler }
Var
      pUserEntry : ^TUserEntry;
      chChar     : Char;

Begin
  pUserEntry := Ptr( nParm );

  { Top status }
  ProgressCycle( 'Press <SPACE> to exit' , 1, 1, pUserEntry^.bFirstInit );

  { Joystick user input management }
  With pUserEntry^ Do
  Begin
    Case nStick Of
      0 : { Nothing }
          chChar := '+';
      1 : { UP }
          Begin
            If( nY > 2 )  Then   { Avoid status display }
              nY := nY - 1;
            chChar := '*';
          End;
      3 : { Right }
          Begin
            nX := nX + 1;
            chChar := '#';
          End;
      5 : { Down }
          Begin
            nY := nY + 1;
            chChar := '#';
          End;
      7 : { Left }
          Begin
            nX := nX - 1;
            chChar := '*';
          End;
    End;

    { User presentation }
    _GotoXY( nX, nY );
    CHPUT( chChar );

    If( bFirstInit = True )  Then
      bFirstInit := False;
  End;
End;

(**
  * GTSTCK MSXBIOS Call.
  *)
Function GetStick : Byte;
Const
        ctGTSTCK = $00D5;  { Return current trigger status }

Var
       regs       : TRegs;
       EXPTBL     : Byte Absolute $FCC1; { Slot 0 }

Begin
  regs.IX := ctGTSTCK;
  regs.IY := EXPTBL;
  regs.A  := 0;           { Directional keys }

  CALSLT( regs );

  GetStick := regs.A;
End;

(**
  * GTTRIG MSXBIOS call.
  *)
Function GetTrigger : Byte;
Const
        ctGTTRIG = $00D8;  { Return current trigger status }

Var
       regs       : TRegs;
       EXPTBL     : Byte Absolute $FCC1; { Slot 0 }

Begin
  regs.IX := ctGTTRIG;
  regs.IY := EXPTBL;
  regs.A  := 0;          { Space bar }

  CALSLT( regs );

  GetTrigger := regs.A;
End;


{ Main program }

Var
       oldIntr    : TInterruptAddress;   { Old interrupt handler }
       userEntry  : TUserEntry;

Begin
  With userEntry Do
  Begin
    bFirstInit := True;
    nStick     := 0;
    nX         := 10;
    nY         := 10;
  End;

  _ClrScr;
  InitProgressTUI;

  SetInterrupt( Addr( __InterruptHandler ),
                Addr( userEntry ),
                SaferInterruptMode,
                oldIntr );

  { Main loop - keyboard user entry }
  Repeat
    userEntry.nStick := GetStick;
  Until( GetTrigger = $FF );  { Until space trigger triggering }

  RestoreInterrupt( oldIntr );
End.
