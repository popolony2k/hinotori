(*<conio.pas>
 * Console functions optimized for MSX.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 *)

(**
  * All valid text modes.
  *)
type TTextMode = ( TextMode4080, TextMode32 );

(**
  * All valid cursor status.
  *)
type TCursorStatus = ( CursorEnabled,
                       CursorDisabled,
                       CursorBlock,
                       CursorUnderscore );

(**
  * Screen status struct used to save the visual status of
  * text screen.
  *)
type TScreenStatus = record
  nWidth,
  nBkColor,
  nFgColor,
  nBdrColor   : byte;
  bFnKeyOn    : boolean;
  TextMode    : TTextMode;
end;


(* High level routines to control position, size and colors of screen *)

(**
  * Set the new position of cursor to console.
  * @param nPosX The new position in X-Axis;
  * @param nPosY The new position in Y-Axis;
  *)
procedure _GotoXY( nPosX, nPosY : byte );
var
       CSRY : byte absolute $F3DC; { Current row-position of the cursor    }
       CSRX : byte absolute $F3DD; { Current column-position of the cursor }

begin
  CSRX := nPosX;
  CSRY := nPosY;
end;

(**
  * Fill a specified screen area with a specified character.
  * @param nX1 Initial X coordinate of area to fill;
  * @param nY1 Initial Y coordinate of area to fill;
  * @param nX2 End X coordinate of area to fill;
  * @param nY2 End Y coordinate of ares to fill;
  *)
procedure FillArea( nX1, nY1, nX2, nY2 : byte; chChar : char );
var
           nXCounter,
           nYCounter  : byte;

begin
  for nYCounter := nY1 to nY2 do
    for nXCounter := nX1 to nX2 do
    begin
      _GotoXY( nXCounter, nYCounter );
      Write( chChar );
    end;
end;

(**
  * Clear the screen;
  *)
procedure _ClrScr;
const
        ctCLS     = $00C3;  { Clear screen, including graphic modes }
var
        regs   : TRegs;
        CSRY   : byte absolute $F3DC; { Current row-position of the cursor    }
        CSRX   : byte absolute $F3DD; { Current column-position of the cursor }
        EXPTBL : byte absolute $FCC1; { Slot 0 }

begin
  regs.IX := ctCLS;
  regs.IY := EXPTBL;
  (*
   * The Z80 zero flag must be set before calling the CLS BIOS function.
   * Check the MSX BIOS specification
   *)
  inline( $AF );            { XOR A    }

  CALSLT( regs );
  CSRX := 1;
  CSRY := 1;
end;

(**
  * CHPUT MSXBIOS call implementation.
  * This function print a character to the text screen output;
  * @param chChar The character to output to screen;
  *)
procedure CHPUT( chChar : char );
const
        ctCHPUT   = $00A2;   { Output a character to the console }

var
        regs    : TRegs;
        EXPTBL  : byte absolute $FCC1; { Slot 0 }

begin
  regs.IX := ctCHPUT;
  regs.IY := EXPTBL;
  regs.A  := byte( chChar );
  CALSLT( regs );
end;

(**
  * CHGET MSXBIOS call implementation.
  * This function retrieve the user typed key character;
  *)
function CHGET : char;
const
        ctCHGET   = $009F;   { One character console input (waiting) }

var
        regs    : TRegs;
        EXPTBL  : byte absolute $FCC1; { Slot 0 }

begin
  regs.IX := ctCHGET;
  regs.IY := EXPTBL;
  CALSLT( regs );

  CHGET := char ( regs.A );
end;

(**
  * Set the new width for the text screen.
  * @param nWidth The new width to set;
  *)
procedure Width( nWidth : byte );
const
       ctINITXT  = $006C; { Initialize screen for text mode (40x24) }

var
       regs    : TRegs;
       EXPTBL  : byte absolute $FCC1; { Slot 0 }
       LINL40  : byte absolute $F3AE; { Width for SCREEN 0 }

begin
  LINL40  := nWidth;
  regs.IX := ctINITXT;
  regs.IY := EXPTBL;
  CALSLT( regs );
end;

(**
  * Change the screen color (Foreground, background and Border);
  * @param nFgColor The foreground color to change;
  * @param nBkColor The backgound color to change;
  * @param nBdrColor The border color to change;
  *)
procedure Color( nFgColor, nBkColor, nBdrColor : byte );
const
        ctCHGCLR  = $0062;    { Changes the color of the screen }

var
        regs    : TRegs;
        EXPTBL  : byte absolute $FCC1; { Slot 0 }
        FORCLR  : byte absolute $F3E9; { Foreground color  }
        BAKCLR  : byte absolute $F3EA; { Background color  }
        BDRCLR  : byte absolute $F3EB; { Border color      }

begin
  FORCLR  := nFgColor ;
  BAKCLR  := nBkColor;
  BDRCLR  := nBdrColor ;
  regs.IX := ctCHGCLR;
  regs.IY := EXPTBL;
  CALSLT( regs );
end;

(**
  * Set the new text mode;
  * @param mode The new @see TTextMode to set;
  *)
procedure SetTextMode( mode : TTextMode );
const
        ctINITXT  = $006C;    { Initialize screen for text mode (40x24) }
        ctINIT32  = $006F;    { Initialize screen mode for text (32x24) }

var
        regs    : TRegs;
        EXPTBL  : byte absolute $FCC1; { Slot 0 }

begin
  if( mode = TextMode4080 )  then
    regs.IX := ctINITXT
  else
    regs.IX := ctINIT32;

  regs.IY := EXPTBL;
  CALSLT( regs );
end;

(**
  * Enable/ disable the function keys.
  * @param nFnKeyStatus The new status for the function keys;
  *)
procedure SetFnKeyStatus( bFnKeyStatus : boolean );
const
          ctERAFNK  = $00CC;    { Erase the function key display   }
          ctDSPFNK  = $00CF;    { Display the function key display }

var
        regs    : TRegs;
        EXPTBL  : byte absolute $FCC1; { Slot 0 }

begin
  if( bFnKeyStatus )  then
    regs.IX := ctDSPFNK
  else
    regs.IX := ctERAFNK;

  regs.IY := EXPTBL;
  CALSLT( regs );
end;

(**
  * Set the cursor status based on valid @see TCursorStatus value;
  * @param cursor The new cursor status (@see TCursorStatus);
  *)
procedure SetCursorStatus( cursor : TCursorStatus );
var
     nCount      : byte;
     strCtrlCode : string[3];

begin   { Procedure entry point }
  case( cursor ) of
    CursorEnabled    : strCtrlCode := 'x5';
    CursorDisabled   : strCtrlCode := 'y5';
    CursorBlock      : strCtrlCode := 'x4';
    CursorUnderscore : strCtrlCode := 'y4';
  end;

  strCtrlCode := #27 + strCtrlCode;

  for nCount := 1 to Length( strCtrlCode ) do
    CHPUT( strCtrlCode[nCount] );
end;

(**
  * Get the current screen status.
  * @param The reference to receive the current screen
  * status;
  *)
procedure GetScreenStatus( var scrStatus : TScreenStatus );
var
      LINLEN : byte absolute $F3B0; { Width for the current text mode         }
      CNSDFG : byte absolute $F3DE; { =0 when function keys are not displayed }
      SCRMOD : byte absolute $FCAF; { Current screen number }
      FORCLR : byte absolute $F3E9; { Foreground color }
      BAKCLR : byte absolute $F3EA; { Background color }
      BDRCLR : byte absolute $F3EB; { Border color     }

begin
  with scrStatus do
  begin
    nWidth    := LINLEN;
    nBkColor  := BAKCLR;
    nBdrColor := BDRCLR;
    nFgColor  := FORCLR;
    bFnKeyOn  := ( CNSDFG <> 0 );

    if( SCRMOD = 0 )  then
      TextMode := TextMode4080
    else
      TextMode := TextMode32;
  end;
end;

(**
  * Set the new screen status, retrieving the old screen
  * status;
  * @param scrStatus The new @see TScreenStatus with the new
  * screen colors and dimension;
  * @param scrRet The old @see TScreenStatus;
  *)
procedure SetScreenStatus( scrStatus  : TScreenStatus;
                           var scrRet : TScreenStatus );
begin
  GetScreenStatus( scrRet );

  Width( scrStatus.nWidth );
  SetFnKeyStatus( scrStatus.bFnKeyOn );
  SetTextMode( scrStatus.TextMode );
  Color( scrStatus.nFgColor,
         scrStatus.nBkColor,
         scrStatus.nBdrColor );
end;
