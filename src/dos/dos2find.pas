(*<dos2find.pas>
 * MSXDOS2 file search (_FFIRST/_FNEXT) wrapper.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /dos/msxdos.pas;
 * - /dos/msxdos2.pas;
 *)

const   ctFindAnyAttr   : byte = $3F; { Match entries of any attribute }
        ctAttrDirectory : byte = $10; { Directory attribute bit }

(**
  * MSXDOS2 fileinfo block, filled in by _FFIRST/_FNEXT (BDOS functions
  * 40h/41h). Layout per the MSX-DOS2 Program Interface Specification,
  * section 3.4 "File info blocks":
  * 0      - Always $FF (marker);
  * 1..13  - Filename as an ASCIIZ string ("NAME.EXT", null terminated);
  * 14     - File attributes byte;
  * 15..16 - Time of last modification (packed, low byte first);
  * 17..18 - Date of last modification (packed, low byte first);
  * 19..20 - Start cluster;
  * 21..24 - File size (32bit, low byte first);
  * 25     - Logical drive;
  * 26..63 - Search continuation data; must not be modified by callers.
  * @see https://map.grauw.nl/resources/dos2_environment.php (section 3.4,
  * "File Info Blocks")
  *)
type PFileInfoBlock = ^TFileInfoBlock;
     TFileInfoBlock = record
  nMarker   : byte;
  aName     : array[0..12] of char;
  nAttr     : byte;
  aTime     : array[0..1] of byte;     { [0]=low byte, [1]=high byte }
  aDate     : array[0..1] of byte;     { [0]=low byte, [1]=high byte }
  nCluster  : integer;
  aSize     : array[0..3] of byte;
  nDrive    : byte;
  aReserved : array[0..37] of byte;
end;

(**
  * Locate the first directory entry matching a glob pattern.
  * @param strPattern The drive/path/filename pattern to search (may
  * contain '*' and '?');
  * @param nAttrMask Attribute bits that should additionally match (eg.
  * ctAttrDirectory to also enumerate subdirectories; ctFindAnyAttr to
  * match entries of any attribute);
  * @param info Reference to the fileinfo block that receives the match
  * and the search continuation context. Must be passed unchanged to a
  * following @see FindNext call;
  * The function returns true on a match, false otherwise.
  *)
function FindFirst( strPattern : TFileName;
                       nAttrMask : byte;
                       var info : TFileInfoBlock ) : boolean;
var
      szPattern : array[0..ctMaxPath] of char;
      regs      : TRegs;
      nPos      : byte;

begin
  for nPos := 1 to Length( strPattern ) do
    szPattern[nPos - 1] := strPattern[nPos];

  szPattern[nPos] := #0;

  FillChar( regs, sizeof( regs ), 0 );
  regs.C  := ctFindFirstEntry;
  regs.B  := nAttrMask;
  regs.DE := Addr( szPattern );
  regs.IX := Addr( info );

  MSXBDOS( regs );

  FindFirst := ( regs.A = 0 );
end;

(**
  * Continue a search started by @see FindFirst.
  * @param info The same fileinfo block passed to FindFirst, holding
  * the search continuation context;
  * The function returns true on a match, false otherwise (including no
  * more matches).
  *)
function FindNext( var info : TFileInfoBlock ) : boolean;
var
      regs : TRegs;

begin
  FillChar( regs, sizeof( regs ), 0 );
  regs.C  := ctFindNextEntry;
  regs.IX := Addr( info );

  MSXBDOS( regs );

  FindNext := ( regs.A = 0 );
end;

(**
  * Extract the matched filename from a fileinfo block as a Pascal string.
  * @param info The fileinfo block previously filled by FindFirst or
  * FindNext;
  *)
function FindInfoName( var info : TFileInfoBlock ) : TFileName;
var
      strName : TFileName;
      nPos    : byte;

begin
  nPos    := 0;
  strName := '';

  while( ( nPos <= High( info.aName ) ) and ( info.aName[nPos] <> #0 ) )  do
  begin
    strName := strName + info.aName[nPos];
    nPos    := Succ( nPos );
  end;

  FindInfoName := strName;
end;

(**
  * Compare two packed date/time stamps and return true if the first one
  * is more recent than the second. Byte-pair comparison is used instead
  * of treating the packed words as integer, since TWord is a 16bit
  * signed type on this platform (see /system/types.pas) and would
  * mis-compare values with the high bit set.
  * @param info1 The fileinfo block to check if it's newer;
  * @param info2 The fileinfo block to compare against;
  *)
function TimeStampNewer( var info1, info2 : TFileInfoBlock ) : boolean;
begin
  if( info1.aDate[1] <> info2.aDate[1] )  then
    TimeStampNewer := ( info1.aDate[1] > info2.aDate[1] )
  else if( info1.aDate[0] <> info2.aDate[0] )  then
    TimeStampNewer := ( info1.aDate[0] > info2.aDate[0] )
  else if( info1.aTime[1] <> info2.aTime[1] )  then
    TimeStampNewer := ( info1.aTime[1] > info2.aTime[1] )
  else
    TimeStampNewer := ( info1.aTime[0] > info2.aTime[0] );
end;
