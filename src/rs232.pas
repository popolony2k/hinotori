(*<rs232.pas>
 * RS232 function call implementation based on MSX-BIOS calls (EXTBIO).
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: rs232.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/rs232.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - memory.pas;
 * - types.pas;
 * - msxbios.pas;
 * - extbio.pas;
 * - slotutil.pas;
 *)

{$i memory.pas }
{$i types.pas }
{$i msxbios.pas }
{$i extbio.pas }
{$i slotutil.pas}

(* Module useful constants *)

(* RS232 BIOS call function ID - for EXTBIO use *)
Const        ctRS232INIT     = 1;   { Initialize RS232 port }
             ctRS232OPEN     = 2;   { Open RS232 port }
             ctRS232STAT     = 3;   { Read status }
             ctRS232GETCHR   = 4;   { Receive data }
             ctRS232SNDCHR   = 5;   { Send data }
             ctRS232CLOSE    = 6;   { Close RS232 port }
             ctRS232EOF      = 7;   { Tell EOF code received }
             ctRS232LOC      = 8;   { Number of chars in receiver buffer }
             ctRS232LOF      = 9;   { Free space left in receiver buffer }
             ctRS232BACKUP   = $A;  { Backup a character }
             ctRS232SNDBRK   = $B;  { Send a break character }
             ctRS232DTR      = $C;  { Turn ON/OFF DTR line }
             ctRS232SETCHN   = $D;  { Set channel number }

(**
  * Character lenght.
  *)
Const        ctCharLen5Bit   = '5';
             ctCharLen8Bit   = '8';

(**
  * Parity.
  *)
Const        ctParityOdd     = 'O';
             ctParityEven    = 'E';
             ctParityNone    = 'N';

(**
  * Stop Bits.
  *)
Const        ctStopBit1      = '1';
             ctStopBit2      = '2';
             ctStopBit3      = '3';

(**
  * Flow Control (XON/XOFF).
  *)
Const        ctFlowCtrlON    = 'X';
             ctFlowCtrlOFF   = 'N';

(**
  * CTS handshake.
  *)
Const        ctCTSRTSYes     = 'H';
             ctCTSRTSNo      = 'N';

(**
  * Auto receive Line Feed control.
  *)
Const        ctAutoLFYes     = 'A';
             ctAutoLFNo      = 'N';

(**
  * SI/SO control.
  *)
Const        ctSISOYes       = 'S';
             ctSISONo        = 'N';

(**
  * Initialization structure for RS232 communication.
  *)
Type TRS232Parms = Record
  chCharLen       : Char;
  chParity        : Char;
  chStopBits      : Char;
  chFlowCtrl      : Char;
  chCTSRTSCtrl    : Char;
  chRecvAutoLF    : Char;
  chSndAutoLF     : Char;
  chSISOCtrl      : Char;
  nRXBaudRate     : Integer;
  nTXBaudRate     : Integer;
  nTimeout        : Byte;
End;


(**
  * Initialize the RS232 communication board.
  * @param commParms The communication parameters;
  * @return The status of initialization. True Success, otherwise Fail;
  *)
Function CommInit( Var commParms : TRS232Parms ) : Boolean;
Var
       regs  : TRegs;
       nAddr : Integer;

Begin
  FillChar( regs, SizeOf( regs ), 0 );
  nAddr   := Addr( commParms );
  regs.HL := nAddr;
  regs.B  := GetSlotNumberByAddress( nAddr );
  regs.D  := ctRS232;
  regs.E  := ctRS232INIT;
  EXTBIO( regs );

  CommInit := ( ( ( regs.F And $1 ) <> 1 ) And ( regs.A = 1 ) );
End;

{ TODO: REMOVE AT THE END }

Var   parms : TRS232Parms;

Begin
  With parms  Do
  Begin
    chCharLen    := ctCharLen8Bit;
    chParity     := ctParityOdd;
    chStopBits   := ctStopBit1;
    chFlowCtrl   := ctFlowCtrlON;
    chCTSRTSCtrl := ctCTSRTSYes;
    chRecvAutoLF := ctAutoLFYes;
    chSndAutoLF  := ctAutoLFYes;
    chSISOCtrl   := ctSISOYes;
    nRXBaudRate  := 75;
    nTXBaudRate  := 75;
    nTimeout     := 20;
  End;

  WriteLn( CommInit( parms ) );
End.
