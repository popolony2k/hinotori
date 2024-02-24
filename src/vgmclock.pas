(*<vgmclock.pas>
 * Library for VGM music handling.
 * Check for newer VGM format definition at following URL address below
 * http://www.smspower.org/Music/VGMFileFormat?from=Development.VGMFormat
 * CopyLeft (c) since 1995 by PopolonY2k.
 *)

(**
  *
  * $Id: vgmclock.pas 128 2020-07-08 17:51:23Z popolony2k $
  * $Author: popolony2k $
  * $Date: 2020-07-08 14:51:23 -0300 (Wed, 08 Jul 2020) $
  * $Revision: 128 $
  * $HeadURL: https://svn.code.sf.net/p/oldskooltech/code/msx/trunk/msxdos/pascal/vgmclock.pas $
  *)

(*
 * This module depends on folowing include files (respect the order):
 * - databufr.pas;
 * - types.pas;
 * - vgmtypes.pas;
 *)


(**
  * AY8910 chip types supported by VGM format.
  *)
Const   ctAY8910                = $00;
        ctAY8912                = $01;
        ctAY8913                = $02;
        ctAY8930                = $03;
        ctYM2149                = $10;
        ctYM3439                = $11;
        ctYMZ284                = $12;
        ctYMZ294                = $13;

(**
  * Header position index (Version 1.70). All fields are 32Bit, except when
  * the comments shows the field's real size.
  *)
Const
        ctSN76489Clock          = $0C; { SN76489 clock }
        ctYM2413Clock           = $10; { YM2413 clock  }
        ctSN76489Feedback       = $28; { SN76489 feedback - 16Bit }
        ctSN76489ShiftRegWidth  = $2A; { SN76489 shift regs. width 8Bit }
        ctSN76489Flags          = $2B; { SN76489 flags - 8Bit }
        ctYM2612Clock           = $2C; { YM2612 clock }
        ctYM2151Clock           = $30; { YM2151 clock }
        ctSegaPCMClock          = $38; { Sega PCM clock }
        ctSPCMInterface         = $3C; { SPCM interface }
        ctRF5C68Clock           = $40; { RF5C68 clock }
        ctYM2203Clock           = $44; { YM2203 clock }
        ctYM2608Clock           = $48; { YM2606 clock }
        ctYM2610BClock          = $4C; { YM2610B clock }
        ctYM3812Clock           = $50; { YM3812 clock }
        ctYM3526Clock           = $54; { YM3526 clock }
        ctY8950Clock            = $58; { Y8950 clock }
        ctYMF262Clock           = $5C; { YMF262 clock }
        ctYMF278BClock          = $60; { YMF278B clock }
        ctYMF271Clock           = $64; { YMF271 clock }
        ctYMZ280BClock          = $68; { YMZ280B clock }
        ctRF5C164Clock          = $6C; { RF5C164 clock }
        ctPWMClock              = $70; { PWM clock }
        ctAY8910Clock           = $74; { AY8910 clock }
        ctAY8910ChipType        = $78; { AY8910 chip type - 8Bit }
        ctAY8910Flags           = $79; { AY8910 flags - 8Bit }
        ctYM2203_AY8910Flags    = $7A; { YM2203/AY8910 flags - 8Bit }
        ctYM2608_AY8910Flags    = $7B; { YM2608/AY8910 flags - 8Bit }
        ctGameBoyDMGClock       = $80; { GameBoyDMG clock }
        ctNESAPUClock           = $84; { NES AUP clock }
        ctMultiPCMClock         = $88; { MultiPCM Clock }
        ctUPD7759Clock          = $8C; { UPD7759 clock }
        ctOKIM6258Clock         = $90; { OKIM6258 clock }
        ctOKIM6258Flags         = $94; { OKIM6258 flags - 8Bit }
        ctK054539Flags          = $95; { K054539 flags - 8Bit }
        ctC140ChipType          = $96; { C140 Chip type - 8Bit }
        ctOKIM6295Clock         = $98; { OKIM6259 clock }
        ctK051649Clock          = $9C; { K051649 clock }
        ctK054539Clock          = $A0; { K054539 clock }
        ctHUC6280Clock          = $A4; { HUC6280 clock }
        ctC140Clock             = $A8; { C140 clock }
        ctK053260Clock          = $AC; { K053260 clock }
        ctPokeyClock            = $B0; { Pokey clock }
        ctQSoundClock           = $B4; { QSound clock }

(**
  * Structure containing all clocks supported by library. The full set of
  * clocks supported by the latest VGM specification can be reached in
  * the VGM raw buffer in @see TVGMData structure.
  *
  * Defined chipsets data:
  *
  * AY-3-8910/YM2149F (PSG/MSX/Spectrum/Several arcades);
  * YM2413 (OPLL/MSX Sound/Master System)
  * Y8950 (Philips Music Module (aka MSX AUDIO)/some arcade systems)
  * K051649 (MSX SCC/some arcade systems)
  * YMF278B (MSX OPL4 based cards (eg. Moonsound/Tecnobytes Shockwave)/
  * some arcade systems)
  *)
Type TVGMClocks = Record
  nAY8910Clock      : TInt32;              { AY8910 clock  }
  nYM2413Clock      : TInt32;              { YM2413 clock  }
  nY8950Clock       : TInt32;              { Y8950 clock   }
  nK051649Clock     : TInt32;              { K051649 clock }
  nYMF278BClock     : TInt32;              { YMF278B clock }
  nYM2151Clock      : TInt32;              { YM2151 clock  }
End;


(**
  * Helper functions to retrieve all clocks data from VGM buffer into the
  * @see TVGMData structure.
  * @param data The @see TVGMData structure containing the VGM data of all
  * clocks will be retrieved;
  * @param clocks The reference to the @see TVGMClocks structure to receive
  * the clocks information from VGM data buffer;
  * Add newer clock information here always when needed;
  *)
Procedure GetClocksData( Var data : TVGMData; Var clocks : TVGMClocks );
Begin
  FillChar( clocks, SizeOf( clocks ), 0 );

  With data Do
  Begin
    (* Since protocol 1.10 *)
    If( ( header.nVersionNumber[0] >= $10 ) And
        ( header.nVersionNumber[1] >= $1 ) )  Then
    Begin
      (* YM2151 Clock *)
      GetData( Ord( pVGMSongBuffer ),
               Addr( clocks.nYM2151Clock ),
               ctYM2151Clock,
               SizeOf( clocks.nYM2151Clock ) );
    End;

    (* Since protocol 1.51 *)
    If( ( header.nVersionNumber[0] >= $51 ) And
        ( header.nVersionNumber[1] >= $1 ) )  Then
    Begin
      (* AY8910 Clock *)
      GetData( Ord( pVGMSongBuffer ),
               Addr( clocks.nAY8910Clock ),
               ctAY8910Clock,
               SizeOf( clocks.nAY8910Clock ) );

      (* Y8950 Clock *)
      GetData( Ord( pVGMSongBuffer ),
               Addr( clocks.nY8950Clock ),
               ctY8950Clock,
               SizeOf( clocks.nY8950Clock ) );

      (* YMF278B Clock *)
      GetData( Ord( pVGMSongBuffer ),
               Addr( clocks.nYMF278BClock ),
               ctYMF278BClock,
               SizeOf( clocks.nYMF278BClock ) );
    End;

    (* Since protocol 1.61 *)
    If( ( header.nVersionNumber[0] >= $61 ) And
        ( header.nVersionNumber[1] >= $1 ) )  Then
    Begin
      (* K051649 Clock *)
      GetData( Ord( pVGMSongBuffer ),
               Addr( clocks.nK051649Clock ),
               ctK051649Clock,
               SizeOf( clocks.nK051649Clock ) );
    End;

    (* All protocol versions *)
    (* YM2413 Clock *)
    GetData( Ord( pVGMSongBuffer ),
             Addr( clocks.nYM2413Clock ),
             ctYM2413Clock,
             SizeOf( clocks.nYM2413Clock ) );
  End;
End;
