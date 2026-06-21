(*<memory.pas>
 * Memory management helper functions.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)
 
(*
 * This module depends on folowing include files (respect the order):
 * -
 *)

(**
  * Get the a integer value based on address passed by parameter.
  * @param nAddress The reference value pointing to the address position
  * to retrieve.
  * After execution of this function, the nAddress value points
  * to the next address position (Word step).
  *)
function GetInteger( var nAddress : integer ) : integer;
var
        nCount  : byte;
        nResult : integer;

begin
  nCount := sizeof( integer );
  Move( Mem[nAddress], Mem[Addr( nResult )], nCount );
  nAddress := nAddress + nCount;
  GetInteger := nResult;
end;

(**
  * Get the a byte memory position based on address passed
  * by parameter.
  * @param nAddress The reference value with address position
  * to retrieve.
  * After execution of this function, the nAddress value points
  * to the next address position (byte step).
  *)
function GetByte( var nAddress : integer ) : byte;
var
        nResult : byte;

begin
  nResult  := Mem[nAddress];
  nAddress := nAddress + 1;
  GetByte  := nResult;
end;

(**
  * When we're using a uni-dimensional vector and want to
  * manage it as a bi-dimensional vector, this function is
  * a helper to do this management.
  * The function retrieve a index of uni-dimensional array for
  * a given Column and Row.
  * @param nCol The column index;
  * @param nRow The row index;
  * @param nMaxCol the maximum number of columns of 'virtual'
  * bi-dimensional array;
  *)
function IndexArray( nCol, nRow, nMaxCol : byte) : integer;
begin
 IndexArray := ( ( nMaxCol * nCol ) + nRow );
end;
