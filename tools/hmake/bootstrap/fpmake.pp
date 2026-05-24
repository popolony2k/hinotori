(*<fpmake.pp>
 * FPC-native bootstrap for hmake using fpmake — REFERENCE ONLY.
 *
 * fpmake is designed for multi-package FPC library ecosystems where every
 * package (including RTL) is registered in a shared fpmkinst/ directory.
 * That registration is present in FPC source builds but is typically
 * incomplete in package-manager installs (MacPorts, apt, Homebrew).
 *
 * For a standalone program like hmake, fpmake adds more infrastructure
 * than it solves.  Use build.sh, build.bat, or GNUmakefile instead.
 *
 * If you do have a complete fpmake-enabled FPC installation the canonical
 * invocation would be:
 *
 *   fpc tools/hmake/bootstrap/fpmake.pp
 *   ./tools/hmake/bootstrap/fpmake build \
 *       --globalunitdir=<fpc-install-prefix>     (e.g. /usr/lib/fpc/3.x.x)
 *   ./tools/hmake/bootstrap/fpmake clean \
 *       --globalunitdir=<fpc-install-prefix>
 *
 * CopyLeft (c) 1995-2024 by PopolonY2k.
 * CopyLeft (c) since 2024 by Hinotori Team.
 *)

program fpmake;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils,
  fpmkunit;

const
  cOutDir  = 'build';
  cSrcDir  = 'tools/hmake/src/main/fpc';

var
  pkg : TPackage;
  tgt : TTarget;

begin
  with Installer do
  begin
    pkg         := AddPackage( 'hmake' );
    pkg.Version := '1.0.0';

    (* pkg.Options is a TStringList — add FPC compiler flags directly. *)
    pkg.Options.Add( '-FE' + cOutDir );
    pkg.Options.Add( '-g'  );
    pkg.Options.Add( '-gw' );

    (* fpmake resolves program sources as <pkg.Directory>/<tgt.Directory>/<name>.pas *)
    pkg.Directory := IncludeTrailingPathDelimiter( GetCurrentDir );
    tgt           := pkg.Targets.AddProgram( 'hmake' );
    tgt.Directory := cSrcDir;

    Run;
  end;
end.
