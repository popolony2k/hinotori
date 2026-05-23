(*<pointer.pas>
 * Pointer functions to make Turbo Pascal 3 more flexible with
 * modern pointer operations, present in newer Delphi releases.
 * FPC compatible (This module will be unified with MSX version
 * when a hinotori pre-processing is developed).
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas
 *)


(**
  * Increment the pointer address using the units passed by parameter.
  * @param pPointer The pointer that address will be incremented;
  * @param nIncrement The increment to skip to thew new address;
  *)
procedure IncPtr( var pPointer : TPointer; nIncrement : integer );
begin
  inc( pPointer, nIncrement );
 end;

(**
  * Helper function to make TP3 and 3.3f pointer operations more abstract
  * enabling multi-platform code exchangeable with newer pascal implementaion
  * like FPC compiler.
  * Convert an any type variable to pointer;
  * @param variable Variable to be converted to pointer;
  *)
function ToPointer( var variable ) : TPointer;
var
    pRet : TPointer;

begin
  pRet := Addr( variable );

  ToPointer := pRet;
end;
