(*<dostest.pas>
 * MSXDOS library sample test.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
Program MSXDOS_Test;


(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /dos/dpb.pas;
 *)

{$i ../../src/system/types.pas}
{$i ../../src/dos/dpb.pas}

Var      DPB      : TDPB;
         nError,
         nDrive   : Integer;
         strDrive : String[2];

Begin
  If( ParamCount > 0 )  Then
    Val( ParamStr( 1 ), nDrive, nError )
  Else
    nDrive := 0;

  If( GetDPB( nDrive, DPB ) = ctError ) Then
  Begin
    WriteLn( 'Invalid drive' );
    Exit;
  End;

  strDrive := Char( Byte( 'A' ) + DPB.nDrvNum ) + ':';

  WriteLn( 'MSXDD Tools. CopyLeft (c) 1995-2011 by PopolonY2k' );
  WriteLn;
  WriteLn;
  WriteLn( 'Disk parameter block' );
  WriteLn;
  WriteLn( 'Drive letter                 -> ', strDrive );
  WriteLn( 'Disk Format                  -> ', DPB.nDiskFormat );
  WriteLn( 'Bytes per sector             -> ', DPB.nBytesPerSector );
  WriteLn( 'Directory mask               -> ', DPB.nDirectoryMask );
  WriteLn( 'Directory shift              -> ', DPB.nDirectoryShift );
  WriteLn( 'Cluster mask                 -> ', DPB.nClusterMask );
  WriteLn( 'Cluster shift                -> ', DPB.nClusterShift );
  WriteLn( 'Top of FAT sector            -> ', DPB.nTopOfFATSector );
  WriteLn( 'Number of FATs               -> ', DPB.nFATCount );
  WriteLn( 'Directory entries            -> ', DPB.nDirectoryEntries );
  WriteLn( 'Data disk sector             -> ', DPB.nDataEntrySector );
  WriteLn( 'Number of disk clusters (+1) -> ', DPB.nDiskClusters );
  WriteLn( 'Sectors by FAT               -> ', DPB.nSectorsByFAT );
  WriteLn( 'Directory entry sector       -> ', DPB.nDirectoryEntrySector );
  WriteLn( 'FAT memory address (RAM)     -> ', DPB.nFATAreaMemoryAddress );

  WriteLn;
  WriteLn( 'Non DPB info (1Bh BDOS call)' );
  WriteLn;

  With DPB.allocationInfo Do
  Begin
    WriteLn( 'Sectors per cluster          -> ', nSectorsPerCluster );
    WriteLn( 'Sector size (in bytes)       -> ', nSectorSize );
    WriteLn( 'Total clusters on disk       -> ', nTotalClustersOnDisk );
    WriteLn( 'Free clusters on disk        -> ', nFreeClustersOnDisk );
  End;
End.
