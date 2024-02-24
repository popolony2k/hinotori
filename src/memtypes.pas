(*<memtypes.pas>
 * Memory type definitions for use with all kinds of memory available to
 * the MSX standard.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: memtypes.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/memtypes.pas $
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
