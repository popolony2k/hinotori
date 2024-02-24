(*<sndtypes.pas>
 * Types and functions to manage all kind of soundchips supported by the
 * MSX standard.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: sndtypes.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/sndtypes.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - systypes.pas;
 * - types.pas;
 * - hooks.pas;
 *)

(**
  * The structure containing the sound chip information for all
  * sound chips supported by MSX system.
  *)
Type PSoundChips = ^TSoundChips;
     TSoundChips = Record
  nSCCPrimarySlot      : Byte;                  { SCC primary slot            }
  nSCCSecondarySlot    : Byte;                  { SCC secondary slot          }
  nYM2151PrimarySlot   : Byte;                  { YM2151 primary slot         }
  nYM2151SecondarySlot : Byte;                  { YM2151 secondary slot       }
  nYM2413SlotNumber    : TSlotNumber;           { YM2413 sound chip handle    }
  hasYMF278B           : Boolean;               { YM278B (OPL4) sound chip    }
  hasY8950             : Boolean;               { Y8950 sound chip            }
  nHostFreqDivisor     : Integer;               { Host frequency divisor      }
  hookHTIMI            : THookCode;             { The original H.TIMI hook    }
  hookHKEYI            : THookCode;             { The original H.KEYI hook    }
End;
