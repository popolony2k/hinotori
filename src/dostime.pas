(*<dostime.pas>
 * Time function implementation for Turbo Pascal 3
 * running on MSX-DOS operating system.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: dostime.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/dostime.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxdos.pas;
 *)

(* Module constant definitions *)

Const     __ctError : Byte = $FF; { MSXDOS error code For internal use only }


(* Time functions implementation *)

(**
  * Set the system time using BDOS call.
  * @param time The @see TTime data variable containing the new system
  * time;
  *)
Function DOSSetTime( time : TTime ) : Boolean;
Var
       regs   : TRegs;

Begin
  regs.C := ctSetTime;
  regs.H := time.nHours;
  regs.L := time.nMinutes;
  regs.D := time.nSeconds;
  regs.E := time.nCentiSeconds;
  regs.A := 0;

  MSXBDOS( regs );
  DOSSetTime := ( regs.A <> __ctError );
End;

(**
  * Retrieve the system time using BDOS call.
  * @param time Reference to the @see TTime structure to receive the system
  * time;
  *)
Procedure DOSGetTime( Var time : TTime );
Var
       regs  : TRegs;

Begin
  regs.C := ctGetTime;

  MSXBDOS( regs );

  time.nHours   := regs.H;
  time.nMinutes := regs.L;
  time.nSeconds := regs.D;
  time.nCentiSeconds := regs.E;
End;

(**
  * Set the system date using BDOS call.
  * @param date The @see TDate data variable containing the new system
  * date;
  *)
Function DOSSetDate( date : TDate ) : Boolean;
Var
       regs  : TRegs;

Begin
  regs.C  := ctSetDate;
  regs.HL := date.nYear;
  regs.D  := date.nMonth;
  regs.E  := date.nDay;
  regs.A  := 0;

  MSXBDOS( regs );

  DOSSetDate := ( regs.A <> __ctError );
End;

(**
  * Retrieve the system date using BDOS call.
  * @param date Reference to the @see TDate structure to receive the system
  * date;
  *)
Procedure DOSGetDate( Var date : TDate );
Var
       regs   : TRegs;

Begin
  regs.C := ctGetDate;

  MSXBDOS( regs );

  date.nYear  := regs.HL;
  date.nMonth := regs.D;
  date.nDay   := regs.E;
End;

(**
  * Get the current date and time storing it on @see TDateTime
  * structure.
  * @param datetime Reference to the structure that will receive
  * the @see TDateTime structure;
  *)
Procedure DOSGetDateTime( Var datetime : TDateTime );
Begin
  DOSGetDate( datetime.date );
  DOSGetTime( datetime.time );
End;
