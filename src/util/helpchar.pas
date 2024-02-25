(*<helpchar.pas>
 * Helper functions to manage char types.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This source file depends on following include files (respect the order):
 * -
 *)

Const     ctKbEsc       = $1B;         { Escape key              }
          ctKbCtrlE     = $5;          { Ctrl+E combo key        }
          ctKbCTRLS     = $13;         { Ctrl+S combo key        }
          ctKbCtrlG     = $7;          { Ctrl+G combo key        }
          ctKbCtrlA     = $1;          { Ctrl+A combo key        }
          ctKbCtrlR     = $12;         { Ctrl+R combo key        }
          ctKbBackSpace = $8;          { BackSpace key           }
          ctKbReturn    = $D;          { Return key              }
          ctKbEnter     = ctkbReturn;  { Enter key               }
          ctKbKeyUp     = $1E;         { Up arrow key            }
          ctKbKeyDown   = $1F;         { Down arrow key          }
          ctKbKeyLeft   = $1D;         { Left arrow key          }
          ctKbKeyRight  = $1C;         { Right arrow key         }
          ctKbSelect    = $18;         { Select key              }
          ctKbTab       = $9;          { Tab key                 }
          ctKbNothing   = -1;          { None                    }


(**
  * Check if a byte is a printable character,
  * @param nByte The byte to check;
  *)
Function IsChar( nByte : Byte ) : Boolean;
Begin
  If( nByte > 32 )  Then
    IsChar := True
  Else
    IsChar := False;
End;

(**
  * Retrieve a character from keyboard device.
  * This function is here to make Turbo Pascal 3
  * compatible with new Pascal versions.
  *)
Function ReadKey : Char;
Var
      chChar  : Char;

Begin
  Read( KBD, chChar );
  ReadKey := chChar;
End;
