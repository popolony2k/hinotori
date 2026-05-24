(*<build_hmake.pas>
 * Pascal bootstrap for hmake — builds hmake using FPC via the process unit.
 * This is the FPC-idiomatic alternative to a shell script: written entirely
 * in Pascal, no external tools required beyond FPC itself.
 *
 * Step 1 — compile this script once (run from the repository root):
 *   fpc tools/hmake/bootstrap/build_hmake.pas
 *
 * Step 2 — run the compiled bootstrap to build hmake:
 *   tools/hmake/bootstrap/build_hmake
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

program build_hmake;

{$mode objfpc}{$H+}

uses
  SysUtils,
  Process;

const
  cOutDir = 'build';
  cEntry  = 'tools/hmake/src/main/fpc/hmake.pas';

var
  nResult : integer;
  proc    : TProcess;
  strLine : string;

begin
  if not DirectoryExists( cOutDir ) then
    if not CreateDir( cOutDir ) then
    begin
      WriteLn( 'Error: cannot create output directory: ', cOutDir );
      Halt( 1 );
    end;

  WriteLn( 'Building hmake...' );

  proc                    := TProcess.Create( nil );
  proc.Executable         := 'fpc';
  proc.Parameters.Add( '-FE' + cOutDir );
  proc.Parameters.Add( '-g' );
  proc.Parameters.Add( '-gw' );
  proc.Parameters.Add( cEntry );
  proc.Options            := [poUsePipes, poStderrToOutput];
  proc.Execute;

  while proc.Running or ( proc.Output.NumBytesAvailable > 0 ) do
  begin
    while proc.Output.NumBytesAvailable > 0 do
    begin
      SetLength( strLine, proc.Output.NumBytesAvailable );
      proc.Output.Read( strLine[1], Length( strLine ) );
      Write( strLine );
    end;
  end;

  nResult := proc.ExitCode;
  proc.Free;

  if nResult <> 0 then
  begin
    WriteLn( 'Build failed (fpc exit code ', nResult, ').' );
    Halt( nResult );
  end;

  WriteLn( 'Done: ', cOutDir, '/hmake' );
end.
