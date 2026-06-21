(*<mapperd.pas>
 * Direct memory mapper management implementation.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /mapper/maprdefs.pas;
 *)

(**
  * Ports/segments type definition.
  *)
type TPortsSegments = array[0..ctMapperSegsSize] of byte;
     PPortsSegments = ^TPortsSegments;

(*
 * Internal module data.
 *)
var
         __nMapperSegmentsEx : integer;          { Max. mapper segs }
         __aMapperPortSegsEx : TPortsSegments;   { Port segments    }


(**
  * Get the full capacity for all memory mappers installed in the machine.
  * The result is given in kilobytes;
  *)
function GetMapperCapacity : integer;
var
       nMapperSize   : integer;

begin
  nMapperSize := ( ( 256 - Port[ctMapperPortPage3] ) *
                   ( ctMapperPageSize div 1024 ) );

  GetMapperCapacity := nMapperSize;
end;

(**
  * Return the maximum number of mapper segments.
  *)
function GetMaxMapperSegments : integer;
begin
  GetMaxMapperSegments := ( GetMapperCapacity div 16 );
end;

(**
  * Allocate a memory mapper segment.
  * @param nMaperSegmentId The mapper id that will be allocated;
  * @param nMapperPagePort The page port corresponding to the main memory
  * page that will allocated on mapper;
  *)
function AllocMapperSegmentEx( nMapperSegmentId,
                               nMapperPagePort : byte ) : boolean;
begin
  if( nMapperPagePort in [ctMapperPortPage0..ctMapperPortPage3] )  then
  begin
    if( __aMapperPortSegsEx[nMapperSegmentId] = ctFreeSegment )  then
    begin
      if( nMapperSegmentId < __nMapperSegmentsEx )  then
      begin
        __aMapperPortSegsEx[nMapperSegmentId] := nMapperPagePort;
        AllocMapperSegmentEx := true;
      end
      else
        AllocMapperSegmentEx := false;
    end
    else
      AllocMapperSegmentEx := false;
  end
  else
    AllocMapperSegmentEx := false;
end;

(**
  * Release an allocated memory mapper segment.
  * @param nMaperSegmentId The mapper id that will be allocated;
  *)
function FreeMapperSegmentEx( nMapperSegmentId : byte ) : boolean;
begin
  if( __aMapperPortSegsEx[nMapperSegmentId] <> ctReservedSegment )  then
    if( nMapperSegmentId < __nMapperSegmentsEx )  then
    begin
      __aMapperPortSegsEx[nMapperSegmentId] := ctFreeSegment;
      FreeMapperSegmentEx := true;
    end
    else
      FreeMapperSegmentEx := false
  else
    FreeMapperSegmentEx := false;
end;

(**
  * Activate a mapper segment to the main memory based on mapper id;
  * @param nMapperId The mapper id that will be activated;
  *)
function ActivateMapperSegmentEx( nMapperSegmentId : byte ) : boolean;
begin
  if( nMapperSegmentId < __nMapperSegmentsEx )  then
  begin
    if( __aMapperPortSegsEx[nMapperSegmentId] <> ctFreeSegment )  then
    begin
      if( __aMapperPortSegsEx[nMapperSegmentId] <> ctReservedSegment )  then
      begin
        Port[__aMapperPortSegsEx[nMapperSegmentId]] := nMapperSegmentId;
        ActivateMapperSegmentEx := true;
        Exit;
      end
      else
      begin
        ActivateMapperSegmentEx := false;
        Exit;
      end;
    end
    else
    begin
      ActivateMapperSegmentEx := false;
      Exit;
    end;
  end
  else
    ActivateMapperSegmentEx := false;
end;

(**
  * Mark/unmark a segment as reserved. After a segment is marked as reserved
  * it can't be allocated or released;
  * @param bReserved The reserved status for a segment id;
  * @param nMapperSegmentId The segment id that will be marked/unmarked
  * as reserved;
  *)
procedure SetReservedMapperSegmentEx( bReserved : boolean;
                                      nMapperSegmentId : byte );
begin
  if( bReserved )  then
    __aMapperPortSegsEx[nMapperSegmentId] := ctReservedSegment
  else
    __aMapperPortSegsEx[nMapperSegmentId] := ctFreeSegment;
end;

(**
  * Initialize the mapper engine.
  * @param pPortsSegs Pointer to an array containing all ports/segments
  * which will initialize the engine. If a Nil pointer is passed to this
  * function, the internal data will be initialized with zeros;
  *)
procedure InitMapperEx( pPortsSegs : PPortsSegments );
begin
  __nMapperSegmentsEx := GetMaxMapperSegments;

  if( pPortsSegs = nil ) then
    FillChar( __aMapperPortSegsEx,
              sizeof( __aMapperPortSegsEx ),
              ctFreeSegment )
  else
    Move( pPortsSegs^, __aMapperPortSegsEx, sizeof( __aMapperPortSegsEx ) );
end;
