(*<systypes.pas>
 * Type definition for system operations related.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)


(**
  * The host interrupt timing.
  *)
type THostInterruptTiming = ( TimingUndefined, Timing50Hz, Timing60Hz );


(**
  * MSX system variables for timming control.
  *)
var
         JIFFY     : integer absolute $FC9E; { MSX JIFFY variable  }
