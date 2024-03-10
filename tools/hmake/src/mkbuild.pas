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
  * Makefile build handle used by parsing and build routines.
  *)
 type TMakeHandle = record
  bOpen       : boolean;   { Make file is open }
 End;



(**
 * Open a make file for processing.
 * @param strFileName The make file name to open;
 * The function will return a @see TMakeHandle of the opened makefile
 * that will be used to perform all make operations;
 *)
function MkOpen( strFileName : TFileName ) : TMakeHandle;
var 
         handle : TMakeHandle;
begin
  handle.bOpen := false;
  { TODO: FINISH HIM !!! }
  MkOpen := handle;
end;

(**
 * Close a previously open make file.
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkClose( handle : TMakeHandle ) : boolean;
var
      bRet   : boolean;
begin
  if( handle.bOpen )  then
  begin
    { TODO: FINISH HIM !!! }
    handle.bOpen := false;
  end;

  MkClose := bRet;
end;

(**
 * Parse and build an open make file. This function will parse the makefile, creating
 * all needed infrastructure needed by making a Pascal project;
 * @param handle The handle of a makefile previously opened by @see MkOpen;
 * The function will return true if the operation was successfull otherwise false;
 *)
function MkBuild( handle : TMakeHandle ) : boolean;
var
      bRet   : boolean;
begin
  bRet := handle.bOpen;

  if( bRet )  then
  begin
    { TODO: FINISH HIM !!! }

  end;

  MkBuild := bRet;
end;
