(*<rs232.pas>
 * RS232 function call implementation based on MSX-BIOS calls (EXTBIO).
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /memory/memory.pas;
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 * - /bios/extbio.pas;
 * - /slot/slotutil.pas;
 *)

{$i memory.pas }
{$i types.pas }
{$i msxbios.pas }
{$i extbio.pas }
{$i slotutil.pas}

(* Module useful constants *)

(* RS232 BIOS call function ID - for EXTBIO use *)
const        ctRS232INIT     = 1;   { Initialize RS232 port }
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
const        ctCharLen5Bit   = '5';
             ctCharLen8Bit   = '8';

(**
  * Parity.
  *)
const        ctParityOdd     = 'O';
             ctParityEven    = 'E';
             ctParityNone    = 'N';

(**
  * Stop Bits.
  *)
const        ctStopBit1      = '1';
             ctStopBit2      = '2';
             ctStopBit3      = '3';

(**
  * Flow Control (XON/XOFF).
  *)
const        ctFlowCtrlON    = 'X';
             ctFlowCtrlOFF   = 'N';

(**
  * CTS handshake.
  *)
const        ctCTSRTSYes     = 'H';
             ctCTSRTSNo      = 'N';

(**
  * Auto receive Line Feed control.
  *)
const        ctAutoLFYes     = 'A';
             ctAutoLFNo      = 'N';

(**
  * SI/SO control.
  *)
const        ctSISOYes       = 'S';
             ctSISONo        = 'N';

(**
  * Initialization structure for RS232 communication.
  *)
type TRS232Parms = record
  chCharLen       : char;
  chParity        : char;
  chStopBits      : char;
  chFlowCtrl      : char;
  chCTSRTSCtrl    : char;
  chRecvAutoLF    : char;
  chSndAutoLF     : char;
  chSISOCtrl      : char;
  nRXBaudRate     : integer;
  nTXBaudRate     : integer;
  nTimeout        : byte;
end;


(**
  * Initialize the RS232 communication board.
  * @param commParms The communication parameters;
  * @return The status of initialization. True Success, otherwise Fail;
  *)
function CommInit( var commParms : TRS232Parms ) : boolean;
var
       regs  : TRegs;
       nAddr : integer;

begin
  FillChar( regs, sizeof( regs ), 0 );
  nAddr   := Addr( commParms );
  regs.HL := nAddr;
  regs.B  := GetSlotNumberByAddress( nAddr );
  regs.D  := ctRS232;
  regs.E  := ctRS232INIT;
  EXTBIO( regs );

  CommInit := ( ( ( regs.F and $1 ) <> 1 ) and ( regs.A = 1 ) );
end;

{ TODO: REMOVE AT THE END - WORK IN PROGRESS }

var   parms : TRS232Parms;

begin
  with parms  do
  begin
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
  end;

  WriteLn( CommInit( parms ) );
end.
