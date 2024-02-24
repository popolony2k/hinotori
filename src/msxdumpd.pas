(*<msxdumpd.pas>
 * MSXDD - The MSX Disk doctor tools for disk management.
 * This module supports:
 *  1) Low level sector disk operations;
 *  2) Low level sector IDE (Sunrise-like) operations;
 *
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

 Program MSXDUMP_DISK;

(**
  *
  * $Id: msxdumpd.pas 134 2020-09-11 02:44:57Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-09-10 23:44:57 -0300 (Thu, 10 Sep 2020) $
  * $Revision: 134 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/msxdumpd.pas $
  *)

{$v-,c-,u-,a+,r-}

{$i types.pas}
{$i systypes.pas}
{$i sleep.pas}
{$i suntypes.pas}
{$i math.pas}
{$i math16.pas}
{$i bigint.pas}
{$i dvram.pas}
{$i txthndlr.pas}
{$i msxbios.pas}
{$i conio.pas}
{$i helpchar.pas}
{$i helpcnv.pas}
{$i twindow.pas}
{$i ttext.pas}
{$i memory.pas}
{$i msxdos.pas}
{$i dpb.pas}
{$i msxdos2.pas}
{$i mddtypes.pas}
{$i iohandle.pas}
{$i funcptr.pas}
{$i dos2err.pas}
{$i doscodes.pas}
{$i uidump.pas}
{$i dosio.pas}
{$i bitwise.pas}
{$i sltsrch.pas}
{$i sunwrksp.pas}
{$i sunio.pas}
{$i drvdisk.pas}
{$i envvars.pas}
{$i dumphelp.pas}


(**
  * Execute the main program loop according parameters
  * received by comand line.
  * @param parms The received command line parameters;
  *)
Procedure Run( Var parms : TCmdLineParms );
Var
        scrStat,
        oldScrStat      : TScreenStatus;
        scrHandle       : TTextHandle;
        device          : TDeviceCtrl;
        version         : TMSXDOSVersion;
        bigDevicePtr    : TBigInt;
        bExecDump       : Boolean;

Begin
  GetMSXDOSVersion( version );
  bExecDump := False;

  With parms Do
  Begin
    If( bFile )  Then  { File dump - Call the external application module }
      CallExec( 'MSXDUMP.COM' )
    Else               { Sector Dump }
      With device Do
      Begin            { Setup the driver for direct sector operations }
        nOpenDevFnAddr       := Addr( OpenSectorDev );
        nCloseDevFnAddr      := Addr( CloseSectorDev );
        nSeekDevFnAddr       := Addr( SeekSectorDev );
        nGetDevParmsFnAddr   := Addr( GetSectorDevParms );
        nReadDevFnAddr       := Addr( ReadSectorDev );
        nWriteDevFnAddr      := Addr( WriteSectorDev );
        nErrorHandlingFnAddr := Addr( ErrorHandlingSectorDev );
        nDeviceNumber        := nDriveNumber;
        FileCtrl.strFileName := strDriveLetter;
        OSEnv.nOSVersion     := version.nKernelMajor;
        IDECtrl.bAbsoluteStartSector := bAbsoluteStartSector;

        With Buffer Do
        Begin
          nMemoryPtr := 0;

          With bigDevicePtr Do
          Begin
            nSize  := SizeOf( nDevicePtr );
            pValue := Ptr( Addr( nDevicePtr ) );
          End;

          If( strSectorNumber <> '' )  Then
          Begin
            If( StrToBigInt( bigDevicePtr, strSectorNumber ) = Success )  Then
              bExecDump := True
            Else
              WriteLn( 'Invalid sector number' );
          End
          Else
            If( ResetBigInt( bigDevicePtr ) = Success )  Then
              bExecDump := True
            Else
              WriteLn( 'Internal error' );
        End;
      End;
  End;

  If( bExecDump )  Then
  Begin
    SaveAppTextMode( scrHandle, scrStat, oldScrStat );
    Dump( device );
    RestoreAppTextMode( scrHandle, scrStat, oldScrStat );

    If( version.nKernelMajor >= 2 )  Then      { Clear APPEND variable }
      If( SetEnv( ctAPPENDEnvVar, #0 ) )  Then;

    _ClrScr;
    WriteLn( 'Thanks for using MSX Disk Doctor Suite.' );
  End;
End;

(* Main block variables *)
Var
       parms  : TCmdLineParms;

Begin        { Main Block }
  ParseCmdLine( parms );

  If( Not parms.bHelp And Not HasInvalidParms( parms ) ) Then
    Run( parms )
  Else
    CallExec( 'MSXDUMPH.COM' );
End.
