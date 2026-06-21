(*<dpb.pas>
 * MSXDOS and CP/M DPB (Disk parameter block) structures definitions and
 * functions.
 * Some data structures were converted from ASCII Corp. MSX-C Compiler and
 * others from books and specifications about MSX disk management.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 *)

(**
  * Internal MSXDOS & CP/M80 definitions
  *)

const   ctMaxDskDevices : byte = $8;    { Maximum disk drives devices }

(**
  * Return codes
  *)

const   ctOK            : byte = $0;    { Success }
        ctError         : byte = $1;    { Error }
        ctBDOSErr       : byte = $FF;   { BDOS error value }

(**
  * Disk formats
  *)

const   ctSingleSided31_2 : byte = $F8; { 31/2 Single Sided floppy }
        ctDoubleSided31_2 : byte = $F9; { 31/2 Double Sided floppy }
        ctSingleSided51_4 : byte = $FC; { 51/4 Single Sided floppy }
        ctDoubleSided51_4 : byte = $FD; { 51/4 Double Sided floppy }

(**
  * Disk side
  *)
const   ctSingleSided     : byte = $0;  { Single Sided }
        ctDoubleSided     : byte = $1;  { Double Sided }

(**
  * MSXDOS addresses
  *)
const   ctMaxPhysicalDrv  = $F1C8;      { Maximum Physical drives }
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
type  PFCB = ^TFCB;
      TFCB = record
  nDriveCode    : byte;                  { Drive 0=Current, A=1, B=2, ... }
  aName         : array [0..7] of char;  { File Name }
  aExt          : array [0..2] of char;  { File Name Extension }
  nCurrentBlock : integer;               { Num. blocks from begining of file }
  nRecSize      : integer;               { Record Size Used by Block I/O }
  aFileSize     : array[0..1] of integer;{ File Size in Bytes }
  nFCBDate      : integer;               { File/Directory Date }
  nFCBTime      : integer;               { File/Directory Time }
  nDeviceId     : byte;                  { Device Id }
  nDirLocation  : byte;                  { Directory Location }
  nTopCluster   : integer;               { Top cluster of the file/dir }
  nLastCluster  : integer;               { Last cluster of the file/dir }
  nRelativeRec  : integer;               { RelPos from 1st to last cluster }
  nCurrentRec   : byte;                  { Current record }
  aRndRec       : array[0..1] of integer;{ Random Record from the top of file }
end;

(**
  * Allocation information retrieved by 1Bh BDOS function.
  *)
type TAllocInfo = record
  nSectorsPerCluster   : byte;           { Number of sectors per cluster }
  nSectorSize          : integer;        { Sector size in bytes }
  nTotalClustersOnDisk : integer;        { Total clusters on disk }
  nFreeClustersOnDisk  : integer;        { Free clusters on disk }
end;

(**
  * Disk Parameter Block (DPB) structure definition
  *)
type PDPB = ^TDPB;
     TDPB = record
  nDrvNum               : byte;         { Drive number ( A=0, B=1,... }
  nDiskFormat           : byte;         { Disk Format F8/F9/FA/FB/FC/FD/FE/FF }
  nBytesPerSector       : integer;      { Bytes per sector }
  nDirectoryMask        : byte;         { Directory Mask }
  nDirectoryShift       : byte;         { Directory shift }
  nClusterMask          : byte;         { Cluster mask }
  nClusterShift         : byte;         { Cluster shift - Sectors by cluster }
  nTopOfFATSector       : integer;      { Top os sector FAT }
  nFATCount             : byte;         { Number of FAT's }
  nDirectoryEntries     : byte;         { Directory entries }
  nDataEntrySector      : integer;      { Initial data sector - After FAT }
  nDiskClusters         : integer;      { Disk clusters }
  nSectorsByFAT         : byte;         { Sectors by FAT }
  nDirectoryEntrySector : integer;      { Start of Directory entry (Sector) }
  nFatAreaMemoryAddress : integer;      { FAT Memory Address (RAM) }
  (*
   * The allocation info below is not part
   * of the official CPM80-MSXDOS specification.
   *)
  allocationInfo        : TAllocInfo;   { Allocation info - Not part of DPB }
end;


(**
  * Get the disk parameter block (DPB) for specified drive.
  * @param nDrive The disk drive to retrieve DPB ( A - 0, B - 1, ...);
  * @param DPB The DPB retrieved;
  * The function return:
  * ctError - Operation failed;
  * ctOk - Operation success;
  *)
function GetDPB( nDrive : byte; var DPB : TDPB ) : byte;
var
      nDPBAddr,
      nTotalClusters,
      nFreeClusters,
      nSecSize        : integer;
      nErrorFlag,
      nSecByCluster   : byte;

begin
  nErrorFlag := ctOK;

  if( nDrive > ctMaxDskDevices )  then
    nErrorFlag  := ctError               { Error - Max drives limit reached }
  else
  begin
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
    inline( $DD/$22/nDPBAddr/         { LD (nDPBAddr), IX      }
            $32/nSecByCluster/        { LD (nSecByCluster), A  }
            $ED/$53/nTotalClusters/   { LD (nTotalClusters, DE }
            $22/nFreeClusters/        { LD (nFreeClusters, HL  }
            $ED/$43/nSecSize          { LD (nSecSize), BC      } );

    with DPB.allocationInfo do
    begin
      nSectorsPerCluster   := nSecByCluster;
      nSectorSize          := nSecSize;
      nTotalClustersOnDisk := nTotalClusters;
      nFreeClustersOnDisk  := nFreeClusters;
    end;
  end;

  if( nErrorFlag = ctOK ) then
    Move( Mem[nDPBAddr], DPB, ( sizeof( DPB ) - sizeof( TAllocInfo ) ) );

  GetDPB := nErrorFlag;
end;

(**
  * Get the default Data Transfer Address.
  *)
function GetDefaultDTA : integer;
var
       nDefaultDTA  : integer;
begin
  Move( Mem[ctDefaultDTA], nDefaultDTA, sizeof( nDefaultDTA ) );
  GetDefaultDTA := nDefaultDTA;
end;
