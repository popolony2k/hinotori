(*<dpb.pas>
 * MSXDOS and CP/M DPB (Disk parameter block) structures definitions and
 * functions.
 * Some data structures were converted from ASCII Corp. MSX-C Compiler and
 * others from books and specifications about MSX disk management.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: dpb.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/dpb.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 *)

(**
  * Internal MSXDOS & CP/M80 definitions
  *)

Const   ctMaxDskDevices : Byte = $8;    { Maximum disk drives devices }

(**
  * Return codes
  *)

Const   ctOK            : Byte = $0;    { Success }
        ctError         : Byte = $1;    { Error }
        ctBDOSErr       : Byte = $FF;   { BDOS error value }

(**
  * Disk formats
  *)

Const   ctSingleSided31_2 : Byte = $F8; { 31/2 Single Sided floppy }
        ctDoubleSided31_2 : Byte = $F9; { 31/2 Double Sided floppy }
        ctSingleSided51_4 : Byte = $FC; { 51/4 Single Sided floppy }
        ctDoubleSided51_4 : Byte = $FD; { 51/4 Double Sided floppy }

(**
  * Disk side
  *)
Const   ctSingleSided     : Byte = $0;  { Single Sided }
        ctDoubleSided     : Byte = $1;  { Double Sided }

(**
  * MSXDOS addresses
  *)
Const   ctMaxPhysicalDrv  = $F1C8;      { Maximum Physical drives }
        ctDefaultDrive    = $F247;      { Default drive }
        ctMSXDOSBoot      = $F346;      { Boot with or without MSXDOS }
        ctMaxLogicalDrv   = $F347;      { Maximum logical drives }
        ctDiskIntfSlot    = $F348;      { Disk interface slot }
        ctRAMFATAddress   = $F34D;      { Copy of FAT in RAM address }
        ctDMAAddress      = $F34F;      { DMA Address }
        ctDefaultDTA      = $F351;      { Data Transfer Address. Known as DMA }
        ctFCBAddress      = $F353;      { FCB address }
        ctDPBAddress      = $F355;      { DPB start address SizeOf(int) step }
                                        { for each system drive ($F355 - A) }
                                        { ($F357 - B ...) }

(**
  * File control block (FCB) data structure
  *)
Type  PFCB = ^TFCB;
      TFCB = Record
  nDriveCode    : Byte;                  { Drive 0=Current, A=1, B=2, ... }
  aName         : Array [0..7] Of Char;  { File Name }
  aExt          : Array [0..2] Of Char;  { File Name Extension }
  nCurrentBlock : Integer;               { Num. blocks from begining of file }
  nRecSize      : Integer;               { Record Size Used by Block I/O }
  aFileSize     : Array[0..1] Of Integer;{ File Size in Bytes }
  nFCBDate      : Integer;               { File/Directory Date }
  nFCBTime      : Integer;               { File/Directory Time }
  nDeviceId     : Byte;                  { Device Id }
  nDirLocation  : Byte;                  { Directory Location }
  nTopCluster   : Integer;               { Top cluster of the file/dir }
  nLastCluster  : Integer;               { Last cluster of the file/dir }
  nRelativeRec  : Integer;               { RelPos from 1st to last cluster }
  nCurrentRec   : Byte;                  { Current record }
  aRndRec       : Array[0..1] Of Integer;{ Random Record from the top of file }
End;

(**
  * Allocation information retrieved by 1Bh BDOS function.
  *)
Type TAllocInfo = Record
  nSectorsPerCluster   : Byte;           { Number of sectors per cluster }
  nSectorSize          : Integer;        { Sector size in bytes }
  nTotalClustersOnDisk : Integer;        { Total clusters on disk }
  nFreeClustersOnDisk  : Integer;        { Free clusters on disk }
End;

(**
  * Disk Parameter Block (DPB) structure definition
  *)
Type PDPB = ^TDPB;
     TDPB = Record
  nDrvNum               : Byte;         { Drive number ( A=0, B=1,... }
  nDiskFormat           : Byte;         { Disk Format F8/F9/FA/FB/FC/FD/FE/FF }
  nBytesPerSector       : Integer;      { Bytes per sector }
  nDirectoryMask        : Byte;         { Directory Mask }
  nDirectoryShift       : Byte;         { Directory shift }
  nClusterMask          : Byte;         { Cluster mask }
  nClusterShift         : Byte;         { Cluster shift - Sectors by cluster }
  nTopOfFATSector       : Integer;      { Top os sector FAT }
  nFATCount             : Byte;         { Number of FAT's }
  nDirectoryEntries     : Byte;         { Directory entries }
  nDataEntrySector      : Integer;      { Initial data sector - After FAT }
  nDiskClusters         : Integer;      { Disk clusters }
  nSectorsByFAT         : Byte;         { Sectors by FAT }
  nDirectoryEntrySector : Integer;      { Start of Directory entry (Sector) }
  nFatAreaMemoryAddress : Integer;      { FAT Memory Address (RAM) }
  (*
   * The allocation info below is not part
   * of the official CPM80-MSXDOS specification.
   *)
  allocationInfo        : TAllocInfo;   { Allocation info - Not part of DPB }
End;


(**
  * Get the disk parameter block (DPB) for specified drive.
  * @param nDrive The disk drive to retrieve DPB ( A - 0, B - 1, ...);
  * @param DPB The DPB retrieved;
  * The function return:
  * ctError - Operation failed;
  * ctOk - Operation success;
  *)
Function GetDPB( nDrive : Byte; Var DPB : TDPB ) : Byte;
Var
      nDPBAddr,
      nTotalClusters,
      nFreeClusters,
      nSecSize        : Integer;
      nErrorFlag,
      nSecByCluster   : Byte;

Begin
  nErrorFlag := ctOK;

  If( nDrive > ctMaxDskDevices )  Then
    nErrorFlag  := ctError               { Error - Max drives limit reached }
  Else
  Begin
    (*
     * Call the GetAlloc (1Bh) BDOS function to retrieve the pointer to the
     * requested DPB.
     *)
    BDOS( $1B {GetAlloc}, nDrive );

    (*
     * Please check the MSX Handbook (4.2 - Environment setting and readout)
     * for details about the registers returned after calling the 1Bh BDOS
     * function call.
     *)
    Inline( $DD/$22/nDPBAddr/         { LD (nDPBAddr), IX      }
            $32/nSecByCluster/        { LD (nSecByCluster), A  }
            $ED/$53/nTotalClusters/   { LD (nTotalClusters, DE }
            $22/nFreeClusters/        { LD (nFreeClusters, HL  }
            $ED/$43/nSecSize          { LD (nSecSize), BC      } );

    With DPB.allocationInfo Do
    Begin
      nSectorsPerCluster   := nSecByCluster;
      nSectorSize          := nSecSize;
      nTotalClustersOnDisk := nTotalClusters;
      nFreeClustersOnDisk  := nFreeClusters;
    End;
  End;

  If( nErrorFlag = ctOK ) Then
    Move( Mem[nDPBAddr], DPB, ( SizeOf( DPB ) - SizeOf( TAllocInfo ) ) );

  GetDPB := nErrorFlag;
End;

(**
  * Get the default Data Transfer Address.
  *)
Function GetDefaultDTA : Integer;
Var
       nDefaultDTA  : Integer;
Begin
  Move( Mem[ctDefaultDTA], nDefaultDTA, SizeOf( nDefaultDTA ) );
  GetDefaultDTA := nDefaultDTA;
End;
