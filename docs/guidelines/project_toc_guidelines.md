**CopyLeft (c) 1995-2024 by PopolonY2k
**CopyLeft (c) since 2024 by Hinotori Team


**INTRODUCTION**

This document describes project structure and some basic rules guidelines
for developers.


**ABOUT CONTRIBUTION**

THIS IS AN OPEN SOURCE PROJECT, then the use of classes, libraries or beans 
without the source code released under any open license (like GNU, FreeBSD or 
another open license) is forbidden in this project and will be removed of our 
repository code.


**REQUIRED SOFTWARE TO USE AND BUILD THE PACKAGE**

The project requires MCCE Turbo Pascal 3.3f for MSX.


**DIRECTORY AND SOURCE CODE DESCRIPTION**

The package has a basic file structure described below.

ROOT
|
|-- DOCS        (Directory containing documentation about the project)
|     |
|     |--CODE (Source code related documents)
|     |    | - header.txt (Source code default header for all modules)
|     |
|     |-- GUIDELINES (Team development guidelines)
|     |    | -- project_toc_guidelines - Table of contents and guidelines;
|     |
|     -- MSX_TECH (MSX standard related documentation)
|     |    |- sysvars.txt (System variables MSX Assembly Pages document)
|     |
|
|
|======== [ASM CODE - INTEGRATED THROUGH INLASS] ==============================
|
| + .SOU extension is used in assembly source, instead .ASM, because INLASS
|   assembler for Turbo Pascal ASM integration just accepts this extension.  
|
| --ASM
|    |-- MAPPER  (Mapper ASM code used by BIOS based mapper in Turbo Pascal)
|    |     |- putph.sou
|    |     |- putpn.sou
|    |     |- rdseg.sou
|    |     |- wrseg.sou
|    |     |- allseg.sou
|    |     |- calseg.sou
|    |     |- freseg.sou
|    |     |- getph.sou
|    |     |- getpnb.sou
|    |
|    |-- MATH    (Math ASM code used by Math routines (16/32 bit)
|    |     |- math16-1.sou
|    |     |- math16-2.sou
|    |
|    |-- POINTER (Pointer ASM code used by pointer related routines)
|    |     |- funcptr1.sou
|    |     |- funcptr2.sou
|    |     |- pointer.sou
|    |
|    |-- POPART  (POP!ART related ASM code)
|    |     |- vgmplay.sou
|    |
|    |-- SNDCHIP (Sound chip ASM code used by chip drivers)
|    |     |- ay8910.sou
|    |     |- opl4.sou
|    |     |- scc.sou
|    |     |- y8950.sou
|    |     |- ym2151.sou
|    |     |- ym2413.sou
|    |
|    |-- SYSTEM  (System related ASM code)
|    |     |- longjmp.sou 
|    |     |- setjmp.sou
|    |     |- system1.sou
|    |     |- system2.sou
|    |     |- system3.sou
|    |     |- wait.sou
|
|
|======== [FRAMEWORK MODULES PASCAL] ==========================================
|
|========+++++ [FOUNDATION MODULES]
|
|-- types.pas    (New types definitions used through the framework and apps)
|-- bitwise.pas  (Bitwise primitives)
|-- math.pas     (Extra math functions added to Turbo Pascal 3.xx)
|-- math16.pas   (16 Bit extra math functions added to Turbo Pascal 3.xx)
|-- math32.pas   (32 Bit extra math functions added to Turbo Pascal 3.xx)
|-- funcptr.pas  (Function pointer implementation for Turbo Pascal 3.xx)
|-- tpcodes.pas  (Turbo Pascal I/O return codes)
|-- memory.pas   (Memory management helper functions)
|-- databufr.pas (Buffer management helper functions)
|-- helpchar.pas (Helper functions to manage char types)
|-- helpcnv.pas  (Helper functions to handle conversion types)
|-- helpstr.pas  (Helper functions to string manipulation)
|-- bigint.pas   (New math functions to handle Big Integers vars)
|-- fixedpt.pas  (New math functions to handle fixed point operations)
|-- sleep.pas    (Accurate sleep routine based on JIFFY (VBLANK) clock)
|-- wait.pas     (JIFFY/VBLANK based sleep, with frequency deviation correction)
|-- pointer.pas  (Pointer helper routines)
|-- loadable.pas (Loadable Turbo Pascal module (Function/Procedure) routines)
|-- longjmp.pas  (SetJmp/LongJmp Z80 Turbo Pascal implementation)
|
|========+++++ [COLLECTIONS MODULES]
|
|-- lnkdlist.pas (Linear linked list implementation)
|
|========+++++ [MSX INTERNALS MODULES]
|
|-- sysvars.pas  (Official MSX system variables addresses)
|-- systypes.pas (Specific structure definitions to MSX architecture)
|-- system.pas   (MSX system related routines)
|-- hooks.pas    (MSX hooks management routines)
|
|========+++++ [MSX MEMORY MANAGEMENT]
|
|-- memtypes.pas (Memory management definitions)
|-- mapperd.pas  (Memory Mapper (Direct access) routines - unsafe)
|-- maprbase.pas (Memory Mapper (BIOS) base definitions and routines)
|-- maprvars.pas (Memory Mapper (BIOS) memory variables definition)
|-- maprallc.pas (Memory Mapper (BIOS) memory/segment allocation routines)
|-- maprcall.pas (Memory Mapper (BIOS) intersegment call routines)
|-- maprpage.pas (Memory Mapper (BIOS) memory mapper page management routines)
|-- maprrw.pas   (Memory Mapper (BIOS) memory mapper R/W intersegment routines)
|
|========+++++ [BIOS MODULES]
|
|-- msxbios.pas  (MSX-BIOS management and function call library)
|-- extbio.pas   (EXtended BIOS support routines - EXTBIO calls)
|-- conbios.pas  (BIOS addresses related to console)
|-- ctrlbios.pas (BIOS addresses related to controllers)
|-- initbios.pas (BIOS addresses related to Initialization and RST calls)
|-- miscbios.pas (BIOS addresses related to miscelaneous functions)
|-- psgbios.pas  (BIOS addresses related to PSG management)
|-- quebios.pas  (BIOS addresses related to queue management)
|-- tapebios.pas (BIOS addresses related to TAPE management)
|-- vdpbios.pas  (BIOS addresses related to VDP management)
|
|========+++++ [MSXDOS (1 & 2) MODULES]
|
|-- msxdos.pas   (MSXDOS and CP/M80 functions and definitions)
|-- msxdos2.pas  (MSXDOS2 functions and definitions)
|-- dos2file.pas (Wrapper to MSXDOS2 file management calls)
|-- dos2err.pas  (Wrapper to MSXDOS2 error messages management calls)
|-- envvars.pas  (Wrapper to MSXDOS2 environment variables functions)
|-- doscodes.pas (MSXDOS (1&2) and CP/M return codes)
|-- dosio.pas    (MSXDOS and CP/M low level disk I/O functions)
|-- dostime.pas  (MSXDOS date/time functions)
|-- dosutil.pas  (MSXDOS (1&2) helper functions)
|-- dpb.pas      (MSXDOS and CP/M DPB functions)
|
|========+++++ [SLOT MANAGEMENT FRAMEWORK]
|
|-- sltsrch.pas  (Slot searching routines)
|-- slotutil.pas (Slot utilities helper routines)
|
|========+++++ [INTERRUPT HANDLING FRAMEWORK]
|
|-- intr.pas     (Interrupt handling manager)
|
|========+++++ [COMMUNICATION FRAMEWORK]
|
|-- rs232.pas    (RS232 BIOS function call implementation)
|-- sockdefs.pas (New definition types and constants to support the abstract 
|                 socket communication layer)
|-- socket.pas   (Implementation of the abstract presentation layer, based on
|                 Berkeley/POSIX sockets, and used to perform communication 
|                 throught any existing communication cards with driver support 
|                 built to work with this abstraction)
|
|========+++++ [COMMUNICATION DRIVERS - For the socket layer support]
|
|-- optodrv.pas  (OptoNet/OptoWifi low level common I/O board routines)
|-- optonet.pas  (Driver implementation for OPTONET multi-card(RS232/SD/Network)
|                 Details about this board can be found here:
|                 http://optotech.net.br/fzanoto/msx.htm)
|
|========+++++ [UNAPI FRAMEWORK]
|
|-- unapi.pas    (UNAPI base discovery specification implementation)
|-- unapinfo.pas (UNAPI base information gathering routines)
|-- unapitcp.pas (UNAPI TCP/IP, UDP RAW datagram, ICMP and hostname resolutions
|                 routines)
|-- utcpstat.pas (UNAPI TCP/IP capabilities and status routines)
|-- ramhelp.pas  (UNAPI RAM Helper routines)
|
|========+++++ [MASS STORAGE DRIVERS]
|
|--mflshrom.pas  (MegaFlashROM (AM29F040B chipset) R/W routines)
|
|========+++++ [SOUND CHIP DRIVERS]
|
|-- ay8910.pas   (AY8910-PSG driver implementation)
|-- ym2413-i.pas (AY2413-FM driver initializing routines)
|-- ym2413.pas   (YM2413-FM driver implementation)
|-- ym2151-i.pas (YM2151-SFG driver initializing routines)
|-- ym2151.pas   (YM2151-SFG driver implementation)
|-- y8950-i.pas  (Y8950-Philips music module driver implementation)
|-- y8950.pas    (Y8950-Philips music module driver implementation)
|-- scc-i.pas    (K051649-SCC driver initializing routines)
|-- scc.pas      (K051649-SCC driver implementation)
|-- opl4-i.pas   (YMF278B-OPL4 driver initializing routines)
|-- opl4.pas     (YMF278B-OPL4 driver implementation)
|-- sndtypes.pas (Sound chips handling new types definitions)
|-- sndchips.pas (Sound chips management routines)
|-- sndstart.pas (Sound chip engine start routines)
|-- sndstop.pas  (Sound chip engine stop routines)
|
|========+++++ [VGM PLAYER FRAMEWORK]
|
|-- vgmtypes.pas (VGM format structures definitions)
|-- vgmclock.pas (VGM clock structures definitions)
|-- vgmgd3.pas   (VGM GD3 tags support)
|-- vgmopt.pas   (VGM optional header fields handling)
|-- vgmfile.pas  (VGM file format I/O handling)
|-- vgmplay.pas  (VGM player functions)
|-- vgmmem.pas   (VGM memory management)
|
|========+++++ [IDE SUNRISE-LIKE FRAMEWORK]
|
|-- sunatapi.pas (IDE sunrise-like Framework. ATAPI functions)
|-- sunio.pas    (IDE sunrise-like Framework. Low level I/O functions)
|-- suntypes.pas (IDE sunrise-like Framework. Types definition to all modules)
|-- sunwrksp.pas (IDE sunrise-like Framework. IDE memory workspace management)
|
|========+++++ [USER INTERFACE AND OPTIMIZED CONSOLE MODULES]
|
|-- conio.pas    (Console functions optimized for MSX)
|-- twindow.pas  (Text user interface widgets implementation - Window mangmt)
|-- ttext.pas    (Text user interface widgets implementation - Text mangmt)
|-- tmenu.pas    (Text user interface widgets implementation - Menu mangmt)
|-- tprogres.pas (Text user interface widgets implementation - Progress bar)
|-- tradio.pas   (Text user interface widgtes implementation - Radio button)
|-- txthndlr.pas (Direct I/O text handler)
|-- dvram.pas    (Direct VRAM functions for screen I/O operations)
|
|========+++++ [UNIT TEST FRAMEWORK - POPOLONY2K TEST (PTEST)
|
|-- ptest.pas     (PTEST Framework implementation for Pascal types)
|-- ptestbig.pas  (PTEST Framework for Big Int operations)
|-- pgrptest.pas  (PTEST Framework implementation. Pascal types grouping)
|-- pgrpbig.pas   (PTEST Framework implementation. Big Int grouping)
|
|======== [FRAMEWORK SAMPLE CODE]
|
|-- testload.pas (Loadable module sample code)
|-- intrtest.pas (Interrupt sample code)
|-- dostest1.pas (MSXDOS first Sample)
|-- idedump.pas  (Sample code for using the IDE sunrise-like framework)
|-- ideinfo.pas  (Sample code for using the IDE sunrise-like framework)
|-- maprtest.pas (Sample code for using Memory Mapper routines MSXDOS2
|                 EXTBIO based routines)
|-- tcpsdemo.pas (Sample code for using the UNAPI TCP/IP capabilities and
|                 status routines)
|
|======== [UNIT TESTS - POPOLONY2K TEST FRAMEWORK]
|
|-- tstbig1.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig2.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig3.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig4.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig5.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig6.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig7.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig8.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig9.pas   (Unit test based on PTEST to test Big Number operations)
|-- tstbig10.pas  (Unit test based on PTEST to test Big Number operations)
|-- tstbig11.pas  (Unit test based on PTEST to test Big Number operations)
|-- tstbig12.pas  (Unit test based on PTEST to test Big Number operations)
|-- tstbig13.pas  (Unit test based on PTEST to test Big Number operations)
|-- tstbig14.pas  (Unit test based on PTEST to test Big Number operations)
|-- tstbig15.pas  (Unit test based on PTEST to test Big Number operations)
|-- tstbig16.pas  (Unit test based on PTEST to test Big Number operations)
|
|
|=========================================================================
|=========================================================================
|
|
|======== [MSXDISK DOCTOR APPLICATION MODULES]============================
|
|========+++++ [MSX DISK DOCTOR SUITE COMMON MODULES]
|
|-- iohandle.pas (MSXDD I/O handling common structures)
|-- drvfile.pas  (MSXDD Driver implementation for file operations)
|-- drvdisk.pas  (MSXDD Driver implementation for low level disk operations)
|-- mddtypes.pas (MSXDD new data types)
|-- msxddver.pas (MSXDD version definition)
|
|========+++++ [MSXDUMP MAIN MODULE AND USER INTERFACE]
|-- uidump.pas   (User interface implementation for MSXDUMP utility)
|-- uihelp.pas   (User interface help implementation for MSXDUMP utility)
|-- dumphelp.pas (The MSXDUMP helper functions common to the modules below)
|-- msxdump.pas  (The MSXDUMP main program for operation with files)
|-- msxdumpd.pas (The MSXDUMP main program for operations with disks and IDE)
|-- msxdumph.pas (The MSXDUMP main program to show the help screen)
|
|
|=========================================================================
|=========================================================================
|
|
|======== [MANIFEST NETWORK TOOLS APPLICATION MODULES]====================
|
|========+++++ [MANIFEST NETWORK SUITE COMMON MODULES]
|
|-- mnfstver.pas (Manifest Network tools version definition)
|
|========+++++ [MANIFEST TOOLS MAIN MODULES AND USER INTERFACE]
|
|-- ftdefs.pas   (File transfer data structure definitions)
|-- fthelp.pas   (Helper functions to used by send.pas and recv.pas)
|-- send.pas     (Network tool to send files to a RECV.COM tool)
|-- recv.pas     (Network tool to receive files from SEND.COM tool)
|
|
|=========================================================================
|=========================================================================
|
|
|======== [POP!ART VGM PLAYER APPLICATION MODULES]========================
|
|========+++++ [POP!ART SOUND SUITE COMMON MODULES]
|
|-- none
|
|========+++++ [POP!ART MAIN MODULES AND USER INTERFACE]
|
|-- popvgm.pas   (Pop!Art main application executable VGM loader module)
|-- popplay.pas  (Pop!Art VGM player CHN main application module)
|
|
|=========================================================================
|=========================================================================
|
|
|======== [MASS STORAGE TOOLS MODULES]====================================
|
|========+++++ [DSK2FLSH MAIN MODULE]
|
|-- dsk2flsh.pas (Dsk2Flsh main command line application)
|
|

**RULES FOR CODING**

Some rules can be followed to build new pieces of code for the framework.


1) Is a good idea keep the Hungarian Notation for coding;
2) Keep team informed about new added modules to avoid adding redundant code;
3) Please use space filling instead tab filling and the identation space must
   be 2 spaces;


Enjoy helping.


Hinotori Team

