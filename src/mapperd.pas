(*<mapperd.pas>
 * Direct memory mapper management implementation.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: mapperd.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/mapperd.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - maprdefs.pas;
 *)

(**
  * Ports/segments type definition.
  *)
Type TPortsSegments = Array[0..ctMapperSegsSize] Of Byte;
     PPortsSegments = ^TPortsSegments;

(*
 * Internal module data.
 *)
Var
         __nMapperSegmentsEx : Integer;          { Max. mapper segs }
         __aMapperPortSegsEx : TPortsSegments;   { Port segments    }


(**
  * Get the full capacity for all memory mappers installed in the machine.
  * The result is given in kilobytes;
  *)
Function GetMapperCapacity : Integer;
Var
       nMapperSize   : Integer;

Begin
  nMapperSize := ( ( 256 - Port[ctMapperPortPage3] ) *
                   ( ctMapperPageSize Div 1024 ) );

  GetMapperCapacity := nMapperSize;
End;

(**
  * Return the maximum number of mapper segments.
  *)
Function GetMaxMapperSegments : Integer;
Begin
  GetMaxMapperSegments := ( GetMapperCapacity Div 16 );
End;

(**
  * Allocate a memory mapper segment.
  * @param nMaperSegmentId The mapper id that will be allocated;
  * @param nMapperPagePort The page port corresponding to the main memory
  * page that will allocated on mapper;
  *)
Function AllocMapperSegmentEx( nMapperSegmentId,
                               nMapperPagePort : Byte ) : Boolean;
Begin
  If( nMapperPagePort In [ctMapperPortPage0..ctMapperPortPage3] )  Then
  Begin
    If( __aMapperPortSegsEx[nMapperSegmentId] = ctFreeSegment )  Then
    Begin
      If( nMapperSegmentId < __nMapperSegmentsEx )  Then
      Begin
        __aMapperPortSegsEx[nMapperSegmentId] := nMapperPagePort;
        AllocMapperSegmentEx := True;
      End
      Else
        AllocMapperSegmentEx := False;
    End
    Else
      AllocMapperSegmentEx := False;
  End
  Else
    AllocMapperSegmentEx := False;
End;

(**
  * Release an allocated memory mapper segment.
  * @param nMaperSegmentId The mapper id that will be allocated;
  *)
Function FreeMapperSegmentEx( nMapperSegmentId : Byte ) : Boolean;
Begin
  If( __aMapperPortSegsEx[nMapperSegmentId] <> ctReservedSegment )  Then
    If( nMapperSegmentId < __nMapperSegmentsEx )  Then
    Begin
      __aMapperPortSegsEx[nMapperSegmentId] := ctFreeSegment;
      FreeMapperSegmentEx := True;
    End
    Else
      FreeMapperSegmentEx := False
  Else
    FreeMapperSegmentEx := False;
End;

(**
  * Activate a mapper segment to the main memory based on mapper id;
  * @param nMapperId The mapper id that will be activated;
  *)
Function ActivateMapperSegmentEx( nMapperSegmentId : Byte ) : Boolean;
Begin
  If( nMapperSegmentId < __nMapperSegmentsEx )  Then
  Begin
    If( __aMapperPortSegsEx[nMapperSegmentId] <> ctFreeSegment )  Then
    Begin
      If( __aMapperPortSegsEx[nMapperSegmentId] <> ctReservedSegment )  Then
      Begin
        Port[__aMapperPortSegsEx[nMapperSegmentId]] := nMapperSegmentId;
        ActivateMapperSegmentEx := True;
        Exit;
      End
      Else
      Begin
        ActivateMapperSegmentEx := False;
        Exit;
      End;
    End
    Else
    Begin
      ActivateMapperSegmentEx := False;
      Exit;
    End;
  End
  Else
    ActivateMapperSegmentEx := False;
End;

(**
  * Mark/unmark a segment as reserved. After a segment is marked as reserved
  * it can't be allocated or released;
  * @param bReserved The reserved status for a segment id;
  * @param nMapperSegmentId The segment id that will be marked/unmarked
  * as reserved;
  *)
Procedure SetReservedMapperSegmentEx( bReserved : Boolean;
                                      nMapperSegmentId : Byte );
Begin
  If( bReserved )  Then
    __aMapperPortSegsEx[nMapperSegmentId] := ctReservedSegment
  Else
    __aMapperPortSegsEx[nMapperSegmentId] := ctFreeSegment;
End;

(**
  * Initialize the mapper engine.
  * @param pPortsSegs Pointer to an array containing all ports/segments
  * which will initialize the engine. If a Nil pointer is passed to this
  * function, the internal data will be initialized with zeros;
  *)
Procedure InitMapperEx( pPortsSegs : PPortsSegments );
Begin
  __nMapperSegmentsEx := GetMaxMapperSegments;

  If( pPortsSegs = Nil ) Then
    FillChar( __aMapperPortSegsEx,
              SizeOf( __aMapperPortSegsEx ),
              ctFreeSegment )
  Else
    Move( pPortsSegs^, __aMapperPortSegsEx, SizeOf( __aMapperPortSegsEx ) );
End;
