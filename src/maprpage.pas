(*<maprpage.pas>
 * Memory mapper management implementation using MSXDOS2 EXTBIO calls.
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: maprpage.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/maprpage.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - types.pas;
 * - msxbios.pas;
 * - extbio.pas;
 * - maprdefs.pas;
 * - maprbase.pas;
 *)


(**
  * Retrieve a mapper segment for the specified page.
  * @param handle The allocated handle by the @see InitMapper routine;
  * @param nPageId The page id which the segment will be retrieved;
  *)
Function GetMapperPage( Var handle : TMapperHandle;
                        nPageId    : Byte ) : Byte;
Var
        nSegmentId  : Byte;
        nJmpTblAddr : Integer;

Begin
  nJmpTblAddr := handle.nStartAddrJumpTbl + aGetPageEntry[nPageId];

  (*
   * The ASM routine below is located in the .\ASM\ project folder
   * and was generated by INLASS.
   *)
  Inline(
          $21/*+$0007          {       LD HL,RETJ                    }
          /$E5                 {       PUSH HL                       }
          /$2A/nJmpTblAddr     {       LD HL,(nJmpTblAddr)           }
          /$E9                 {       JP (HL)                       }
          /$32/nSegmentId      { RETJ: LD (nSegmentId),A             }
                               {       END                           } );

  GetMapperPage := nSegmentId;
End;

(**
  * Put a specified mapper segment to a page, activating it.
  * @param handle The allocated handle by the @see InitMapper routine;
  * @param nSegmentId The segment id which the page will be assigned;
  * @param nPageId The page to assign to a segment;
  *)
Procedure PutMapperPage( Var handle : TMapperHandle;
                         nSegmentId, nPageId : Byte );
Var
        nJmpTblAddr : Integer;

Begin
  nJmpTblAddr := handle.nStartAddrJumpTbl + aPutPageEntry[nPageId];

  (*
   * The ASM routine below is located in the .\ASM\ project folder
   * and was generated by INLASS.
   *)
  Inline(
          $21/*+$000A          {       LD HL,RETJ                    }
          /$E5                 {       PUSH HL                       }
          /$3A/nSegmentId      {       LD A,(nSegmentId)             }
          /$2A/nJmpTblAddr     {       LD HL,(nJmpTblAddr)           }
          /$E9                 {       JP (HL)                       }
                               { RETJ: END                           } );
End;

(**
  * Retrieve a mapper segment based on specified address.
  * @param handle The allocated handle by the @see InitMapper routine;
  * @param nAddress The address which the segment will be retrieved;
  *)
Function GetMapperPageByAddress( Var handle : TMapperHandle;
                                 nAddress   : Integer ) : Byte;
Var
        nSegmentId  : Byte;
        nJmpTblAddr : Integer;

Begin
  nJmpTblAddr := handle.nStartAddrJumpTbl + ctGET_PH;

  (*
   * The ASM routine below is located in the .\ASM\ project folder
   * and was generated by INLASS.
   *)
  Inline(
          $21/*+$000C          {       LD HL,RETJ                    }
          /$E5                 {       PUSH HL                       }
          /$2A/nAddress        {       LD HL,(nAddress)              }
          /$DD/$2A/nJmpTblAddr {       LD IX,(nJmpTblAddr)           }
          /$DD/$E9             {       JP (IX)                       }
          /$32/nSegmentId      { RETJ: LD (nSegmentId),A             }
                               {       END                           } );

  GetMapperPageByAddress := nSegmentId;
End;

(**
  * Put a specified mapper segment to a page considering the passed
  * address, activating it.
  * @param handle The allocated handle by the @see InitMapper routine;
  * @param nSegmentId The segment id which the page will be assigned;
  * @param nAddress The address to assign to a segment;
  *)
Procedure PutMapperPageByAddress( Var handle : TMapperHandle;
                                  nSegmentId : Byte;
                                  nAddress   : Integer );
Var
        nJmpTblAddr : Integer;

Begin
  nJmpTblAddr := handle.nStartAddrJumpTbl + ctPUT_PH;

  (*
   * The ASM routine below is located in the .\ASM\ project folder
   * and was generated by INLASS.
   *)
  Inline(
          $21/*+$000F          {       LD HL,RETJ                    }
          /$E5                 {       PUSH HL                       }
          /$3A/nSegmentId      {       LD A,(nSegmentId)             }
          /$2A/nAddress        {       LD HL,(nAddress)              }
          /$DD/$2A/nJmpTblAddr {       LD IX,(nJmpTblAddr)           }
          /$DD/$E9             {       JP (IX)                       }
                               { RETJ: END                           } );
End;
