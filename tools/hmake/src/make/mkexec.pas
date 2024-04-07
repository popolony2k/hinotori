(*<mkexec.pas>
 * Hinotori makefile execution routines.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 * - /memory/pointer.pas;
 * - ./make/mktypes.pas;
 * - ./make/mkhelper.pas;
 *)

 (**
  * Execute a previously compiled makefile.
  * @param handle The makefile handle struct containing
  * all previously processed makefile data.
  * @param strTarget The target name that will be processed.
  * If empty, the default will be processed;
  *)
function MkExecute( var handle : TMakeHandle; strTarget : TString ) : boolean;
var
      bRet : boolean;

  (**
    * Find the identifier based on its name;
    * @param strName The identifier name to find;
    * The function return the pointer to the requested identifier or
    * nil if not found;
    *)
  function __FindIdentifier( var strName : TString ) : PIdentifierPair;
  var
        pItem  : PLinkedListItem;
        pPair  : PIdentifierPair;
        pPtr   : TPointer;
        bFound : boolean;
         
  begin
    bFound := false;
    pItem  := GetFirstLinkedListItem( handle.variableList );

    while( not bFound and ( pItem <> nil ) ) do
    begin
      pItem := GetNextLinkedListItem( handle.variableList );
      pPtr  := ToPointer( pItem^.pValue );
      Move( pPtr, pPair, sizeof( pPair ) );
      bFound := ( pPair^.strName = strName );
    end;

    if( not bFound )  then
      pPair := nil;

    __FindIdentifier := pPair;
  end;

(*
 * MkExecute main routine
 *)
begin
  bRet := true;

  MkExecute := bRet;
end;
