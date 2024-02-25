(*<sleep.pas>
 * Sleep accurate routines to overload the inaccurate Turbo Pascal's
 * builtin Delay procedure.
 * This module implements a Sleep routine based on JIFFY MSX system variable.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/systypes.pas;
 *)

Var
       __nSleepInterval     : Integer;

(**
  * Implements a new accurate Sleep routine (16bit resolution);
  * @param __nSleepInterval The specified time in 1/60 (or 1/50)
  * intervals;
  *)
Procedure SleepDirect{( __nSleepInterval : Integer )};
Begin
  JIFFY := 0;

  {%W+}
  While( __nSleepInterval > JIFFY ) Do;
  {%W-}
End;

(**
  * Implements a new accurate Sleep routine (16bit resolution);
  * @param nInterval The specified time in 1/60 (or 1/50) intervals;
  *)
Procedure Sleep( nInterval : Integer );
Begin
  __nSleepInterval := nInterval;
  SleepDirect{( __nSleepInterval )};
End;
