(*<mktypes.pas>
 * Hinotori makefile basic types definition.
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 *
 * - /system/types.pas;
 * - /collectn/lnkdlist.pas;
 *)

(**
  * Wildcard type
  *)
 type TWildcardType = ( WILDCARD_PERCENT,
                        WILDCARD_ASTERISK );

(**
  * Identifier type
  *)
type TIdentifierType = ( IDENT_NONE,
                         IDENT_NOP,
                         IDENT_VARIABLE, 
                         IDENT_TARGETS, 
                         IDENT_COMMAND );

(**
  * Variable data struct.
  *)
type PIdentifierName  = ^TIdentifierName;
     TIdentifierName  = string[20];
     PIdentifierValue = ^TIdentifierValue;
     TIdentifierValue = TString;

(**
  * Identifier data structure.
  *)
type PIdentifierPair = ^TIdentifierPair;
     TIdentifierPair = record
  strName     : TIdentifierName;
  strValue    : TIdentifierValue;
  identType   : TIdentifierType;
end;

(**
  * Target data structure.
  *)
type PTarget = ^TTarget;
     TTarget = record
  targetPair    : TIdentifierPair;        { Target name/prereq.         }
  commandList   : TLinkedList;            { Command list                }
end;

(**
  * Makefile build handle used by parsing and build routines.
  *)
 type TMakeHandle = record
   bIsOpen        : boolean;              { Make file is open           }
   bDebugMode     : boolean;              { Debug mode execution        }
   hFile          : text;                 { Make file handle            }
   pDefaultTarget : PTarget;              { Pointer to default target   }
   variableList   : TLinkedList;          { Make variable list          }
   targetList     : TLinkedList;          { Make target list            }
   strLastError   : TString;              { Last processing error       }
   nLastLine      : integer;              { Last processed line         }
   nCursor        : byte;                 { Cursor position control     }
   aCursor        : array[0..3] of char;  { Cursor array char sequence  }
   chCSI          : char;                 { Control sequence introducer }
 end;
