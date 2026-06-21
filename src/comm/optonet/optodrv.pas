(*<optodrv.pas>
 * Low level network implementation driver model for OPTO-TECH compliant cards
 * Network/RS232/SD-Card and ESP8266 WIFI Card for MSX platform.
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

(*
 * This module depends on folowing include files (respect the order):
 * - /system/systypes.pas;
 * - /timer/sleep.pas;
 *)

(*
 * Internal addresses and commands used by all OptoNet compatible cards.
 * (J) means JIFFY;
 *)
const
           { Serial communication commands config }
           ctCMDUARTInit1200      = 1;    { Init UART 1200 baud rate        }
           ctCMDUARTInit2400      = 2;    { Init UART 2400 baud rate        }
           ctCMDUARTInit4800      = 4;    { Init UART 4800 baud rate        }
           ctCMDUARTInit9600      = 9;    { Init UART 9600 baud rate        }
           ctCMDUARTInit19200     = 19;   { Init UART 19200 baud rate       }
           ctCMDUARTInit38400     = 38;   { Init UART 38400 baud rate       }
           ctCMDUARTInit57600     = 57;   { Init UART 57600 baud rate       }
           ctCMDUARTInit115200    = 115;  { Init UART 115200 baud rate      }
           ctCMDUARTInit256000    = 250;  { Init UART 256000 baud rate      }

           { Board state commands }
           ctCMDRequestBufferSize = 0;    { Get the buffer size             }
           ctCMDClearBuffers      = 20;   { Clear all buffers               }
           ctCMDResetToDefault    = 40;   { Reset to default (store/reset)  }
           ctCMDResetBoard        = 43;   { Reset board                     }
           ctCMDSendSerialPacket  = 55;   { Send a packet over serial/flush }

           { I/O command/data board ports }
           ctCommandPort          = $06;  { Card command port }
           ctDataPort             = $07;  { Card data port }

           { Time wait for I/O port communication with Opto card boards }
           ctIOPortWait           = $01;  { I/O port wait (J)               }
           ctCommandPortWait      = $01;  { Command port wait (J)           }

(*
 * Driver card operation return codes.
 *)
type  TOptoCardResult = ( OptoCardSuccess,      { OptoCard I/O result codes }
                          OptoCardError,
                          OptoCardTimeoutReached,
                          OptoCardNotInitialized,
                          OptoCardNotConnected,
                          OptoCardInvalidPacket,
                          OptoCardBufferOverflow,
                          OptoCardNotImplemented );

(* Low level board functions. Don't use this directly. *)

(**
  * Write one byte to the specified port.
  * @param nPort The port to send the data;
  * @param nData The Data to send over the port;
  *)
procedure __OptoWritePort( nPort : integer; nData : byte );
begin
  Port[nPort] := nData;
  Sleep( ctIOPortWait );
end;

(**
  * Read a information from OPTONET port;
  * @param nPort The port to read;
  *)
function __OptoReadPort( nPort : integer ) : byte;
begin
  __OptoReadPort := Port[nPort];
  Sleep( ctIOPortWait );
end;

(**
  * Reset the network card.
  * @param nPort The COMMAND port to write command data;
  *)
procedure __OptoResetBoard( nPort : integer );
begin
  __OptoWritePort( nPort, ctCMDResetBoard );
end;

(**
  * Clear the network card buffers.
  * @param nPort The COMMAND port to write command data;
  *)
procedure __OptoClearBuffers( nPort : integer );
begin
  __OptoWritePort( nPort, ctCMDClearBuffers );
end;
