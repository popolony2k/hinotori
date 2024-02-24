(*<unapinfo.pas>
 * UNAPI base information gathering routines.
 * All function addresses and EXTBIO function call is respecting
 * the UNAPI specification reached at Konamiman site at
 * http://www.konamiman.com.
 *
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: unapinfo.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/unapinfo.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxbios.pas;
 * - extbio.pas;
 * - unapi.pas;
 *)

Const   ctNameStringSize = 63;    { Name string max size }

(**
  * UNAPI Version structure.
  *)
Type TUNAPIVersion = Record
  nMinor,
  nMajor   : Byte;
End;

(**
  * UNAPI information.
  *)
Type TUNAPIInfo = Record
  strImplName     : String[ctNameStringSize];   { Implementation name }
  apiSpecVersion,                               { API spec. supported }
  apiImplVersion  : TUNAPIVersion;              { API impl. version   }
End;


(**
  * Retrieve the the implementation name and API version.
  * @param impl Reference to the implementation pointer previously found
  * by @see UNAPIGetImplementation;
  * @param info Reference to the @see TUNAPIInfo structure to receive
  * the UNAPI information;
  *)
Procedure UNAPIGetInfo( Var impl : TUNAPIImplPointer; Var info : TUNAPIInfo );
Var
     nPri,
     nSec,
     nValue,
     nCount  : Byte;
     regs    : TRegs;

Begin
  FillChar( regs, SizeOf( regs ), 0 );
  nCount := 0;
  regs.A := 0;      { UNAPI_GET_INFO }

  UNAPICallFn( impl, regs );

  nValue := RDSLT( impl.nSlotNumber, regs.HL );

  (*
   * Retrieve the implementation name.
   *)
  While( ( nValue <> 0 ) And ( nCount < ctNameStringSize ) ) Do
  Begin
    info.strImplName[nCount+1] := Char( nValue );
    nCount  := nCount + 1;
    nValue  := RDSLT( impl.nSlotNumber, regs.HL + nCount );
  End;

  If( nCount > 0 )  Then
    info.strImplName[0] := Char( nCount );

  (*
   * Get the specification and implementation
   * version.
   *)
  info.apiSpecVersion.nMinor := regs.E;
  info.apiSpecVersion.nMajor := regs.D;
  info.apiImplVersion.nMinor := regs.C;
  info.apiImplVersion.nMajor := regs.B;
End;
