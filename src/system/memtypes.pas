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

Const    ctMemPage0Addr : Integer = $0000;   { Memory page 0 base address }
         ctMemPage1Addr : Integer = $4000;   { Memory page 1 base address }
         ctMemPage2Addr : Integer = $8000;   { Memory page 2 base address }
         ctMemPage3Addr : Integer = $C000;   { Memory page 3 base address }

(**
  * Supported memory types.
  *)
Type TMemoryType = ( MemAnyMemory,
                     MemMemoryMapper,
                     MemMegaRAM );

(**
  * Set for TMemoryType.
  *)
Type TMemoryTypeSet = Set Of TMemoryType;
