(*<sunatapi.pas>
 * MSX-IDE functions library implementation (Sunrise-like) to
 * handle IDE ATAPI functions.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * - /memory/memory.pas;
 * - /system/types.pas;
 * - /bios/msxbios.pas;
 *)

(* Sunrise-like IDE BIOS calls *)

const     ctBIOSSelectATAPIDevice = $7FB9; { Select master or slave device }
          ctBIOSSendATAPIPacket   = $7FBC; { Send ATAPI to selected device }

(* Library internal constants *)

const     ctATAPIPacketSize       = 11;    { ATAPI packet size }


(**
  * ATAPI device type required by @see SelectATAPIDevice function.
  *)
type TATAPIDeviceType = ( ATAPIMaster, ATAPISlave );

(**
  * Return codes for ATAPI BIOS call operations.
  *)
type TATAPIOperationCode = ( ATAPIControllerTimeout,
                             ATAPIError,
                             ATAPISuccess );

(**
  * ATAPI command data transmission buffer.
  *)
type TATAPIPacket = array[0..ctATAPIPacketSize] of byte;
     PATAPIPacket = ^TATAPIPacket;


(* BIOS calls implementation *)

(**
  * Select a device for ATAPI command transmission operations through the
  * @see SendATAPIPacket function.
  * @param nSlotNumber The slot number which IDE is connected;
  * @param devType The @see TATAPIDeviceType parameter to select;
  *)
function SelectATAPIDevice( nSlotNumber : TSlotNumber;
                            devType : TATAPIDeviceType ) : TATAPIOperationCode;
var
      regs  : TRegs;

begin
  case devType of
    ATAPIMaster : regs.A := 0;
    ATAPISlave  : regs.A := 1;
  end;

  regs.IX := ctBIOSSelectATAPIDevice;
  regs.IY := nSlotNumber;

  CALSLT( regs );

  { Check carry for controller timeout }
  if( ( regs.F and $1 ) = 0 )  then
    SelectATAPIDevice := ATAPISuccess
  else
    SelectATAPIDevice := ATAPIControllerTimeout;
end;

(**
  * Send a packet for the selected device throught @see SelectATAPIDevice;
  * @param nSlotNumber The slot number which IDE is connected;
  * @param packet The ATAPI data to send to device;
  * @param nRetBufferAddr The address of the return buffer allocated to
  * receive the ATAPI requested data, if any;
  * @param nErrorRegister If the function return ATAPIError, the variable
  * referenced by this parameter will be filled with the content of error
  * register from controller;
  *)
function SendATAPIPacket( nSlotNumber : TSlotNumber;
                          var packet : TATAPIPacket;
                          nRetBufferAddr : integer;
                          var nErrorRegister : byte ) : TATAPIOperationCode;
var
      regs     : TRegs;
      bCarryOn : boolean;

begin
  regs.HL := Addr( packet );
  regs.DE := nRetBufferAddr;
  regs.IX := ctBIOSSendATAPIPacket;
  regs.IY := nSlotNumber;

  CALSLT( regs );

  { Check for all ATAPI controller errors }
  bCarryOn := ( ( regs.F and $1 ) = 1 );

  if( not bCarryOn )  then
    SendATAPIPacket := ATAPISuccess
  else
    if( bCarryOn and ( ( regs.F and $40 ) = 1 ) )  then
    begin
      nErrorRegister  := regs.A;
      SendATAPIPacket := ATAPIError;
    end
    else
      SendATAPIPacket := ATAPIControllerTimeout;
end;
