(*<memtypes.pas>
 * Memory type definitions for use with all kinds of memory available to
 * the MSX standard.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* Module definitions *)

const    ctMemPage0Addr : integer = $0000;   { Memory page 0 base address }
         ctMemPage1Addr : integer = $4000;   { Memory page 1 base address }
         ctMemPage2Addr : integer = $8000;   { Memory page 2 base address }
         ctMemPage3Addr : integer = $C000;   { Memory page 3 base address }

(**
  * Supported memory types.
  *)
type TMemoryType = ( MemAnyMemory,
                     MemMemoryMapper,
                     MemMegaRAM );

(**
  * Set for TMemoryType.
  *)
type TMemoryTypeSet = set of TMemoryType;
