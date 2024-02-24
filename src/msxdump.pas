(*<msxdump.pas>
 * MSXDD - The MSX Disk doctor tools for disk management.
 * This module supports:
 *  1) File operations;
 *
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

 Program MSXDUMP_FILE;

(**
  *
  * $Id: msxdump.pas 134 2020-09-11 02:44:57Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-09-10 23:44:57 -0300 (Thu, 10 Sep 2020) $
  * $Revision: 134 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/msxdump.pas $
  *)

{$v-,c-,u-,a+,r-}

{$i systypes.pas}
{$i sleep.pas}
{$i types.pas}
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
{$i msxdos2.pas}
{$i mddtypes.pas}
{$i iohandle.pas}
{$i funcptr.pas}
{$i dos2file.pas}
{$i doscodes.pas}
{$i uidump.pas}
{$i tpcodes.pas}
{$i dos2err.pas}
{$i drvfile.pas}
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
        oldScrStat     : TScreenStatus;
        scrHandle      : TTextHandle;
        device         : TDeviceCtrl;
        version        : TMSXDOSVersion;
        bExecDump      : Boolean;

Begin
  GetMSXDOSVersion( version );
  bExecDump := False;

  With parms Do
  Begin
    If( bFile )  Then  { File dump }
    Begin
      With device Do
      Begin      { Setup the driver for file operations }
        nOpenDevFnAddr       := Addr( OpenFileDev );
        nCloseDevFnAddr      := Addr( CloseFileDev );
        nSeekDevFnAddr       := Addr( SeekFileDev );
        nGetDevParmsFnAddr   := Addr( GetFileDevParms );
        nReadDevFnAddr       := Addr( ReadFileDev );
        nWriteDevFnAddr      := Addr( WriteFileDev );
        nErrorHandlingFnAddr := Addr( ErrorHandlingFileDev );
        FileCtrl.strFileName := strFileName;
        OSEnv.nOSVersion     := version.nKernelMajor;

        With Buffer Do
        Begin
          nMemoryPtr := 0;
          FillChar( nDevicePtr, SizeOf( nDevicePtr ), 0 );
        End;

        bExecDump := True;
      End;
    End
    Else               { Sector Dump - Call the external application module }
      CallExec( 'MSXDUMPD.COM' );
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
