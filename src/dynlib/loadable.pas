(*<loadable.pas>
 * Loadable module management routines.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 *)


(**
  * Constants and definitions.
  *)
const
        ctLibraryMajorVrs = 0;          { Library major version  }
        ctLibraryMinorVrs = 0;          { Library minor version  }
        ctLibMaxSignature = 6;          { Maximum signature size }
        ctLibSignature    = 'POPLIB';   { File signature         }
        ctDiskBlockSize   = 127;        { Disk block size        }

(**
  * Loadable module return type.
  *)
type TLibraryResult = ( LibSuccess,
                        LibIOError,
                        LibInvalidFormat,
                        LibIncompatibleVersion );

(**
  * The loadable module file open mode.
  *)
type TLibraryOpenMode = ( LibraryModeOpen,
                          LibraryModeCreate );
(**
  * Module entry name definition.
  *)
type TLibraryEntryName = string[50];    { Entry name maximum string }

(**
  * Loadable module file header specification (128 bytes record).
  *)
type TLibraryHdr = record
  aSignature  : array[0..ctLibMaxSignature] of char;   { Signature  7 bytes   }
  nMinorVrs   : byte;                   { Module file minor version 1 byte    }
  nMajorVrs   : byte;                   { Module file major version 1 byte    }
  nNumEntries : byte;                   { Routines entries on file  1 byte    }
  aFiller     : array[0..117] of byte;  { Filler                    118 bytes }
end;

(**
  * Loadable module file entry specification (128 bytes record).
  *)
type TLibraryEntry = record
  strEntryName  : TLibraryEntryName;    { Entry name - Routine name 51 bytes }
  nEntryAddress : integer;              { Entry default address     2  bytes }
  nEntrySize    : integer;              { Entry size - Routine size 2  bytes }
  aFiller       : array[0..72] of byte; { Filler                    73 bytes }
end;

(**
  *  The loadable module structure handle.
  *)
type TLibraryHandle = record
  hdr           : TLibraryHdr;          { File module header        }
  fpFile        : file;                 { File descriptor           }
end;


(* Internal helper functions *)

(**
  * Check the file module format.
  * @param handle The @see TLibraryHandle returned handle to
  * perform future loadable module I/O operations;
  *)
function __CheckLibraryFormat( handle : TLibraryHandle ) : TLibraryResult;
var
     ret          : TLibraryResult;
     strSignature : string[ctLibMaxSignature];
     hdr          : TLibraryHdr;

begin
  {$i-}
  Seek( handle.fpFile, 0 );
  BlockRead( handle.fpFile, hdr, 1 );
  {$i+}

  if( IOResult = 0 )  then
  begin
    (* Check library file signature *)
    strSignature[0] := char( ctLibMaxSignature );
    Move( hdr.aSignature, strSignature[1], ctLibMaxSignature );

    if( strSignature = ctLibSignature )  then
    begin
      (*
       * The major version is mandatory to be the same between
       * file module and the used library.
       *)
      if( hdr.nMajorVrs = ctLibraryMajorVrs )  then
      begin
        Move( hdr, handle.hdr, sizeof( hdr ) );
        ret := LibSuccess;
      end
      else
        ret := LibIncompatibleVersion;
    end
    else
      ret := LibInvalidFormat;
  end
  else
    ret := LibIOError;

  __CheckLibraryFormat := ret;
end;

(**
  * Open a loadable module file for reading and writing.
  * @param strFileName The loadable file to open;
  * @param mode The @see TLibraryOpenMode file opening mode;
  * @param handle The @see TLibraryHandle returned handle to
  * perform future loadable module I/O operations;
  *)
function OpenLibrary( strFileName : TFileName;
                      mode : TLibraryOpenMode;
                      var handle : TLibraryHandle ) : TLibraryResult;

  (**
    * Write the file module format to file.
    *)
  function __WriteLibraryFormat : TLibraryResult;
  var
       ret          : TLibraryResult;
       strSignature : string[ctLibMaxSignature];

  begin
    strSignature := ctLibSignature;

    FillChar( handle.hdr, sizeof( handle.hdr ), 0 );

    with handle.hdr do
    begin
      Move( strSignature[1], aSignature, ctLibMaxSignature );
      nNumEntries := 0;
      nMinorVrs   := ctLibraryMinorVrs;
      nMajorVrs   := ctLibraryMajorVrs;
    end;

    {$i-}
    Seek( handle.fpFile, 0 );
    BlockWrite( handle.fpFile, handle.hdr, 1 );
    {$i+}

    if( IOResult <> 0 )  then
      ret := LibIOError
    else
      ret := LibSuccess;

    __WriteLibraryFormat := ret;
  end;


(*
 * Main procedure entry point.
 *)
var
       res   : TLibraryResult;

begin
  {$i-}
  Assign( handle.fpFile, strFileName );

  if( mode = LibraryModeOpen )  then
    Reset( handle.fpFile )
  else
    Rewrite( handle.fpFile );
  {$i+}

  if( IOResult <> 0 )  then
    res := LibIOError
  else
  begin
    if( mode = LibraryModeOpen )  then
      res := __CheckLibraryFormat( handle )
    else
      res := __WriteLibraryFormat;
  end;

  OpenLibrary := res;
end;

(**
  * Close the previosly opened handle by @see OpenLibrary function;
  * @param handle The library handle to close;
  *)
function CloseLibrary( var handle : TLibraryHandle ) : TLibraryResult;
var
      res : TLibraryResult;

begin
  {$i-}
  Close( handle.fpFile );
  {$i+}

  if( IOResult <> 0 )  then
    res := LibIOError
  else
    res := LibSuccess;

  CloseLibrary := res;
end;

(**
  * Write a routine to the end of module file.
  * @param handle The opened library handle to use on writing operation;
  * @param entry The library entry structure containing information
  * about entry to save in library;
  *)
function WriteLibraryEntry( var handle : TLibraryHandle;
                            var entry  : TLibraryEntry ) : TLibraryResult;
var
       ret         : TLibraryResult;
       nBlockCount : integer;

begin
  {$i-}
  with handle do
  begin
    hdr.nNumEntries := Succ( hdr.nNumEntries );

    (* Write the header *)
    Seek( fpFile, 0 );
    BlockWrite( fpFile, hdr, 1 );

    if( IOResult = 0 )  then
    begin
      (* Write the routine at the end of file *)
      Seek( fpFile, FileSize( fpFile ) );

      (* Write the entry *)
      BlockWrite( fpFile, entry, 1 );

      if( IOResult = 0 )  then
      begin
        nBlockCount := Round( entry.nEntrySize / sizeof( entry ) );

        if( nBlockCount = 0 )  then
          nBlockCount := 1;

        (* Write the routine content *)
        BlockWrite( fpFile, Mem[entry.nEntryAddress], nBlockCount );

        if( IOResult = 0 )  then
          ret := LibSuccess
        else
          ret := LibIOError;
      end
      else
        ret := LibIOError;
    end
    else
      ret := LibIOError;
  end;
  {$i+}

  WriteLibraryEntry := ret;
end;

(**
  * Read a routine entry on module file.
  * @param handle The opened library handle to use on reading operation;
  * @param entry The entry to load;
  * @param bUseDefaultAddress When this flag is true, the address stored
  * on file will be used to load the routine on memory, if false, the
  * @see TLibraryEntry.nEntryAddress will be used instead;
  *)
function LoadLibraryEntry( var handle : TLibraryHandle;
                           var entry : TLibraryEntry;
                           bUseDefaultAddress : boolean ) : TLibraryResult;
var
      nRes,
      nMaxBlocks,
      nBlockCount,
      nEntryAddress : integer;
      ret           : TLibraryResult;
      fileEntry     : TLibraryEntry;
      aDiskBlock    : array[0..ctDiskBlockSize] of byte;

begin
  with handle do
  begin
    ret := __CheckLibraryFormat( handle );

    if( ret = LibSuccess )  then
    begin
      {$i-}
      Seek( fpFile, 1 );

      (* Searching by the right entry *)
      repeat
        if( IOResult = 0 )  then
        begin
          BlockRead( fpFile, fileEntry, 1, nRes );

          if( ( IOResult = 0 ) and ( nRes = 1 ) )  then
          begin
            if( entry.strEntryName = fileEntry.strEntryName )  then
            begin
              ret := LibSuccess;

              if( bUseDefaultAddress )  then
                nEntryAddress := fileEntry.nEntryAddress
              else
                nEntryAddress := entry.nEntryAddress;

              nMaxBlocks := Round( fileEntry.nEntrySize /
                                   sizeof( aDiskBlock ) );

              if( nMaxBlocks = 0 )  then
                nMaxBlocks := 1;

              nBlockCount := 0;

              (* Load the routine to the specified memory address *)
              while( nBlockCount < nMaxBlocks ) do
              begin
                BlockRead( fpFile, aDiskBlock, 1, nRes );

                if( ( IOResult = 0 ) and ( nRes = 1 ) ) then
                begin
                  Move( aDiskBlock, Mem[nEntryAddress], sizeof( aDiskBlock ) );
                  nBlockCount := Succ( nBlockCount );
                  nEntryAddress := nEntryAddress + sizeof( aDiskBlock );
                end
                else
                begin
                  ret := LibIOError;
                  nBlockCount := nMaxBlocks;
                end
              end;

              nRes := 0;
            end
            else  { Move the file pointer to the next library entry }
            begin
              nMaxBlocks := Round( fileEntry.nEntrySize /
                                   sizeof( aDiskBlock ) );

              if( nMaxBlocks = 0 )  then
                nMaxBlocks := 1;

              Seek( fpFile, FilePos( fpFile ) + nMaxBlocks );
            end;
          end
          else
          begin
            nRes := 0;
            ret  := LibIOError;
          end;
        end
        else
        begin
          nRes := 0;
          ret  := LibIOError;
        end;
      until( nRes < 1 );
      {$i+}
    end;
  end;

  LoadLibraryEntry := ret;
end;
