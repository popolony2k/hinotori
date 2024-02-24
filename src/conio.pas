(**<conio.pas>
  * Console functions optimized for MSX.
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: conio.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/conio.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxbios.pas;
 *)

(**
  * All valid text modes.
  *)
Type TTextMode = ( TextMode4080, TextMode32 );

(**
  * All valid cursor status.
  *)
Type TCursorStatus = ( CursorEnabled,
                       CursorDisabled,
                       CursorBlock,
                       CursorUnderscore );

(**
  * Screen status struct used to save the visual status of
  * text screen.
  *)
Type TScreenStatus = Record
  nWidth,
  nBkColor,
  nFgColor,
  nBdrColor   : Byte;
  bFnKeyOn    : Boolean;
  TextMode    : TTextMode;
End;


(* High level routines to control position, size and colors of screen *)

(**
  * Set the new position of cursor to console.
  * @param nPosX The new position in X-Axis;
  * @param nPosY The new position in Y-Axis;
  *)
Procedure _GotoXY( nPosX, nPosY : Byte );
Var
       CSRY : Byte Absolute $F3DC; { Current row-position of the cursor    }
       CSRX : Byte Absolute $F3DD; { Current column-position of the cursor }

Begin
  CSRX := nPosX;
  CSRY := nPosY;
End;

(**
  * Fill a specified screen area with a specified character.
  * @param nX1 Initial X coordinate of area to fill;
  * @param nY1 Initial Y coordinate of area to fill;
  * @param nX2 End X coordinate of area to fill;
  * @param nY2 End Y coordinate of ares to fill;
  *)
Procedure FillArea( nX1, nY1, nX2, nY2 : Byte; chChar : Char );
Var
           nXCounter,
           nYCounter  : Byte;

Begin
  For nYCounter := nY1 To nY2 Do
    For nXCounter := nX1 To nX2 Do
    Begin
      _GotoXY( nXCounter, nYCounter );
      Write( chChar );
    End;
End;

(**
  * Clear the screen;
  *)
Procedure _ClrScr;
Const
        ctCLS     = $00C3;  { Clear screen, including graphic modes }
Var
        regs   : TRegs;
        CSRY   : Byte Absolute $F3DC; { Current row-position of the cursor    }
        CSRX   : Byte Absolute $F3DD; { Current column-position of the cursor }
        EXPTBL : Byte Absolute $FCC1; { Slot 0 }

Begin
  regs.IX := ctCLS;
  regs.IY := EXPTBL;
  (*
   * The Z80 zero flag must be set before calling the CLS BIOS function.
   * Check the MSX BIOS specification
   *)
  Inline( $AF );            { XOR A    }

  CALSLT( regs );
  CSRX := 1;
  CSRY := 1;
End;

(**
  * CHPUT MSXBIOS call implementation.
  * This function print a character to the text screen output;
  * @param chChar The character to output to screen;
  *)
Procedure CHPUT( chChar : Char );
Const
        ctCHPUT   = $00A2;   { Output a character to the console }

Var
        regs    : TRegs;
        EXPTBL  : Byte Absolute $FCC1; { Slot 0 }

Begin
  regs.IX := ctCHPUT;
  regs.IY := EXPTBL;
  regs.A  := Byte( chChar );
  CALSLT( regs );
End;

(**
  * CHGET MSXBIOS call implementation.
  * This function retrieve the user typed key character;
  *)
Function CHGET : Char;
Const
        ctCHGET   = $009F;   { One character console input (waiting) }

Var
        regs    : TRegs;
        EXPTBL  : Byte Absolute $FCC1; { Slot 0 }

Begin
  regs.IX := ctCHGET;
  regs.IY := EXPTBL;
  CALSLT( regs );

  CHGET := Char ( regs.A );
End;

(**
  * Set the new width for the text screen.
  * @param nWidth The new width to set;
  *)
Procedure Width( nWidth : Byte );
Const
       ctINITXT  = $006C; { Initialize screen for text mode (40x24) }

Var
       regs    : TRegs;
       EXPTBL  : Byte Absolute $FCC1; { Slot 0 }
       LINL40  : Byte Absolute $F3AE; { Width for SCREEN 0 }

Begin
  LINL40  := nWidth;
  regs.IX := ctINITXT;
  regs.IY := EXPTBL;
  CALSLT( regs );
End;

(**
  * Change the screen color (Foreground, background and Border);
  * @param nFgColor The foreground color to change;
  * @param nBkColor The backgound color to change;
  * @param nBdrColor The border color to change;
  *)
Procedure Color( nFgColor, nBkColor, nBdrColor : Byte );
Const
        ctCHGCLR  = $0062;    { Changes the color of the screen }

Var
        regs    : TRegs;
        EXPTBL  : Byte Absolute $FCC1; { Slot 0 }
        FORCLR  : Byte Absolute $F3E9; { Foreground color  }
        BAKCLR  : Byte Absolute $F3EA; { Background color  }
        BDRCLR  : Byte Absolute $F3EB; { Border color      }

Begin
  FORCLR  := nFgColor ;
  BAKCLR  := nBkColor;
  BDRCLR  := nBdrColor ;
  regs.IX := ctCHGCLR;
  regs.IY := EXPTBL;
  CALSLT( regs );
End;

(**
  * Set the new text mode;
  * @param mode The new @see TTextMode to set;
  *)
Procedure SetTextMode( mode : TTextMode );
Const
        ctINITXT  = $006C;    { Initialize screen for text mode (40x24) }
        ctINIT32  = $006F;    { Initialize screen mode for text (32x24) }

Var
        regs    : TRegs;
        EXPTBL  : Byte Absolute $FCC1; { Slot 0 }

Begin
  If( mode = TextMode4080 )  Then
    regs.IX := ctINITXT
  Else
    regs.IX := ctINIT32;

  regs.IY := EXPTBL;
  CALSLT( regs );
End;

(**
  * Enable/ disable the function keys.
  * @param nFnKeyStatus The new status for the function keys;
  *)
Procedure SetFnKeyStatus( bFnKeyStatus : Boolean );
Const
          ctERAFNK  = $00CC;    { Erase the function key display   }
          ctDSPFNK  = $00CF;    { Display the function key display }

Var
        regs    : TRegs;
        EXPTBL  : Byte Absolute $FCC1; { Slot 0 }

Begin
  If( bFnKeyStatus )  Then
    regs.IX := ctDSPFNK
  Else
    regs.IX := ctERAFNK;

  regs.IY := EXPTBL;
  CALSLT( regs );
End;

(**
  * Set the cursor status based on valid @see TCursorStatus value;
  * @param cursor The new cursor status (@see TCursorStatus);
  *)
Procedure SetCursorStatus( cursor : TCursorStatus );
Var
     nCount      : Byte;
     strCtrlCode : String[3];

Begin   { Procedure entry point }
  Case( cursor ) Of
    CursorEnabled    : strCtrlCode := 'x5';
    CursorDisabled   : strCtrlCode := 'y5';
    CursorBlock      : strCtrlCode := 'x4';
    CursorUnderscore : strCtrlCode := 'y4';
  End;

  strCtrlCode := #27 + strCtrlCode;

  For nCount := 1 To Length( strCtrlCode ) Do
    CHPUT( strCtrlCode[nCount] );
End;

(**
  * Get the current screen status.
  * @param The reference to receive the current screen
  * status;
  *)
Procedure GetScreenStatus( Var scrStatus : TScreenStatus );
Var
      LINLEN : Byte Absolute $F3B0; { Width for the current text mode         }
      CNSDFG : Byte Absolute $F3DE; { =0 when function keys are not displayed }
      SCRMOD : Byte Absolute $FCAF; { Current screen number }
      FORCLR : Byte Absolute $F3E9; { Foreground color }
      BAKCLR : Byte Absolute $F3EA; { Background color }
      BDRCLR : Byte Absolute $F3EB; { Border color     }

Begin
  With scrStatus Do
  Begin
    nWidth    := LINLEN;
    nBkColor  := BAKCLR;
    nBdrColor := BDRCLR;
    nFgColor  := FORCLR;
    bFnKeyOn  := ( CNSDFG <> 0 );

    If( SCRMOD = 0 )  Then
      TextMode := TextMode4080
    Else
      TextMode := TextMode32;
  End;
End;

(**
  * Set the new screen status, retrieving the old screen
  * status;
  * @param scrStatus The new @see TScreenStatus with the new
  * screen colors and dimension;
  * @param scrRet The old @see TScreenStatus;
  *)
Procedure SetScreenStatus( scrStatus  : TScreenStatus;
                           Var scrRet : TScreenStatus );
Begin
  GetScreenStatus( scrRet );

  Width( scrStatus.nWidth );
  SetFnKeyStatus( scrStatus.bFnKeyOn );
  SetTextMode( scrStatus.TextMode );
  Color( scrStatus.nFgColor,
         scrStatus.nBkColor,
         scrStatus.nBdrColor );
End;
