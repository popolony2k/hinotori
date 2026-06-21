(*<dostime.pas>
 * Time function implementation for Turbo Pascal 3
 * running on MSX-DOS operating system.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /dos/msxdos.pas;
 *)

(* Module constant definitions *)

const     __ctError : byte = $FF; { MSXDOS error code For internal use only }


(* Time functions implementation *)

(**
  * Set the system time using BDOS call.
  * @param time The @see TTime data variable containing the new system
  * time;
  *)
function DOSSetTime( time : TTime ) : boolean;
var
       regs   : TRegs;

begin
  regs.C := ctSetTime;
  regs.H := time.nHours;
  regs.L := time.nMinutes;
  regs.D := time.nSeconds;
  regs.E := time.nCentiSeconds;
  regs.A := 0;

  MSXBDOS( regs );
  DOSSetTime := ( regs.A <> __ctError );
end;

(**
  * Retrieve the system time using BDOS call.
  * @param time Reference to the @see TTime structure to receive the system
  * time;
  *)
procedure DOSGetTime( var time : TTime );
var
       regs  : TRegs;

begin
  regs.C := ctGetTime;

  MSXBDOS( regs );

  time.nHours   := regs.H;
  time.nMinutes := regs.L;
  time.nSeconds := regs.D;
  time.nCentiSeconds := regs.E;
end;

(**
  * Set the system date using BDOS call.
  * @param date The @see TDate data variable containing the new system
  * date;
  *)
function DOSSetDate( date : TDate ) : boolean;
var
       regs  : TRegs;

begin
  regs.C  := ctSetDate;
  regs.HL := date.nYear;
  regs.D  := date.nMonth;
  regs.E  := date.nDay;
  regs.A  := 0;

  MSXBDOS( regs );

  DOSSetDate := ( regs.A <> __ctError );
end;

(**
  * Retrieve the system date using BDOS call.
  * @param date Reference to the @see TDate structure to receive the system
  * date;
  *)
procedure DOSGetDate( var date : TDate );
var
       regs   : TRegs;

begin
  regs.C := ctGetDate;

  MSXBDOS( regs );

  date.nYear  := regs.HL;
  date.nMonth := regs.D;
  date.nDay   := regs.E;
end;

(**
  * Get the current date and time storing it on @see TDateTime
  * structure.
  * @param datetime Reference to the structure that will receive
  * the @see TDateTime structure;
  *)
procedure DOSGetDateTime( var datetime : TDateTime );
begin
  DOSGetDate( datetime.date );
  DOSGetTime( datetime.time );
end;
