(*<types.pas>
 * New types definition and function to extend and
 * compatibilize Turbo Pascal 3 with new Pascal
 * and Delphi versions.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(* Module useful constants *)

const                  ctMaxPath         = 127; { Maximum path size - MSXDOS2 }
                       ctMaxDirName      = 11;  { Directory name entry size }
                       ctUnitializedSlot = 255; { Unitialized slot id }

(**
  * New types definitions
  *)
type TWord          = integer;                  { 16Bit Unsigned - reserved }
     TInteger       = integer;                  { Signed integer }
     TChar          = char;                     { Character (1 byte) }
     TInt24         = array[0..2] of byte;      { 24Bit integer }
     TInt32         = array[0..3] of byte;      { 32Bit integer }
     TTinyString    = string[40];               { String 40 byte size }
     PTinyString    = ^TTinyString;             { TTinyString pointer }
     TShortString   = string[80];               { String 80 byte size }
     PShortString   = ^TShortString;            { TShortString pointer }
     TString        = string[255];              { String 255 byte size }
     PString        = ^TString;                 { TString pointer }
     TFileName      = string[ctMaxPath];        { File name path type }
     PFileName      = ^TFileName;               { TFileName pointer }
     TDirectoryName = string[ctMaxDirName];     { Directory Name type }
     PDirectoryName = ^TDirectoryName;          { TDirectoryName pointer }
     THexadecimal   = string[2];                { Hexadecimal type }
     Pointer        = ^byte;                    { Pointer generic type }
     TDynCharArray  = array [0..0] of char;     { Dynamic char array }
     PDynCharArray  = ^TDynCharArray;           { Dynamic char array pointer }
     TDynByteArray  = array [0..0] of byte;     { Dynamic byte array }
     PDynByteArray  = ^TDynByteArray;           { Dynamic byte array pointer }
     TDynIntArray   = array [0..0] of integer;  { Dynamic int array }
     PDynIntArray   = ^TDynIntArray;            { Dynamic int array pointer }
     TDynRealArray  = array [0..0] of real;     { Dynamic Real array }
     PDynRealArray  = ^TDynRealArray;           { Dynamic Real array pointer }
     TSlotNumber    = byte;                     { Slot identification }

(**
  * Date and time structures for MSXDOS functions
  *)
type TTime = record
  nHours,
  nMinutes,
  nSeconds,
  nCentiSeconds  : byte;
end;

type TDate = record
  nDay,
  nMonth         : byte;
  nYear          : integer;
end;

type TDateTime = record
  date : TDate;
  time : TTime;
end;

(**
  * Z80 registers struct/union definition
  *)
type TRegs = record
  IX       : integer;                     { 16Bit index registers }
  IY       : integer;

  case byte of    { 8Bit registers and 16Bit registers - WORD_REGS }
    0 : ( C,B,E,D,L,H,F,A  : byte );      { 8bit registers  }
    1 : ( BC,DE,HL,AF      : integer );   { 16bit registers }
end;
