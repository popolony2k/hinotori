(*<sunio.pas>
 * MSX-IDE functions library implementation (Sunrise-like) to
 * manage IDE I/O low level functions.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: sunio.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/sunio.pas $
  *)

(*
 * This source file depends on following include files (respect the order):
 * - memory.pas;
 * - types.pas;
 * - msxbios.pas;
 * - suntypes.pas;
 * - doscodes.pas;
 *)

(* Sunrise-like IDE BIOS calls *)

Const     ctBIOSAbsSectorRead  = $7F89;  { Absolute sector read function  }
          ctBIOSAbsSectorWrite = $7F8C;  { Absolute sector write function }


(* BIOS calls implementation *)

(**
  * Perform a low level sector absolute read from IDE connected device.
  * @param nSlotNumber The slot number which the IDE is connected;
  * @param ptrDriveField A pointer to @see TDriveField structure retrieved by
  * @see GetDriveField function <sunwrksp.pas>;
  * @param n24SectorNumber The 24bit sector number to start the I/O
  * operation;
  * @param nSectorsToRead Number of sectors to read;
  * @param nBufferAddress The buffer data address that will receive the
  * data of sector I/O operation;
  * @return The latest status of I/O performed on selected IDE device.
  * This result has the same values of DISKIO DOS function return codes.
  * For this codes please check the <doscodes.pas> module;
  *)
Function SunAbsoluteSectorRead( nSlotNumber : TSlotNumber;
                                ptrDriveField : PDriveField;
                                n24SectorNumber : TInt24;
                                nSectorsToRead : Byte;
                                nBufferAddress : Integer ) : Byte;
Var
      regs  : TRegs;

Begin
  regs.A  := ptrDriveField^.nDeviceCodeByte;
  regs.B  := nSectorsToRead;
  regs.C  := n24SectorNumber[2];
  regs.D  := n24SectorNumber[1];
  regs.E  := n24SectorNumber[0];
  regs.HL := nBufferAddress;
  regs.IX := ctBIOSAbsSectorRead;
  regs.IY := nSlotNumber;

  CALSLT( regs );

  { Check carry for error }
  If( ( regs.F And $1 ) = 0 )  Then
    SunAbsoluteSectorRead := ctDISKIOSuccess
  Else
    SunAbsoluteSectorRead := regs.A;
End;

(**
  * Perform a low level sector absolute write to IDE connected device.
  * @param nSlotNumber The slot number which the IDE is connected;
  * @param ptrDriveField A pointer to @see TDriveField structure retrieved by
  * @see GetDriveField function <sunwrksp.pas>;
  * @param n24SectorNumber The 24bit sector number to start the I/O
  * operation;
  * @param nSectorsToWrite Number of sectors to write;
  * @param nBufferAddress The buffer data address that will written to the
  * sector of connected IDE device;
  * @return The latest status of I/O performed on selected IDE device.
  * This result has the same values of DISKIO DOS function return codes.
  * For this codes please check the <doscodes.pas> module;
  *)
Function SunAbsoluteSectorWrite( nSlotNumber : TSlotNumber;
                                 ptrDriveField : PDriveField;
                                 n24SectorNumber : TInt24;
                                 nSectorsToWrite : Byte;
                                 nBufferAddress : Integer ) : Byte;
Var
      regs  : TRegs;

Begin
  regs.A  := ptrDriveField^.nDeviceCodeByte;
  regs.B  := nSectorsToWrite;
  regs.C  := n24SectorNumber[2];
  regs.D  := n24SectorNumber[1];
  regs.E  := n24SectorNumber[0];
  regs.HL := nBufferAddress;
  regs.IX := ctBIOSAbsSectorWrite;
  regs.IY := nSlotNumber;

  CALSLT( regs );

  { Check carry for error }
  If( ( regs.F And $1 ) = 0 )  Then
    SunAbsoluteSectorWrite := ctDISKIOSuccess
  Else
    SunAbsoluteSectorWrite := regs.A;
End;
