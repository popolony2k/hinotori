(*<loadable.pas>
 * Loadable module management routines.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: loadable.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/loadable.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 *)


(**
  * Constants and definitions.
  *)
Const
        ctLibraryMajorVrs = 0;          { Library major version  }
        ctLibraryMinorVrs = 0;          { Library minor version  }
        ctLibMaxSignature = 6;          { Maximum signature size }
        ctLibSignature    = 'POPLIB';   { File signature         }
        ctDiskBlockSize   = 127;        { Disk block size        }

(**
  * Loadable module return type.
  *)
Type TLibraryResult = ( LibSuccess,
                        LibIOError,
                        LibInvalidFormat,
                        LibIncompatibleVersion );

(**
  * The loadable module file open mode.
  *)
Type TLibraryOpenMode = ( LibraryModeOpen,
                          LibraryModeCreate );
(**
  * Module entry name definition.
  *)
Type TLibraryEntryName = String[50];    { Entry name maximum string }

(**
  * Loadable module file header specification (128 bytes record).
  *)
Type TLibraryHdr = Record
  aSignature  : Array[0..ctLibMaxSignature] Of Char;   { Signature  7 bytes   }
  nMinorVrs   : Byte;                   { Module file minor version 1 byte    }
  nMajorVrs   : Byte;                   { Module file major version 1 byte    }
  nNumEntries : Byte;                   { Routines entries on file  1 byte    }
  aFiller     : Array[0..117] Of Byte;  { Filler                    118 bytes }
End;

(**
  * Loadable module file entry specification (128 bytes record).
  *)
Type TLibraryEntry = Record
  strEntryName  : TLibraryEntryName;    { Entry name - Routine name 51 bytes }
  nEntryAddress : Integer;              { Entry default address     2  bytes }
  nEntrySize    : Integer;              { Entry size - Routine size 2  bytes }
  aFiller       : Array[0..72] Of Byte; { Filler                    73 bytes }
End;

(**
  *  The loadable module structure handle.
  *)
Type TLibraryHandle = Record
  hdr           : TLibraryHdr;          { File module header        }
  fpFile        : File;                 { File descriptor           }
End;


(* Internal helper functions *)

(**
  * Check the file module format.
  * @param handle The @see TLibraryHandle returned handle to
  * perform future loadable module I/O operations;
  *)
Function __CheckLibraryFormat( handle : TLibraryHandle ) : TLibraryResult;
Var
     ret          : TLibraryResult;
     strSignature : String[ctLibMaxSignature];
     hdr          : TLibraryHdr;

Begin
  {$i-}
  Seek( handle.fpFile, 0 );
  BlockRead( handle.fpFile, hdr, 1 );
  {$i+}

  If( IOResult = 0 )  Then
  Begin
    (* Check library file signature *)
    strSignature[0] := Char( ctLibMaxSignature );
    Move( hdr.aSignature, strSignature[1], ctLibMaxSignature );

    If( strSignature = ctLibSignature )  Then
    Begin
      (*
       * The major version is mandatory to be the same between
       * file module and the used library.
       *)
      If( hdr.nMajorVrs = ctLibraryMajorVrs )  Then
      Begin
        Move( hdr, handle.hdr, SizeOf( hdr ) );
        ret := LibSuccess;
      End
      Else
        ret := LibIncompatibleVersion;
    End
    Else
      ret := LibInvalidFormat;
  End
  Else
    ret := LibIOError;

  __CheckLibraryFormat := ret;
End;

(**
  * Open a loadable module file for reading and writing.
  * @param strFileName The loadable file to open;
  * @param mode The @see TLibraryOpenMode file opening mode;
  * @param handle The @see TLibraryHandle returned handle to
  * perform future loadable module I/O operations;
  *)
Function OpenLibrary( strFileName : TFileName;
                      mode : TLibraryOpenMode;
                      Var handle : TLibraryHandle ) : TLibraryResult;

  (**
    * Write the file module format to file.
    *)
  Function __WriteLibraryFormat : TLibraryResult;
  Var
       ret          : TLibraryResult;
       strSignature : String[ctLibMaxSignature];

  Begin
    strSignature := ctLibSignature;

    FillChar( handle.hdr, SizeOf( handle.hdr ), 0 );

    With handle.hdr Do
    Begin
      Move( strSignature[1], aSignature, ctLibMaxSignature );
      nNumEntries := 0;
      nMinorVrs   := ctLibraryMinorVrs;
      nMajorVrs   := ctLibraryMajorVrs;
    End;

    {$i-}
    Seek( handle.fpFile, 0 );
    BlockWrite( handle.fpFile, handle.hdr, 1 );
    {$i+}

    If( IOResult <> 0 )  Then
      ret := LibIOError
    Else
      ret := LibSuccess;

    __WriteLibraryFormat := ret;
  End;


(*
 * Main procedure entry point.
 *)
Var
       res   : TLibraryResult;

Begin
  {$i-}
  Assign( handle.fpFile, strFileName );

  If( mode = LibraryModeOpen )  Then
    Reset( handle.fpFile )
  Else
    Rewrite( handle.fpFile );
  {$i+}

  If( IOResult <> 0 )  Then
    res := LibIOError
  Else
  Begin
    If( mode = LibraryModeOpen )  Then
      res := __CheckLibraryFormat( handle )
    Else
      res := __WriteLibraryFormat;
  End;

  OpenLibrary := res;
End;

(**
  * Close the previosly opened handle by @see OpenLibrary function;
  * @param handle The library handle to close;
  *)
Function CloseLibrary( Var handle : TLibraryHandle ) : TLibraryResult;
Var
      res : TLibraryResult;

Begin
  {$i-}
  Close( handle.fpFile );
  {$i+}

  If( IOResult <> 0 )  Then
    res := LibIOError
  Else
    res := LibSuccess;

  CloseLibrary := res;
End;

(**
  * Write a routine to the end of module file.
  * @param handle The opened library handle to use on writing operation;
  * @param entry The library entry structure containing information
  * about entry to save in library;
  *)
Function WriteLibraryEntry( Var handle : TLibraryHandle;
                            Var entry  : TLibraryEntry ) : TLibraryResult;
Var
       ret         : TLibraryResult;
       nBlockCount : Integer;

Begin
  {$i-}
  With handle Do
  Begin
    hdr.nNumEntries := Succ( hdr.nNumEntries );

    (* Write the header *)
    Seek( fpFile, 0 );
    BlockWrite( fpFile, hdr, 1 );

    If( IOResult = 0 )  Then
    Begin
      (* Write the routine at the end of file *)
      Seek( fpFile, FileSize( fpFile ) );

      (* Write the entry *)
      BlockWrite( fpFile, entry, 1 );

      If( IOResult = 0 )  Then
      Begin
        nBlockCount := Round( entry.nEntrySize / SizeOf( entry ) );

        If( nBlockCount = 0 )  Then
          nBlockCount := 1;

        (* Write the routine content *)
        BlockWrite( fpFile, Mem[entry.nEntryAddress], nBlockCount );

        If( IOResult = 0 )  Then
          ret := LibSuccess
        Else
          ret := LibIOError;
      End
      Else
        ret := LibIOError;
    End
    Else
      ret := LibIOError;
  End;
  {$i+}

  WriteLibraryEntry := ret;
End;

(**
  * Read a routine entry on module file.
  * @param handle The opened library handle to use on reading operation;
  * @param entry The entry to load;
  * @param bUseDefaultAddress When this flag is true, the address stored
  * on file will be used to load the routine on memory, if false, the
  * @see TLibraryEntry.nEntryAddress will be used instead;
  *)
Function LoadLibraryEntry( Var handle : TLibraryHandle;
                           Var entry : TLibraryEntry;
                           bUseDefaultAddress : Boolean ) : TLibraryResult;
Var
      nRes,
      nMaxBlocks,
      nBlockCount,
      nEntryAddress : Integer;
      ret           : TLibraryResult;
      fileEntry     : TLibraryEntry;
      aDiskBlock    : Array[0..ctDiskBlockSize] Of Byte;

Begin
  With handle Do
  Begin
    ret := __CheckLibraryFormat( handle );

    If( ret = LibSuccess )  Then
    Begin
      {$i-}
      Seek( fpFile, 1 );

      (* Searching by the right entry *)
      Repeat
        If( IOResult = 0 )  Then
        Begin
          BlockRead( fpFile, fileEntry, 1, nRes );

          If( ( IOResult = 0 ) And ( nRes = 1 ) )  Then
          Begin
            If( entry.strEntryName = fileEntry.strEntryName )  Then
            Begin
              ret := LibSuccess;

              If( bUseDefaultAddress )  Then
                nEntryAddress := fileEntry.nEntryAddress
              Else
                nEntryAddress := entry.nEntryAddress;

              nMaxBlocks := Round( fileEntry.nEntrySize /
                                   SizeOf( aDiskBlock ) );

              If( nMaxBlocks = 0 )  Then
                nMaxBlocks := 1;

              nBlockCount := 0;

              (* Load the routine to the specified memory address *)
              While( nBlockCount < nMaxBlocks ) Do
              Begin
                BlockRead( fpFile, aDiskBlock, 1, nRes );

                If( ( IOResult = 0 ) And ( nRes = 1 ) ) Then
                Begin
                  Move( aDiskBlock, Mem[nEntryAddress], SizeOf( aDiskBlock ) );
                  nBlockCount := Succ( nBlockCount );
                  nEntryAddress := nEntryAddress + SizeOf( aDiskBlock );
                End
                Else
                Begin
                  ret := LibIOError;
                  nBlockCount := nMaxBlocks;
                End
              End;

              nRes := 0;
            End
            Else  { Move the file pointer to the next library entry }
            Begin
              nMaxBlocks := Round( fileEntry.nEntrySize /
                                   SizeOf( aDiskBlock ) );

              If( nMaxBlocks = 0 )  Then
                nMaxBlocks := 1;

              Seek( fpFile, FilePos( fpFile ) + nMaxBlocks );
            End;
          End
          Else
          Begin
            nRes := 0;
            ret  := LibIOError;
          End;
        End
        Else
        Begin
          nRes := 0;
          ret  := LibIOError;
        End;
      Until( nRes < 1 );
      {$i+}
    End;
  End;

  LoadLibraryEntry := ret;
End;
