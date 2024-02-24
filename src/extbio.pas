(*<extbio.pas>
 * Extended BIOS call implementation for use of new devices
 * that implements new BIOS calls to MSX.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: extbio.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/extbio.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxbios.pas;
 *)

(* Module useful constants *)

Const         { EXTBIO valid addresses }
              ctEXTBIO     = $FFCA;    { The EXTBIO hook }
              { The constants below represents all known extended devices }
              ctReserved   = $00;      { Reserved for broadcasters }
              ctDOS2Memory = $04;      { MSXDOS2 memory management BIOS calls }
              ctRS232      = $08;      { RS232 BIOS calls }
              ctMSXAUDIO   = $0A;      { MSX- AUDIO BIOS calls }
              ctKanji      = $11;      { Kanji BIOS support }
              ctUNAPI      = $22;      { UNAPI BIOS calls - Konamiman }
              ctMemMan     = $4D;      { MemMan - memory mapper library calls }
              { TODO: Are needed ctMapperVar and ctMapperAddr constants ?? }
              {ctMapperVar  = $29;}      { Mapper variable table }
              {ctMapperAddr = $2A;}      { Mapper support routines addresses }
              ctSystem     = $FF;      { System exclusive calls }


(**
  * Check if there a installed hook to a new BIOS call.
  * @return The status of hook installation;
  *)
Function HasInstalledHook : Boolean;
Var
         nHOKVLD : Byte Absolute $FB20;  { Valid hook ??? }
Begin
  HasInstalledHook := Odd( nHOKVLD And 1 );
End;

(**
  * Call the extended BIOS function.
  * @param regs The register structure variable with the Extended BIOS
  * parameters to pass to the BIOS function call;
  * The register structure passed by parameter is modified by the BIOS
  * function call;
  * The MSX standard specify that register D must receive the device id
  * of extended BIOS and the register E the function number to call in
  * the extended BIOS call.
  *)
Procedure EXTBIO( Var regs : TRegs );
Var
     nRAMAD3 : Byte Absolute $F344; { Slot addr.of RAM in page 3 (DOS/BASIC) }
Begin
  regs.IX := ctEXTBIO;
  regs.IY := nRAMAD3;
  CALSLT( regs );
End;
