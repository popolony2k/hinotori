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
const
               ctFreeSegment     : byte    = $00;     { Unallocated segment  }
               ctReservedSegment : byte    = $01;     { Reserved segment     }
               ctMapperPortPage0 : byte    = $FC;     { Memory page 0 port   }
               ctMapperPortPage1 : byte    = $FD;     { Memory page 1 port   }
               ctMapperPortPage2 : byte    = $FE;     { Memory page 2 port   }
               ctMapperPortPage3 : byte    = $FF;     { Memory page 3 port   }
               ctMapperPageSize            = $4000;   { Mapper page size 16k }
               ctMapperSegsSize            = $FF;     { Max. mapper segments }

(**
  * Segment types.
  *)
type TSegmentType = ( UserSegment, SystemSegment );

(**
  * Mapper table strcuture definition.
  *)
type PMapperVarTable = ^TMapperVarTable;
     TMapperVarTable = record
  nSlotId         : TSlotNumber;         { Slot address of the mapper slot   }
  nTotalSegs      : byte;                { Total number of 16Kb RAM segments }
  nFreeSegs       : byte;                { Number of free segments           }
  nSystemSegs     : byte;                { Allocated system segments         }
  nUserSegs       : byte;                { Allocated user segments           }
  aFreeSpace      : array[0..2] of byte; { Free space                        }
end;

(**
  * The mapper handle type for using all other mapper functions.
  *)
type PMapperHandle = ^TMapperHandle;
     TMapperHandle = record
  nMapperVarTblAddr  : integer;          { Start address of mapper var. tabl }
  nPriMapperSlotId   : TSlotNumber;      { Slot address of primary mapper    }
  nTotalMapperSegs   : byte;             { Total segments of primary mapper  }
  nFreePriMapperSegs : byte;             { Free segments of primary mapper   }
  nStartAddrJumpTbl  : integer;          { Start address of jump table       }
end;
