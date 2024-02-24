(*<sleep.pas>
 * Sleep accurate routines to overload the inaccurate Turbo Pascal's
 * builtin Delay procedure.
 * This module implements a Sleep routine based on JIFFY MSX system variable.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: sleep.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/sleep.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - systypes.pas;
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
