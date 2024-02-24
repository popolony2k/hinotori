(*<sndchips.pas>
 * Common parameters and structures to be used by all sound chip
 * implementation.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 *)

(**
  * Sound chips common constants.
  *)
Const
       ctSndChipResetDelay     : Integer = $05; { Chip reset delay time }

(**
  * Sound chips common parameter data.
  *)
Var
       __pSndChipArrayParms : Pointer;          { Sound chip buffer pointer   }


