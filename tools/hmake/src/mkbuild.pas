(*<mkbuild.pas>
 * Hinotori make file parse and build routines.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 *)


(**
  * Variable data types.
  *)
type TVariableName  = string[10];
     TVariableValue = TString;

(**
  * Variable data structure.
  *)
type TMakeVariablePair = record
  strKey       : TVariableName;
  strValue     : TVariableValue;
end;

(**
  * Makefile build handle used by parsing and build routines.
  *)
 type TMakeHandle = record
   bIsOpen     : boolean;        { Make file is open }
   hFile       : text;           { Make file handle  }
   mkVars      : TLinkedList;    { Make variables    }
 end;


(**
 * Open a make file for processing.
 * @param strFileName The make file name to open;
 * @param handle A @see TMakeHandle of the opened makefile
 * that will be used to perform all make operations;
 * The function will return true for success operation 
 * otherwise false;
 *)
function MkOpen( strFileName : TFileName; var handle : TMakeHandle ) : boolean;
begin
  {$i-}
  Assign( handle.hFile, strFileName );
  Reset( handle.hFile );
  {$i+}

  handle.bIsOpen := ( IOResult = 0 );

  if( handle.bIsOpen )  then
    CreateLinkedList( handle.mkVars, sizeof( TMakeVariablePair ) );

  MkOpen := ( handle.bIsOpen );
end;

(**
 * Close a previously open make file.
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkClose( var handle : TMakeHandle ) : boolean;
begin
  if( handle.bIsOpen )  then
  begin
    DestroyLinkedList( handle.mkVars );
    {$i-}
    Close( handle.hFile );
    {$i+}
    handle.bIsOpen := false;
  end;

  MkClose := ( IOResult = 0 );
end;

(**
 * Parse and build an open make file. This function will parse the makefile, creating
 * all needed infrastructure needed by making a Pascal project;
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkBuild( var handle : TMakeHandle ) : boolean;
var
      bRet    : boolean;
      strLine : TString;

begin
  bRet := handle.bIsOpen;

  if( bRet )  then
  begin
    while( not eof( handle.hFile ) ) do
    begin
        ReadLn( handle.hFile, strLine );

        // TODO: Parse it
    end;
  end;

  MkBuild := bRet;
end;
