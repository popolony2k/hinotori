(*<dos2file.pas>
 * Wrapper to MSXDOS2 file management calls.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/types.pas;
 * - /dos/msxdos.pas;
 * - /dos/msxdos2.pas;
 *)

const   ctInvalidFileHandle        = $FF; { Invalid file handle operation }
        ctInvalidOpenMode          = $FE; { Invalid file open mode }
        ctReadWriteError           = -1;  { Read/Write error operation }

        { @see FileSeek operation }
        ctSeekSet           : byte = 0;   { Relative Beginning of the file }
        ctSeekCur           : byte = 1;   { Relative current pointer position }
        ctSeekEnd           : byte = 2;   { Relative end of file }

(**
  * The file mode type for @see FileOpen function call;
  *)
type TFileMode = string[3];


(**
  * Open/Create a file with specified file name;
  * @param strFileName The name of file to open/create;
  * @param strMode The mode for FileOpen function.
  * The possible values are:
  * o r  Read only mode;
  * o w  Write only mode;
  * o rw Read/Write mode;
  * o w+ Write only, creating the file if not exist;
  * o rw+ Read/Write mode, creating the file if not exist;
  * The function return the file handle for opened file or ctInvalidFileHandle
  * value;
  *)
function FileOpen( var strFileName : TFileName; strMode : TFileMode ) : byte;
var
        nRet,
        nOpenMode  : byte;
        szFileName : array[0..ctMaxPath] of char;
        regs       : TRegs;

  (**
    * Internal function to check if the file mode is valid;
    * @param strMode The mode to check;
    *)
  function _IsValidMode( strMode : TFileMode ) : boolean;
  begin
    _IsValidMode := ( ( strMode = 'r' )  or
                      ( strMode = 'w' )  or
                      ( strMode = 'rw' ) or
                      ( strMode = 'w+' ) or
                      ( strMode = 'rw+' ) );
  end;

begin      { Main function entry point }
  nRet := ctInvalidOpenMode;

  if( _IsValidMode( strMode ) )  then
  begin
    nRet := Length( strFileName );

    if( ( nRet > 0 ) and ( Length( strMode ) > 0 ) )  then
    begin
      Move( strFileName[1], szFileName, nRet );
      FillChar( regs, sizeof( regs ), 0 );
      szFileName[nRet] := #0;
      nOpenMode := 0;

      { Check the open mode }
      if( strMode = 'r' )  then
        nOpenMode := 1
      else
        if( strMode[1] = 'w' )  then
          nOpenMode := 2;

      nRet := Length( strMode );

      if( strMode[nRet] = '+' )  then
        regs.C := ctCreateFileHandle
      else
        regs.C := ctOpenFileHandle;

      regs.A  := nOpenMode;
      regs.DE := Addr( szFileName );
      MSXBDOS( regs );

      if( regs.A = 0 )  then
        nRet := regs.B
      else
        nRet := ctInvalidFileHandle;
    end
    else
      nRet := ctInvalidFileHandle;
  end;

  FileOpen := nRet;
end;

(**
  * Close a file handle previously opened by the @see FileOpen function.
  * @param nFileHandle The file handle to close;
  * The function return False for error or True for success;
  *)
function FileClose( nFileHandle : byte ) : boolean;
var
        regs : TRegs;
        bRet : boolean;

begin
  regs.C := ctCloseFileHandle;
  regs.B := nFileHandle;
  MSXBDOS( regs );

  bRet := ( regs.A = 0 );

  FileClose := bRet;
end;

(**
  * Flush all data of file handle to disk;
  * @param nFileHandle The file handle to flush;
  * The function return False for error or True for success;
  *)
function FileFlush( nFileHandle : byte ) : boolean;
var
        regs : TRegs;
        bRet : boolean;

begin
  regs.C := ctEnsureFileHandle;
  regs.B := nFileHandle;
  MSXBDOS( regs );

  bRet := ( regs.A = 0 );

  FileFlush := bRet;
end;

(**
  * Duplicate a existing file handle.
  * @param nFileHandle The file handle to duplicate;
  * The function return the file handle for opened file or ctFileOpenError
  * value;
  *)
function FileDuplicate( nFileHandle : byte ) : byte;
var
        regs : TRegs;
        nRet : byte;

begin
  nRet   := ctInvalidFileHandle;
  regs.C := ctDuplicateFileHandle;
  regs.B := nFileHandle;
  MSXBDOS( regs );

  if( regs.A = 0 )  then
    nRet := regs.B;

  FileDuplicate := nRet;
end;

(**
  * Move the current pointer of opened file handle, to a new position.
  * @param nFileHandle The file handle to perform the position change;
  * @param nOffset The new offset of the file handle pointer;
  * @param nOrigin The position from where nOffset is added. This
  * parmeter is specified by one of following constants defined like
  * below:
  * ctSeekSet - Relative Beginning of the file;
  * ctSeekCur - Relative current pointer position;
  * ctSeekEnd - Relative end of file;
  * @param nNewPos The new file pointer position;
  *)
function FileSeek( nFileHandle : byte;
                   nOffset : integer;
                   nOrigin : byte;
                   var nNewPos : integer ) : boolean;
var
        regs    : TRegs;
        bRet    : boolean;

begin
  regs.C  := ctMoveFileHandlePointer;
  regs.A  := nOrigin;
  regs.B  := nFileHandle;
  regs.DE := 0;   { TODO: 32 bit seek operation ?????? }
  regs.HL := nOffset;
  MSXBDOS( regs );

  bRet := ( regs.A = 0 );

  if( bRet )  then
  begin
    nNewPos := regs.HL;
    { TODO: Addr DE here if has support for 32Bit seek operations }
  end;

  FileSeek := bRet;
end;

(**
  * Read a block of data from a file handle.
  * @param nFileHandle The file handle to perform a block read;
  * @param aBuffer The reference to the buffer to receive the block read;
  * @param nBytesToRead Number of bytes to read bythe function;
  * The function return the number of bytes really read;
  *)
function FileBlockRead( nFileHandle : byte;
                        var aBuffer;
                        nBytesToRead : integer ) : integer;
var
        regs : TRegs;
        nRet : integer;

begin
  nRet    := ctReadWriteError;
  regs.C  := ctReadFromFileHandle;
  regs.B  := nFileHandle;
  regs.DE := Addr( aBuffer );
  regs.HL := nBytesToRead;
  MSXBDOS( regs );

  if( regs.A = 0 )  then
    nRet := regs.HL;

  FileBlockRead := nRet;
end;

(**
  * Write a block of data to a file handle.
  * @param nFileHandle The file handle to perform a block write;
  * @param aBuffer The reference to the buffer containing the block to write;
  * @param nBytesToWrite Number of bytes to write by the function;
  * The function return the number of bytes really written;
  *)
function FileBlockWrite( nFileHandle : byte;
                         var aBuffer;
                         nBytesToWrite : integer ) : integer;
var
        regs : TRegs;
        nRet : integer;

begin
  nRet    := ctReadWriteError;
  regs.C  := ctWriteToFileHandle;
  regs.B  := nFileHandle;
  regs.DE := Addr( aBuffer );
  regs.HL := nBytesToWrite;
  MSXBDOS( regs );

  if( regs.A = 0 )  then
    nRet := regs.HL;

  FileBlockWrite := nRet;
end;
