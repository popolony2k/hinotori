(*<vgmplay.pas>
 * Library for VGM music handling.
 * Check for newer VGM format definition at following URL address below
 * http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: vgmplay.pas 133 2020-09-04 00:51:19Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-09-03 21:51:19 -0300 (Thu, 03 Sep 2020) $
  * $Revision: 133 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/vgmplay.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - hooks.pas;
 * - systypes.pas;
 * - types.pas;
 * - sndchips.pas;
 * - sndtypes.pas;
 * - ay8910.pas
 * - scc.pas;
 * - opl4.pas;
 * - y8950.pas;
 * - ym2413.pas;
 * - ym2151.pas;
 * - vgmtypes.pas;
 * - maprdefs.pas;
 * - wait.pas;
 * - math.pas;
 * - math32.pas;
 * - longjmp.pas;
 *)

{$r-}

(**
  * VGM Player commands definitions.
  *)
Const
        ctWaitSamples           = $61;   { Wait for nnnn (16bit) samples }
        ctWait735Samples        = $62;   { Wait 735 samples }
        ctWait882Samples        = $63;   { Wait 882 samples }
        ctOverrideLength        = $64;   { Override length of $62/$63 }
        ctAY8910Write           = $A0;   { Write value dd to register aa }
        ctYM2413Write           = $51;   { Write value dd to register aa }
        ctY8950Write            = $5C;   { Write value dd to register aa }
        ctYM2151Write           = $54;   { Write value dd to register aa }
        ctK051649Write          = $D2;   { Port pp write val. dd to reg. aa }
        ctYMF278BWrite          = $D0;   { Port pp write val. dd to reg. aa }
        ctEndOfSoundData        = $66;   { End of sound data }


(**
  * Play the VGM file content previously opened by @see OpenVGM.
  * @param data The data that will be played;
  * @param chips The @see TSoundChips structure containing all information
  * about the known chips used by the library;
  *)
Procedure PlayVGM( Var data : TVGMData; Var chips : TSoundChips );

(*
 * Internal local constants.
 *)
Const
     (*
      * The __ctMapperBufferEndAddr and __ctMapperBufferEndAddr_1 below
      * are calculated by using the following formula:
      *
      * __ctMapperBufferEndAddr   = ctVGMDataPageAddress +
      *                             __ctMapperSegmentSize - 1;
      * __ctMapperBufferEndAddr_1 = __ctMapperBufferEndAddr - 1:
      *)
     __ctMapperBufferEndAddr        = $BFFF; { Mapper page final addr      }
     __ctMapperBufferEndAddr_1      = $BFFE; { Mapper page final addr - 1  }
     __ctMapperSegmentSize   : Real = $4000; { Mapper buffer segment size  }
     __ctEscKeyMask                 = $4;    { Esc Key PPI mask            }


Var  nExecMapperPagingAddr,
     nWriteSCCDirectAddr,
     nWriteOPL4DirectAddr,
     nWriteY8950DirectAddr,
     nWriteYM2151DirectAddr,
     nWriteYM2413DirectAddr,
     nLoopJmpAddr,
     nFnJmpAddr,
     nWaitDirectAddr,
     nMoveMapper16Addr,
     nMoveMapper24Addr,
     nVGMCmdsJmpTblAddr,
     nLoopOffset,
     nCurrentStreamPos  : TWord;
     nCurrentCmd        : Byte;
     nSegCounter,
     nSegOffset,
     nPlaying           : TWord; {Byte;} { TODO: }
     nActiveSlotId      : TSlotNumber;
     bInitJmpTbl        : Boolean;
     fLoopOffset        : Real;
     nLoopOffset32      : TInt32;
     pWaitInterval      : ^Integer;
     aSndBuffer         : Array[0..6] Of Byte; { Max. VGM parameters + 1 }
     aVGMCmdsJmpTbl     : Array[0..ctHeaderSizeVer170] Of Integer;
     aSamples           : Array[ctWait735Samples..ctWait882Samples] Of Integer;

Label    __endLoop;

  (**
    * Assign a range of commands to a specific function handler.
    * @param nStartCmd The initial command range;
    * @param nEndCmd The final command range;
    * @param nFnAddr The function that will respond to these commands range;
    *)
  Procedure __AssignCmdFn( nStartCmd, nEndCmd, nFnAddr : Integer );
  Var
        nCount : Integer;
  Begin
    For nCount := nStartCmd To nEndCmd Do
      aVGMCmdsJmpTbl[nCount] := nFnAddr;
  End;

  (**
    * Executes the memory mapper paging system.
    *)
  Procedure __ExecMapperPaging;
  Var
           nSlotId   : TSlotNumber;

  Begin
    {%W+}
    If( nSegCounter <> data.mapper.nSegCounter ) Then
    {%W-}
    Begin
      nSegCounter := Succ( nSegCounter );
      nCurrentStreamPos := Ord( data.pVGMSongBuffer );
    End
    Else
    Begin
      nSegCounter := 0;
      nCurrentStreamPos := ( Ord( data.pVGMSongBuffer ) + nLoopOffset );
    End;

    nSlotId := data.mapper.aSegments[nSegCounter].nSlotId;

    (*
     * Enable slot/page if mapper slot changed
     *)
    {%W+}
    If( nSlotId <> nActiveSlotId )  Then
    {%W-}
    Begin
      nActiveSlotId := nSlotId;
      ENASLT( nActiveSlotId, ctVGMSelectedPage );
    End;

    Port[ctMapperPortPage2] := data.mapper.aSegments[nSegCounter].nSegmentId;
  End;

  (**
    * Move a 16Bit data from mapper to the procedure's stack address area,
    * paging mapper segments when necessary.
    * @param __pSndChipArrayParms Pointer to return the buffer with buffer data
    * loaded from Mapper.
    *)
  Procedure __MoveMapper16BitData{( __pSndChipArrayParms : Pointer )};
  Begin
    {%W+}
    If( nCurrentStreamPos < __ctMapperBufferEndAddr ) Then
    {%W-}
    Begin
      __pSndChipArrayParms := Ptr( nCurrentStreamPos );
      nCurrentStreamPos := nCurrentStreamPos + 2;

      (* Direct jump to command processing routine *)
      Inline( $2A/nFnJmpAddr   { LD HL,(nFnJmpAddr) }
              /$E9             { JP (HL)            } );
    End
    Else
    Begin
      __pSndChipArrayParms := Ptr( Addr( aSndBuffer ) );
      aSndBuffer[0] := Mem[nCurrentStreamPos];
      __ExecMapperPaging;
      aSndBuffer[1] := Mem[nCurrentStreamPos];
      nCurrentStreamPos := Succ( nCurrentStreamPos );

      (* Direct jump to command processing routine *)
      Inline( $2A/nFnJmpAddr   { LD HL,(nFnJmpAddr) }
              /$E9             { JP (HL)            } );
    End;
  End;

  (**
    * Move a 24Bit data from mapper to the procedure's stack address area,
    * paging mapper segments when necessary.
    * @param __pSndChipArrayParms Pointer to return the buffer with buffer data
    * loaded from Mapper.
    *)
  Procedure __MoveMapper24BitData{( __pSndChipArrayParms : Pointer )};
  Begin
    {%W+}
    If( nCurrentStreamPos < __ctMapperBufferEndAddr_1 ) Then
    {%W-}
    Begin
      __pSndChipArrayParms := Ptr( nCurrentStreamPos );
      nCurrentStreamPos := nCurrentStreamPos + 3;

      (* Direct jump to command processing routine *)
      Inline( $2A/nFnJmpAddr   { LD HL,(nFnJmpAddr) }
              /$E9             { JP (HL)            } );
    End
    Else
    Begin
      __pSndChipArrayParms := Ptr( Addr( aSndBuffer ) );

      {%W+}
      If( nCurrentStreamPos = __ctMapperBufferEndAddr_1 )  Then
      {%W-}
      Begin
        aSndBuffer[0]     := Mem[nCurrentStreamPos];
        nCurrentStreamPos := Succ( nCurrentStreamPos );
        aSndBuffer[1]     := Mem[nCurrentStreamPos];
        __ExecMapperPaging;
        aSndBuffer[2]     := Mem[nCurrentStreamPos];
        nCurrentStreamPos := Succ( nCurrentStreamPos );

        (* Direct jump to command processing routine *)
        Inline( $2A/nFnJmpAddr   { LD HL,(nFnJmpAddr) }
                /$E9             { JP (HL)            } );
      End;

      aSndBuffer[0]     := Mem[nCurrentStreamPos];
      __ExecMapperPaging;
      aSndBuffer[1]     := Mem[nCurrentStreamPos];
      nCurrentStreamPos := Succ( nCurrentStreamPos );
      aSndBuffer[2]     := Mem[nCurrentStreamPos];
      nCurrentStreamPos := Succ( nCurrentStreamPos );

      (* Direct jump to command processing routine *)
      Inline( $2A/nFnJmpAddr   { LD HL,(nFnJmpAddr) }
              /$E9             { JP (HL)            } );
    End;
  End;

  Procedure __WaitNSamples;   { Wait n samples - $61 nn nn }

    Procedure __WaitInterval;  { Endpoint of __WaitNSamples }
    Begin
      pWaitInterval   := Ptr( Ord( __pSndChipArrayParms ) );
      __nWaitInterval := pWaitinterval^;

      Inline( $2A/nWaitDirectAddr   { LD HL,(nWaitDirectAddr) }
              /$E9                  { JP (HL)                 } );
    End;

  Begin    { __WaitNSamples entry point }
    nFnJmpAddr := Addr( __WaitInterval );

    Inline( $2A/nMoveMapper16Addr { LD HL,(nMoveMapper16Addr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __Wait735_882Samples;   { Wait 735 or 882 samples (60Hz/50Hz) }
  Begin
    __nWaitInterval := aSamples[nCurrentCmd];

    Inline( $2A/nWaitDirectAddr   { LD HL,(nWaitDirectAddr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __Wait7nSamples;        { Wait 7n samples (n+1). 'n' = 1 Nibble }
  Begin
    __nLastWaitInterval := ( __nLastWaitInterval + ( nCurrentCmd - $71 ) );
  End;

  Procedure __Wait8nSamples;        { Wait 8n samples. 'n' = 1 Nibble }
  Begin
    __nLastWaitInterval := ( __nLastWaitInterval + ( nCurrentCmd - $80 ) );
  End;

  Procedure __WriteY8950;     { Y8950 write dd to register aa }
  Begin
    nFnJmpAddr := nWriteY8950DirectAddr;

    Inline( $2A/nMoveMapper16Addr { LD HL,(nMoveMapper16Addr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __WriteYM2413;    { YM2413, write dd to register aa }
  Begin
    nFnJmpAddr := nWriteYM2413DirectAddr;

    Inline( $2A/nMoveMapper16Addr { LD HL,(nMoveMapper16Addr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __WriteAY8910;    { AY8910, write dd to register aa }
  Begin
    nFnJmpAddr := Addr( WriteAY8910Direct );

    Inline( $2A/nMoveMapper16Addr { LD HL,(nMoveMapper16Addr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __WriteSCC;   { K051649 port pp, write dd to register aa }
  Begin
    nFnJmpAddr := nWriteSCCDirectAddr;

    Inline( $2A/nMoveMapper24Addr { LD HL,(nMoveMapper24Addr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __WriteOPL4;   { YMF278B port pp, write dd to register aa }
  Begin
    nFnJmpAddr := nWriteOPL4DirectAddr;

    Inline( $2A/nMoveMapper24Addr { LD HL,(nMoveMapper24Addr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __WriteYM2151;    { YM2151 write dd to register aa }
  Begin
    nFnJmpAddr := nWriteYM2151DirectAddr;

    Inline( $2A/nMoveMapper16Addr { LD HL,(nMoveMapper16Addr) }
            /$E9                  { JP (HL)                 } );
  End;

  Procedure __WriteNullBoard; { Null board write }
  Begin
    { Do nothing - Null device }
  End;

  Procedure __EndOfSoundData; { End Of sound data - Loop management }
  Var
         nSlotId : TSlotNumber;

  Begin
    {%W+}
    If( nLoopOffset <> 0 ) Then
    {%W-}
    Begin
      nCurrentStreamPos := ( Ord( data.pVGMSongBuffer ) + nLoopOffset );
      nSegCounter       := nSegOffset;
      nSlotId           := data.mapper.aSegments[nSegCounter].nSlotId;

      (*
       * Enable slot/page if mapper slot changed
       *)
      {%W+}
      If( nSlotId <> nActiveSlotId )  Then
      {%W-}
      Begin
        nActiveSlotId := nSlotId;
        ENASLT( nActiveSlotId, ctVGMSelectedPage );
      End;

      Port[ctMapperPortPage2] := data.mapper.aSegments[nSegCounter].nSegmentId;
    End
    Else
      nPlaying := 0;
  End;

  Procedure __InitCmdJmpTable; { Init commands jump table }
  Var
        nCount : Integer;

  Begin
    For nCount := 0 To ctHeaderSizeVer170 Do { Jump to the loop's begining }
      aVGMCmdsJmpTbl[nCount] := nLoopJmpAddr;

    __AssignCmdFn( ctWaitSamples,
                   ctWaitSamples,
                   Addr( __WaitNSamples ) );
    __AssignCmdFn( ctWait735Samples,
                   ctWait882Samples,
                   Addr( __Wait735_882Samples ) );
    __AssignCmdFn( $70,
                   $7F,
                   Addr( __Wait7nSamples ) );
    __AssignCmdFn( $80,
                   $8F,
                   Addr( __Wait8nSamples ) );
    __AssignCmdFn( ctEndOfSoundData,
                   ctEndOfSoundData,
                   Addr( __EndOfSoundData ) );
    __AssignCmdFn( ctYM2413Write,
                   ctYM2413Write,
                   Addr( __WriteYM2413 ) );
    __AssignCmdFn( ctAY8910Write,
                   ctAY8910Write,
                   Addr( __WriteAY8910 ) );
    __AssignCmdFn( ctY8950Write,
                   ctY8950Write,
                   Addr( __WriteY8950 ) );
    __AssignCmdFn( ctYMF278BWrite,
                   ctYMF278BWrite,
                   Addr( __WriteOPL4 ) );
    __AssignCmdFn( ctK051649Write,
                   ctK051649Write,
                   Addr( __WriteSCC ) );
    __AssignCmdFn( ctYM2151Write,
                   ctYM2151Write,
                   Addr( __WriteYM2151 ) );

    bInitJmpTbl := False;
  End;

(*Var     nFnJmpAddr : Integer;   { Pascal mode - uncomment }*)

(* Main procedure entry point *)
Begin

  (* Timing initialization *)
  SetWaitFreqDivisor( chips.nHostFreqDivisor );

  (* SCC addresses table initialization *)
  InitSCCBaseAddresses;

  With chips Do
  Begin
    (* Memory based chips initialization *)
    __nSCCPrimarySlot      := nSCCPrimarySlot;
    __nSCCSecondarySlot    := nSCCSecondarySlot;
    __nYM2151PrimarySlot   := nYM2151PrimarySlot;
    __nYM2151SecondarySlot := nYM2151SecondarySlot;
  End;

  (*
   * Configure the temporary song buffer on stack and get the song
   * initial VGM data pointer position.
   *)
  __pSndChipArrayParms := Ptr( Addr( aSndBuffer ) );
  nCurrentStreamPos    := ( Ord( data.pVGMSongBuffer ) + data.nHeaderSize );

  (*
   * Check if song has a loop and points the LoopOffset pointer
   * correctly, considering the memory paging system.
   *)
  Move( data.header.nLoopOffset, nLoopOffset, SizeOf( nLoopOffset ) );

  (* Check if song has a loop *)
  If( ( data.header.nLoopOffset[0] = 0 ) And
      ( data.header.nLoopOffset[1] = 0 ) And
      ( data.header.nLoopOffset[2] = 0 ) And
      ( data.header.nLoopOffset[3] = 0 ) )  Then
  Begin
    nLoopOffset := 0;
    nSegOffset  := 0;
  End
  Else
  Begin
    nLoopOffset32[0] := data.header.nLoopOffset[3];
    nLoopOffset32[1] := data.header.nLoopOffset[2];
    nLoopOffset32[2] := data.header.nLoopOffset[1];
    nLoopOffset32[3] := data.header.nLoopOffset[0];

    fLoopOffset := ( Int32ToReal( nLoopOffset32 ) - ctLoopOffSet );
    nSegOffset  := Trunc( fLoopOffset / __ctMapperSegmentSize );
    nLoopOffset := Trunc( fLoopOffset - ( __ctMapperSegmentSize * nSegOffset ) );
  End;

  (* Time samples table *)
  aSamples[ctWait735Samples] := 735; { 60 Hz }
  aSamples[ctWait882Samples] := 882; { 50 Hz }

  (* General internal initialization *)
  bInitJmpTbl   := True;
  nSegCounter   := 0;
  nPlaying      := 0;
  nActiveSlotId := data.mapper.nPriMapperSlotId;

  (* Direct jump addresses initialization *)
  nVgmCmdsJmpTblAddr    := Addr( aVgmCmdsJmpTbl );
  nExecMapperPagingAddr := Addr( __ExecMapperPaging );
  nWaitDirectAddr       := Addr( WaitDirect );
  nMoveMapper16Addr     := Addr( __MoveMapper16BitData );
  nMoveMapper24Addr     := Addr( __MoveMapper24BitData );

  (* Direct jump addresses drivers boards initialization *)
  If( chips.nSCCPrimarySlot <> ctUnitializedSlot )  Then
    nWriteSCCDirectAddr := Addr( WriteSCCDirect )
  Else
    nWriteSCCDirectAddr := Addr( __WriteNullBoard );

  If( chips.nYM2151PrimarySlot <> ctUnitializedSlot )  Then
    nWriteYM2151DirectAddr := Addr( WriteYM2151Direct )
  Else
    nWriteYM2151DirectAddr := Addr( __WriteNullBoard );

  If( chips.nYM2413SlotNumber <> ctUnitializedSlot )  Then
    nWriteYM2413DirectAddr := Addr( WriteYM2413Direct )
  Else
    nWriteYM2413DirectAddr := Addr( __WriteNullBoard );

  If( chips.hasYMF278B )  Then
    nWriteOPL4DirectAddr := Addr( WriteOPL4Direct )
  Else
    nWriteOPL4DirectAddr := Addr( __WriteNullBoard );

  If( chips.hasY8950 )  Then
    nWriteY8950DirectAddr := Addr( WriteY8950Direct )
  Else
    nWriteY8950DirectAddr := Addr( __WriteNullBoard );

  SetJmp( nLoopJmpAddr );

  {%W+}
  If( nPlaying < __ctEscKeyMask )  Then
  {%W-}
  Begin
    If( bInitJmpTbl )  Then           { Initialize the command jump table     }
      __InitCmdJmpTable
    Else
      Goto __endLoop;
  End;

  (* Source code: asm\popart\vgmplay.asm *)

  Inline( { ; Check for the ESC key to stop playing }
          $3E/$07                     {         LD   A,07H                    }
          /$D3/$AA                    {         OUT  (KBMATRSEL),A            }
          /$DB/$A9                    {         IN   A,(KBSTATUS)             }
          /$E6/$04                    {         AND  ESCKEYMSK                }
          /$32/nPlaying               {         LD   (nPlaying),A             }

          { ; Streaming routine }

          /$ED/$4B/nCurrentStreamPos  {         LD   BC,(nCurrentStreamPos)   }
          /$0A                        {         LD   A,(BC)                   }
          /$32/nCurrentCmd            {         LD   (nCurrentCmd),A          }
          /$6F                        {         LD   L,A                      }
          /$26/$00                    {         LD   H,00H                    }
          /$29                        {         ADD  HL,HL                    }
          /$ED/$5B/nVgmCmdsJmpTblAddr {         LD   DE,(nVgmCmdsJmpTblAddr)  }
          /$19                        {         ADD  HL,DE                    }
          /$5E                        {         LD   E,(HL)                   }
          /$23                        {         INC  HL                       }
          /$56                        {         LD   D,(HL)                   }
          /$D5                        {         PUSH DE                       }
          /$03                        {         INC  BC                       }
          /$ED/$43/nCurrentStreamPos  {         LD   (nCurrentStreamPos),BC   }
          /$21/__ctMapperBufferEndAddr{         LD HL,__ctMapperBufferEndAddr }
          /$AF                        {         XOR  A                        }
          /$ED/$42                    {         SBC  HL,BC                    }
          /$F2/*+$000A                {         JP   P,ENDPRC                 }
          /$21/*+$0007                {         LD   HL,ENDPRC                }
          /$E5                        {         PUSH HL                       }
          /$2A/nExecMapperPagingAddr  {         LD HL,(nExecMapperPagingAddr) }
          /$E9                        {         JP (HL)                       }
          /$E1                        { ENDPRC: POP HL                        }
          /$ED/$5B/nLoopJmpAddr       {         LD  DE, (nLoopJmpAddr)        }
          /$D5                        {         PUSH DE                       }
          /$E9                        {         JP (HL)                       } );

  {
  (* PASCAL STREAMING ROUTINE *)
  (*
   * Check for the ESC key to stop playing.
   *)
  (*
   Port[$AA] := 7;                                * PPI keyboard matrix select *
   nPlaying  := ( Port[$A9] And __ctEscKeyMask ); * ESC key reading *
  *)
  Inline( $3E/$07/                  (* LD  A,07h         *)
          $D3/$AA/                  (* OUT (AAh),A       *)
          $DB/$A9/                  (* IN  A,A9h         *)
          $E6/$04/                  (* AND 04h           *)
          $32/nPlaying              (* LD  (nPlaying), A *) );

  nCurrentCmd := Mem[nCurrentStreamPos];
  nFnJmpAddr  := aVgmCmdsJmpTbl[nCurrentCmd];
  nCurrentStreamPos := Succ( nCurrentStreamPos );

  (*%W+*)
  If( __ctMapperBufferEndAddr < nCurrentStreamPos )  Then
  (*%W-*)
    __ExecMapperPaging;

  (*
   * Perform a call function simulation setting return address to begining
   * of streaming loop.
   *)
  Inline( $2A/nLoopJmpAddr   (* LD HL,(nLoopJmpAddr) *)
          /$E5               (* PUSH HL              *)
          /$2A/nFnJmpAddr    (* LD HL,(nFnJmpAddr)   *)
          /$E9               (* JP (HL)              *) );

  (* PASCAL STREAMING ROUTINE *)
  }

  __endLoop:
End;

{$r+}
