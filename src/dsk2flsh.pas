(**<dsk2flsh.pas>
  * This utility tool was created to work in conjunction with the
  * Vincent Van Dam's DSK2ROM tool modified by PopolonY2k.
  *
  * Copyright (c) since 1995 by PopolonY2k.
  *)

(**
  *
  * $Id: dsk2flsh.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/dsk2flsh.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxbios.pas;
 * - mflshrom.pas;
 * - msxdos.pas;
 * - msxdos2.pas;
 * - dos2file.pas;
 *)

{$i types.pas}
{$i msxbios.pas}
{$i mflshrom.pas}
{$i msxdos.pas}
{$i msxdos2.pas}
{$i dos2file.pas}


(*
 * Module routines.
 *)

(**
  * Print the help options for the Pop! Dsk2Flash writer
  * application.
  * @param bShowExtended Show the extended help;
  *)
Procedure ShowHelp( bShowExtended : Boolean );
Begin
  If( bShowExtended )  Then
  Begin
    Write( 'Usage: ' );
    WriteLn( 'dsk2flsh [-h][-e][-r][-f <file_name>]' );
    WriteLn;
    WriteLn( '-h Show this help screen;' );
    WriteLn( '-e Erase the MegaFlash ROM card content;' );
    WriteLn( '-r Reset the MSX computer when the loading process finishes' );
    Write( '-f <file_name> Specify the ROM file to write to the' );
    WriteLn( ' Mega Flash ROM card;' );
  End
  Else
  Begin
    WriteLn( 'Pop! Dsk2Flash writer for MegaFlashROM' );
    WriteLn( 'CopyLeft (c) since 1995 by PopolonY2k.' );
    Write( 'Check newer versions of this software at ' );
    WriteLn( 'http://www.popolony2k.com.br' );
    WriteLn;
  End;
End;

(**
  * Flash the ROM data to the MegaFlashROM.
  * @param handle The open handle with the MegaFlashROM card;
  * @param nFileHandle The open file handle;
  *)
Function WriteROMToFlash( handle : TFlashHandle;
                          nFileHandle : Byte ) : Boolean;
Var
       nDataRead    : Integer;
       nFlashPos    : Integer;
       nBufferSize  : Integer;
       nBankSel     : Byte;
       nBankId      : Byte;
       nCursor      : Byte;
       status       : TFlashStatus;
       aDiskBuffer  : Array[0..127] Of Byte;
       aCursor      : Array[0..3] Of Char;

Begin
  nBufferSize := SizeOf( aDiskBuffer );
  nBankSel    := 0;
  nBankId     := 0;
  nFlashPos   := 0;
  nCursor     := 0;
  aCursor[0]  := '|';
  aCursor[1]  := '/';
  aCursor[2]  := '-';
  aCursor[3]  := '\';

  Write( 'Loading ( )' );
  Write( #27, 'D' );

  Repeat
    (*
     * Progress indicator.
     *)
    Write( #27, 'D' );
    Write( aCursor[nCursor] );

    If( nCursor = 3 )  Then
      nCursor := 0
    Else
      nCursor := nCursor + 1;

    nDataRead := FileBlockRead( nFileHandle, aDiskBuffer, nBufferSize );

    If( nDataRead > 0 )  Then
      status := WriteToMFR( handle,
                            aDiskBuffer,
                            nFlashPos,
                            nDataRead,
                            nBankSel,
                            nBankId );

    If( status <> FlashSuccess )  Then
    Begin
      nDataRead := 0;

      Case status Of
        FlashPollingError         : WriteLn( 'Memory polling error.' );
        FlashWriteError           : WriteLn( 'Memory write error.' );
        FlashInvalidBankSelection : WriteLn( 'Invalid bank selection.' );
      Else
        WriteLn( 'MegaFlashROM error.' );
      End;
    End
    Else
    Begin
      If( ( nFlashPos >= ctMegaFlashROMBankSize ) And ( nDataRead > 0 ) ) Then
      Begin
        If( nBankSel >= ctMaxMegaFlashROMBankSel )  Then
          nBankSel := 2
        Else
          nBankSel := nBankSel + 1;

        nFlashPos := 0;
        nBankId   := nBankId + 1;
      End;
    End;
  Until( nDataRead <> nBufferSize );

  Write( #27, 'D' );
  Write( '*' );
  Write( #27, 'C' );
  WriteLn;

  WriteROMToFlash := ( status = FlashSuccess );
End;


(* Main program variables *)
Var
     nFileHandle : Byte;
     strROMFile  : TFileName;
     handle      : TFlashHandle;
     nPriSlot    : TSlotNumber;
     nSecSlot    : TSlotNumber;

(* Main program *)
Begin
  ShowHelp( False );

  If( ParamCount >= 1 )  Then
  Begin
    strROMFile  := ParamStr( 1 );
    nFileHandle := FileOpen( strROMFile, 'r' );

    If( nFileHandle <> ctInvalidFileHandle )  Then
    Begin
      If( FindMFR( handle ) )  Then
      Begin
        SplitSlotNumber( handle.nSlot, nPriSlot, nSecSlot );
        WriteLn( 'MegaFlashROM card found at slot ', nPriSlot, '-', nSecSlot );
        WriteLn( 'Erasing card data.' );

        (* Erase the card before writing data *)
        If( EraseMFR( handle ) = FlashSuccess )  Then
        Begin
          WriteLn( 'MegaFlashROM data successfully erased.' );
          WriteLn( 'Reading ROM file content into the MegaFlashROM card.' );
          WriteLn;

          (* Flash the DISK BIOS into the Mapper flash memory *)
          If( WriteROMToFlash( handle, nFileHandle ) )  Then
          Begin
            WriteLn( 'ROM file sucessfully loaded into the MegaFlashROM card.' );

            (* Initialize MegaFlashROM pages and restart *)
            If( SelectInitialMFRPages( handle, True ) = FlashSuccess )  Then
              WriteLn( 'Starting pages successfully initialized' );
          End
          Else
            WriteLn( 'Error reading the ROM file into the MegaFlashROM card.' );
        End
        Else
          WriteLn( 'Error to erase the MegaFlashROM card.' );
      End
      Else
        WriteLn( 'Mega Flash ROM not found.' );

      If( Not FileClose( nFileHandle ) )  Then
        WriteLn( 'Error to close the specified ROM file' );
    End
    Else
      WriteLn( 'Error to open the specified ROM file' );
  End
  Else
    ShowHelp( True );
End.
