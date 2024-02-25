(*<tcpsdemo.pas>
 * UNAPI TCP/IP capabilities and status routines demo.
 * All function addresses and EXTBIO function call is respecting
 * the UNAPI specification reached at Konamiman site at
 * http://www.konamiman.com.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(* Please respect include dependency order *)

{$i ..\..\src\system\types.pas;}
{$i ..\..\src\bios\msxbios.pas;}
{$i ..\..\src\bios\extbio.pas;}
{$i ..\..\src\unapi\unapi.pas;}
{$i ..\..\src\unapi\unapinfo.pas}
{$i ..\..\src\unapi\utcpstat.pas}


(**
  * Print the TCP/IP capabilities of OBSONET implementation.
  * @param cap The capabilities to print;
  *)
Procedure PrintTCPIPCapabilities( Var cap : TUNAPITCPCapabilities );
Begin
  WriteLn( 'TODO: Finish capabilities info !!!' );
End;

(**
  * Print the UNAPI information details, like name and version.
  * @param impl The implementation to print the information;
  *)
Procedure PrintUNAPIInfo( Var impl : TUNAPIImplPointer );
Var
      info : TUNAPIInfo;

Begin
  UNAPIGetInfo( impl, info );

  With info Do
  Begin
    WriteLn( 'Implementation name -> ', strImplName );
    WriteLn( 'API specification version -> ',
             apiSpecVersion.nMajor,
             '.',
             apiSpecVersion.nMinor );
    WriteLn( 'API implementation version -> ',
             apiImplVersion.nMajor,
             '.',
             apiImplVersion.nMinor );
  End;
End;

(**
  * Print details about a requested implementation specification.
  * @param strUNAPISpecName The spacification name to retrieve information;
  *)
Procedure PrintUNAPIImplDetails( strUNAPISpecName : TUNAPISpecName );
Var
       impl        : TUNAPIImplPointer;
       cap         : TUNAPITCPCapabilities;
       nMaxStacks,
       nIndex      : Byte;

Begin
  (*
   * Use UNAPI to check if there is at least one UNAPI TCP/IP
   * implementation installed.
   *)
  nMaxStacks := UNAPIDiscovery( strUNAPISpecName );

  If( nMaxStacks >= 1 )  Then
  Begin
    WriteLn( '==========================================' );
    WriteLn( 'Number of ', strUNAPISpecName, ' stacks found -> ', nMaxStacks );

    (*
     * Iterate over all implementations found, checking the capabilities.
     *)
    For nIndex := 1 To nMaxStacks Do
    Begin
      WriteLn( '------------------------------------------' );

      If( UNAPIGetImplementation( strUNAPISpecName, nIndex, impl ) ) Then
      Begin
        WriteLn( 'Implementation Index -> ', nIndex );
        WriteLn;
        PrintUNAPIInfo( impl );

        (*
         * Print TCP/IP capabilities.
         *)
        If( strUNAPISpecName = ctSpecTCPIP ) Then
        Begin
          If( UNAPIGetTCPCapabilities( impl, cap ) )  Then
            PrintTCPIPCapabilities( cap )
          Else
            WriteLn( 'Error retrieving TCP/IP capabilities' );
        End;
      End
      Else
        WriteLn( 'Retrieving implementation fail' );

      WriteLn( '------------------------------------------' );
      WriteLn;

      While( Not KeyPressed ) Do;
    End;
  End
  Else
    WriteLn( 'No ', strUNAPISpecname, ' implementations found.' );
End;


{ Main Block }

Begin
  WriteLn( 'MSX UNAPI-OBSONET Ethernet-TCP/IP sample.' );
  WriteLn( 'TCP/IP capabilities demo.' );
  WriteLn( 'CopyLeft (c) Since 1995 by PopolonY2k' );
  WriteLn( 'Project home at http://www.planetamessenger.org' );
  WriteLn;

  (* Check for Ethernet specifications *)
  PrintUNAPIImplDetails( ctSpecEthernet );

  (* Check for TCP/IP specifications *)
  PrintUNAPIImplDetails( ctSpecTCPIP );
End.
