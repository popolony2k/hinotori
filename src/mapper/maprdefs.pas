(*<maprdefs.pas>
 * Common Memory mapper definitions for all implementations (Direct and BIOS).
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 *)


(**
  * Module constants and definitions.
  *)
Const
               ctFreeSegment     : Byte    = $00;     { Unallocated segment  }
               ctReservedSegment : Byte    = $01;     { Reserved segment     }
               ctMapperPortPage0 : Byte    = $FC;     { Memory page 0 port   }
               ctMapperPortPage1 : Byte    = $FD;     { Memory page 1 port   }
               ctMapperPortPage2 : Byte    = $FE;     { Memory page 2 port   }
               ctMapperPortPage3 : Byte    = $FF;     { Memory page 3 port   }
               ctMapperPageSize            = $4000;   { Mapper page size 16k }
               ctMapperSegsSize            = $FF;     { Max. mapper segments }

(**
  * Segment types.
  *)
Type TSegmentType = ( UserSegment, SystemSegment );

(**
  * Mapper table strcuture definition.
  *)
Type PMapperVarTable = ^TMapperVarTable;
     TMapperVarTable = Record
  nSlotId         : TSlotNumber;         { Slot address of the mapper slot   }
  nTotalSegs      : Byte;                { Total number of 16Kb RAM segments }
  nFreeSegs       : Byte;                { Number of free segments           }
  nSystemSegs     : Byte;                { Allocated system segments         }
  nUserSegs       : Byte;                { Allocated user segments           }
  aFreeSpace      : Array[0..2] Of Byte; { Free space                        }
End;

(**
  * The mapper handle type for using all other mapper functions.
  *)
Type PMapperHandle = ^TMapperHandle;
     TMapperHandle = Record
  nMapperVarTblAddr  : Integer;          { Start address of mapper var. tabl }
  nPriMapperSlotId   : TSlotNumber;      { Slot address of primary mapper    }
  nTotalMapperSegs   : Byte;             { Total segments of primary mapper  }
  nFreePriMapperSegs : Byte;             { Free segments of primary mapper   }
  nStartAddrJumpTbl  : Integer;          { Start address of jump table       }
End;
