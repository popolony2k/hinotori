(*<mappdemo.pas>
 *  
 * Copyright 2024 Ricardo Jurczyk Pinheiro <ricardojpinheiro@gmail.com>
 * CopyLeft (c) since 2024 by Hinotori Team.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *  
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *  
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 *)

program mappdemo;

{$i ..\..\src\system\types.pas}
{$i ..\..\src\bios\msxbios.pas}
{$i ..\..\src\bios\extbio.pas}
{$i ..\..\src\mapper\maprdefs.pas}
{$i ..\..\src\mapper\maprbase.pas}
{$i ..\..\src\mapper\maprvars.pas}
{$i ..\..\src\mapper\maprrw.pas}
{$i ..\..\src\mapper\maprallc.pas}
{$i ..\..\src\mapper\maprpage.pas}

const
    Limit = 79;

type
    str8 = string[8];

var i, j, l : integer;
    StringTest: string[80] absolute $C000; { Page 3 } 
    Allright: boolean;
    buffer: array [0..Limit] of Byte absolute $8000; { Page 2 }
    Character: char;
    
    Mapper: TMapperHandle;
    PointerMapperVarTable: PMapperVarTable;
    SegmentId: byte;

function Readkey : char;
var
    bt: integer;
    qqc: byte absolute $FCA9;
begin
     readkey := chr(0);
     qqc := 1;
     Inline($f3/$fd/$2a/$c0/$fc/$DD/$21/$9F/00     
            /$CD/$1c/00/$32/bt/$fb);
     readkey := chr(bt);
     qqc := 0;
end;

Procedure MAPRBASE;
begin
    writeln('MAPRBASE:');
    writeln('Get Mapper Var Table...');
    PointerMapperVarTable := GetMapperVarTable(Mapper);
    writeln('Slot address of primary mapper: ', Mapper.nPriMapperSlotId);
    writeln('Total segments of primary mapper: ', Mapper.nTotalMapperSegs);
    writeln('Free segments of primary mapper: ', Mapper.nFreePriMapperSegs);
    writeln('Slot id of the mapper slot: ', PointerMapperVarTable^.nSlotId);
    writeln('Total number of 16Kb RAM segments: ', PointerMapperVarTable^.nTotalSegs);
    writeln('Number of free segments: ', PointerMapperVarTable^.nFreeSegs);
    writeln('Number of allocated system segments: ', PointerMapperVarTable^.nSystemSegs);
    writeln('Number of allocated user segments: ', PointerMapperVarTable^.nUserSegs);
    writeln('Free space: ', PointerMapperVarTable^.aFreeSpace[0], PointerMapperVarTable^.aFreeSpace[1], 
        PointerMapperVarTable^.aFreeSpace[2]);
end;

{
Procedure MAPRALLC_and_MAPRRW;
type
    str80 = string[80];
var
    StringTest : array [1..10] of str80;
    SegmentAllocated: array [1..10] of byte;
    i, j: byte;
    temp: str80;
    Result: byte;

begin
    writeln('MAPRALLC and MAPRRW:');
    for i := 1 to 3 do
    begin
        writeln('Allocating segment ', i, ' : ', AllocMapperSegment(Mapper, Mapper.nPriMapperSlot, UserSegment, SegmentId), 
                ' Allocated segment: ', SegmentId);
        SegmentAllocated[i] := SegmentId;
    end;
    for i := 1 to 3 do
    begin
        fillchar(temp, sizeof(temp), ' ');
        fillchar(StringTest[i], sizeof(StringTest[i]), ' ');
        for j := 1 to 40 do
            temp[j] := chr(random(85) + 41);
        move(temp, StringTest[i], sizeof(temp));
        writeln('Text: ', StringTest[i]);
    end;

    writeln('Putting all the data on a array into Mapper - or trying to.');
    PutMapperPageByAddress (Mapper, SegmentId, addr(StringTest));
    writeln('They said it was done. Hope so.');
    
    writeln('Now, we are wiping out all data from the array.');
    fillchar(StringTest, sizeof(StringTest), ' ');
    writeln('Retrieving all the data to the same array, from Mapper - fingers crossed');
    Result := GetMapperPageByAddress (Mapper, addr(StringTest));
    writeln('Result: ', Result);
    
    for i := 1 to 3 do
        writeln(' Text: ', StringTest[i]);


        move(temp, StringTest[i], sizeof(temp));
        writeln('Text: ', StringTest[i]);
        writeln('Saving it in the Mapper segment ', SegmentAllocated[i], '...');

        temp := copy(StringTest[i], 1, sizeof(StringTest[i]));
        
        for j := addr(temp) to addr(temp) + sizeof(temp) do
            AllRight := WriteMapperSegment(Mapper, SegmentAllocated[i], j, ord(temp[j - addr(temp)]));

        writeln('Writing results: ', AllRight);
    
        writeln('Releasing segment: ', FreeMapperSegment(Mapper, Mapper.nPriMapperSlot, SegmentId));

    for i := 1 to 3 do
    begin
        fillchar(temp, sizeof(temp), ' ');
        fillchar(StringTest[i], sizeof(StringTest[i]), ' ');

        writeln('Text: ', StringTest[i]);
        writeln('Reading it in the Mapper segment ', SegmentId, '... ');

        for j := addr(temp) to addr(temp) + sizeof(temp) do
            temp[j - addr(temp)] := chr(ReadMapperSegment(Mapper, SegmentAllocated[i], j));

        StringTest[i] := copy(temp, 1, sizeof(temp));
        
        writeln('Text: ', StringTest[i]);
    end;
end;
}

Procedure MAPRALLC_and_MAPRRW;
begin
    writeln('MAPRALLC and MAPRRW:');
    writeln('Allocating segment: ', AllocMapperSegment(Mapper, 
                                                       UseSpecifiedSlotOnly, 
                                                       Mapper.nPriMapperSlotId, UserSegment, 
                                                       SegmentId));
    writeln('Allocated segment: ', SegmentId);

    StringTest := 'MSX r0x a lot, dudez.';
    writeln('Text: ', StringTest);
    writeln('Saving it in the Mapper segment ', SegmentId, '...');

    for i := addr(StringTest) to addr(StringTest) + sizeof(StringTest) do
        AllRight := WriteMapperSegment(Mapper, SegmentId, i, ord(StringTest[i - addr(StringTest)]));

    writeln('Writing results: ', AllRight);
    writeln('Releasing segment: ', FreeMapperSegment(Mapper, Mapper.nPriMapperSlotId, SegmentId));

    StringTest := '';
    writeln('Text: ', StringTest);
    writeln('Reading it in the Mapper segment ', SegmentId, '... ');

    for i := addr(StringTest) to addr(StringTest) + sizeof(StringTest) do
        StringTest[i - addr(StringTest)] := chr(ReadMapperSegment(Mapper, SegmentId, i));
        
    writeln('Text: ', StringTest);
end; 


Procedure MAPRPAGE1;
begin
    writeln('MAPRPAGE:');
    writeln('Let me see which segment is allocated to which page.');
    for i := 0 to 3 do
        writeln('Page ',i, ' is allocated to segment ', GetMapperPage(Mapper, i));
end;

Procedure MAPRPAGE2;
begin
    writeln('More MAPRPAGE:');
    writeln('Putting a specified mapper segment to page 2. Let me see...');
    j := random(Mapper.nTotalMapperSegs - 3);
    writeln('It would be segment number ', j, '. So, let''s do it!');
    PutMapperPage (Mapper, j, 2);
    writeln('Generating rubbish in the Buffer array...');
    randomize;
    for i := 0 to Limit do
        Buffer[i] := (random(85) + 41);
    writeln('Printing all the rubbish in the screen...');
    for i := 0 to Limit do
        write(chr(Buffer[i]));
    writeln('Now, we''ll change to another segment...');
    l := random(Mapper.nTotalMapperSegs - 3);
    writeln('It would be segment number ', l, '. So, let''s do it!');
    PutMapperPage (Mapper, l, 2);
    writeln('Is there anything in the Buffer array now?');
    for i := 0 to Limit do
        write(chr(Buffer[i]));
    writeln;
    writeln('Putting back segment ', j);
    PutMapperPage (Mapper, j, 2);
    writeln('Hope there is the old data from Buffer array here...');
    for i := 0 to Limit do
        write(chr(Buffer[i]));
    writeln('Let me see which segment is allocated to which page.');
    for i := 0 to 3 do
        writeln('Page ',i, ' is allocated to segment ', GetMapperPage(Mapper, i));
    writeln('Ops. It seems that I should place the right segment in the right page. ');
    writeln('So, what about placing segment 1 to page 2?');
    PutMapperPage (Mapper, 1, 2);
    writeln('Ah, much better.');
end;    

function IntegerDivision (a, b: real): integer;
begin
    IntegerDivision := round(int((a - (a - (b * (a / b)))) / b));
end;

function IntegerModulo (a, b: real): integer;
begin
    IntegerModulo := round(int(a - (b * round(int(a / b)))));
end;

Function I2Hex (L: real): str8;
const
    D = 16;
var
    S : str8;
    N : integer;
    R : integer;
begin
    S := '';
    if L < 0 then
        L := (((-1 * (maxint)) + L) * -1) + 1;
    for N := 1 to sizeof(S) - 1 do
    begin
        R := IntegerModulo(L, D); { remainder }
        L := IntegerDivision(L, D); { for next dividing/digit }
        if R <= 9 then
            S := chr (R + 48) + S { 0.. 9 -> '0'..'9' (#48.. #57) }
        else
            S := chr (R + 87) + S; { 10..15 -> 'a'..'f' (#97..#102) }
    end;
    I2Hex := S; { the output in exactly 8 digits }
end; { I2Hex }

Procedure MAPRPAGE3;
begin
    writeln('Yet MAPRPAGE:');
    writeln('Now we''ll retrieve a mapper segment based on a specific address.');
    writeln('We''ll use the StringTest''s address, which is ', i2hex(addr(StringTest)));
    writeln('We know that it''s in the page ', GetMapperPageByAddress(Mapper, addr(StringTest)));
    Character := readkey;
end;

Procedure MAPRVARS;
begin
    writeln('MAPRVARS: ');
    writeln('Current page 0: ', CURSEGPAGE0);
    writeln('Current page 1: ', CURSEGPAGE1);
    writeln('Current page 2: ', CURSEGPAGE2);
    writeln('Current page 3: ', CURSEGPAGE3);
    writeln('Segment page 2: ', LASTSEGPAGE2);
    writeln('Segment page 0: ', LASTSEGPAGE0);
    Character := readkey;
end;

BEGIN
    Character := ' ';
    writeln('Init Mapper? ', InitMapper(Mapper));
    while (Character <> 'F') do
    begin
        clrscr;
        writeln(' Mapper routines demo program: ');
        writeln(' Choose your weapon: ');
        writeln(' 1 - MAPRBASE (read info from Mapper)');
        writeln(' 2 - MAPRALLC_and_MAPRRW (allocate, write, free and read)');
        writeln(' 3 - MAPRPAGE1 (which segment are allocated to which page)');
        writeln(' 4 - MAPRPAGE2 (uses PutMapperPage and GetMapperPage)');
        writeln(' 5 - MAPRPAGE3 (uses GetMapperPageByAddress)');
        writeln(' 6 - MAPRVARS (show somre variables)');
        writeln(' F - End.');
        Character := upcase(readkey);
        case Character of 
            '1': MAPRBASE;
            '2': MAPRALLC_and_MAPRRW; 
            '3': MAPRPAGE1;
            '4': MAPRPAGE2;
            '5': MAPRPAGE3;
            '6': MAPRVARS;
            'F': exit;
        end;
        Character := readkey;
    end;
END.

