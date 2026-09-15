# hmake

**CopyLeft (c) 1995-2024 by PopolonY2k**  
**CopyLeft (c) since 2024 by Hinotori Team**

`hmake` is a GNU make-compatible build tool written entirely in Pascal.
Its main goal is to let Hinotori builds run natively on **MSX-DOS** itself
(compiled with Turbo Pascal 3.3f), without depending on a host-side GNU Make
installation — but hmake is a general-purpose build tool, not tied to Hinotori
or to MSX. Compiled with **Free Pascal (FPC)** for a modern host (Linux/macOS/
Windows), the same parser and executor drive any project's makefiles on that
host, not only Hinotori's — see the built-in `MACHINE`/`ARCH` [variables](#variables),
which reflect whatever host hmake was actually compiled for.

The FPC (host) build is the primary implementation for development purposes. The
MSX-DOS port shares the same parser and executor — only the OS-specific layer differs.

## Contents

- [Features](#features)
- [Command-line usage](#command-line-usage)
- [Makefile syntax](#makefile-syntax)
  - [Variables](#variables)
  - [Targets and prerequisites](#targets-and-prerequisites)
  - [Commands](#commands)
  - [Pattern rules](#pattern-rules)
  - [Automatic variables](#automatic-variables)
  - [PHONY targets](#phony-targets)
  - [Wildcard expansion](#wildcard-expansion)
  - [Environment variables](#environment-variables)
- [Building hmake](#building-hmake)
  - [Quick build (VSCode)](#quick-build-vscode)
  - [Bootstrap scripts](#bootstrap-scripts)
- [Source layout](#source-layout)
- [Engine architecture](#engine-architecture)
- [Implementation status](#implementation-status)

---

## Features

- GNU make-compatible makefile parser (variables, targets, prerequisites, commands)
- Multi-line values and commands via `\` continuation
- Comment stripping (`#`) in variables, targets, and commands
- Multiple targets on a single rule line (`tgt1 tgt2: prereq`)
- Chained prerequisite execution — depth-first, mirrors GNU make behaviour
- File-timestamp target checking — skips up-to-date targets automatically
- `.PHONY` target support
- Pattern rules (`%.o: %.c`) with stem capture
- Automatic variables: `$@`, `$<`, `$^`, `$+`, `$*`, `$?` and their `D`/`F` (directory/file) variants
- `$(wildcard <glob>)` expansion — zero matches is not an error
- `$(VAR)` variable expansion with OS environment fallback
- Built-in `$(MACHINE)`/`$(ARCH)` variables — default host/architecture info, overridable like any other variable
- Variable override — later assignments win (GNU make semantics)
- Duplicate target detection with a descriptive error message
- Debug mode (`-d`) — prints all variables, targets, and execution steps
- Silent mode (`-s`) — suppresses command output

---

## Command-line usage

```text
hmake [-h] [-d] [-s] [-f <makefile>] [target ...]
```

| Flag | Description |
| --- | --- |
| `-h` | Print help and exit |
| `-d` | Debug mode: print variables, targets, and every execution step |
| `-s` | Silent mode: suppress command output |
| `-f <makefile>` | Specify makefile path (default: `.\Makefile`) |
| `[target ...]` | One or more targets to build (default: first target in makefile) |

### Examples

```sh
# Build the default target using Makefile in the current directory
hmake

# Build the 'all' target from a named makefile
hmake -f tools/hmake/samples/makefile.test_compilation all

# Debug run — shows variable values, target list, and each command before execution
hmake -d -f tools/hmake/samples/makefile.test_compilation build
```

---

## Makefile syntax

### Variables

```makefile
# Simple assignment
CC = gcc
FLAGS = -Wall -ansi -pedantic

# Multi-line value (backslash continuation)
CC_FLAGS = -c        \
           -Wall     \
           -ansi     \
           -pedantic

# Wildcard expansion in a variable
SOURCES = $(wildcard *.c)
```

Variable names may contain spaces before the `=` sign; they are trimmed automatically.
A later assignment to the same name overrides all earlier ones (last-write-wins).

#### Built-in `MACHINE` / `ARCH`

hmake seeds two variables with default values before parsing a makefile.
hmake is a general-purpose build tool, not exclusively a Hinotori/MSX build
driver, so on an FPC host both values describe *that host*, not MSX:

| Variable | Meaning | Default |
| --- | --- | --- |
| `$(MACHINE)` | Build host OS | `MSX` on MSX-DOS; `LINUX` / `MACOSX` / `WINDOWS` on an FPC host |
| `$(ARCH)` | Build host CPU | `Z80` on MSX-DOS; the actual CPU hmake was compiled for (e.g. `x86_64`, `aarch64`) on an FPC host |

On MSX-DOS, `$(ARCH)` is hardcoded to `Z80`: TP3.3f only ever targets that
one CPU family, regardless of whether the MSX it runs on has a Z80 or a
turboR's R800 (R800 runs the same Z80 opcodes TP3.3f emits, just faster).
It's a placeholder for if Hinotori ever grows hand-written R800-specific
assembly (using R800's extended instruction set) that a makefile would
need to select between — no such code exists yet in `src/asm/`, so there
is currently nothing for a second value to switch on. On an FPC host,
`$(ARCH)` instead comes from FPC's `%FPCTARGETCPU%` compile-time macro, so
it always matches whatever hmake itself was actually built for.

Like any other variable, a makefile assignment overrides these defaults:

```makefile
MACHINE = CUSTOM

report:
    echo "building on $(MACHINE) / $(ARCH)"
```

### Targets and prerequisites

```makefile
# Single target with one prerequisite
main.o: main.c
    gcc -c main.c -o main.o

# Multiple targets sharing the same rule
first.c second.c: main.c
    echo "building $@"

# Target with no prerequisites
clean:
    rm -f *.o
```

### Commands

Command lines **must be indented with a TAB character**.
Space-only indentation is rejected.
Multi-line commands are joined via `\` continuation before execution.

```makefile
all: main.o
    gcc -o myapp $^
```

### Pattern rules

A `%` wildcard matches any non-empty string (the *stem*).

```makefile
# Compile every .c file into a .o file
%.o: %.c
    gcc -c $< -o $@
```

When hmake needs to build `foo.o` and finds no explicit rule, it searches for a pattern
rule whose left-hand side matches. Here `%.o` matches `foo.o` with stem `foo`, and the
prerequisite `%.c` is instantiated to `foo.c`.

### Automatic variables

| Variable | Expands to |
| --- | --- |
| `$@` | Target name |
| `$<` | First prerequisite |
| `$^` | All prerequisites (space-separated, no duplicates) |
| `$+` | All prerequisites (same as `$^`) |
| `$*` | Pattern stem (pattern rules only) |
| `$?` | Prerequisites newer than the target (space-separated subset of `$^`) |
| `$@D` / `$@F` | Directory / filename part of `$@` |
| `$<D` / `$<F` | Directory / filename part of `$<` |
| `$^D` / `$^F` | Directory / filename part of `$^` |
| `$+D` / `$+F` | Directory / filename part of `$+` |
| `$*D` / `$*F` | Directory / filename part of `$*` |
| `$?D` / `$?F` | Directory / filename part of `$?` |

`$%` (archive-member name) is recognised but expands to an empty string — not
applicable without archive-member target syntax (`lib(member.o)`), which this
implementation does not support.

### PHONY targets

Declare targets that are not real files with `.PHONY` so hmake always executes them,
regardless of whether a file with that name exists on disk.

```makefile
.PHONY: clean all

clean:
    rm -f *.o
```

### Wildcard expansion

`$(wildcard <pattern>)` expands to a space-separated list of matching filenames.
Zero matches is not an error — it expands to an empty string.

```makefile
SOURCES = $(wildcard src/*.c)
HEADERS = $(wildcard include/*.h)
```

### Environment variables

All OS environment variables are available inside a makefile as `$(VAR)`.
If a name is defined in both the makefile and the environment, the makefile definition
takes precedence.

```makefile
install_dir = $(PREFIX)/bin
```

---

## Building hmake

### Quick build (VSCode)

Open [src/main/fpc/hmake.pas](src/main/fpc/hmake.pas) in VSCode and run the default
build task (**PAS build active file**). The binary is written to `build/hmake`
(repository root).

```sh
fpc -FE<workspace>/build -g -gw tools/hmake/src/main/fpc/hmake.pas
```

### Bootstrap scripts

Use these when `hmake` does not yet exist on the host. All scripts must be run from the
**repository root**.

| Script | Command |
| --- | --- |
| [bootstrap/build.sh](bootstrap/build.sh) | `sh tools/hmake/bootstrap/build.sh` |
| [bootstrap/build.bat](bootstrap/build.bat) | `tools\hmake\bootstrap\build.bat` (Windows) |
| [bootstrap/GNUmakefile](bootstrap/GNUmakefile) | `make -f tools/hmake/bootstrap/GNUmakefile` |
| [bootstrap/build_hmake.pas](bootstrap/build_hmake.pas) | `fpc tools/hmake/bootstrap/build_hmake.pas -FEtools/hmake/bootstrap` then `tools/hmake/bootstrap/build_hmake` |
| [bootstrap/fpmake.pp](bootstrap/fpmake.pp) | Reference only — see file header for infrastructure caveats |

`build.sh` and `build.bat` are the simplest options for Unix and Windows respectively.
`GNUmakefile` adds incremental rebuilds (only re-compiles when a `.pas` source changes).
`build_hmake.pas` is a self-contained FPC program that invokes `fpc` as a subprocess —
no GNU Make or fpmake infrastructure required.

---

## Source layout

```text
tools/hmake/
  bootstrap/                     Host-side bootstrap scripts (see above)
  docs/WIP.md                    Work-in-progress checklist
  samples/
    makefile.test_compilation    C compilation simulation (pattern rules, PHONY, auto-vars, wildcard)
    makefile.test_auto_vars      Full auto-var and pattern-rule test suite
    makefile.test_errors         Error-handling test suite
    makefile.test_wildcard       $(wildcard) expansion tests
    makefile.test_final          Variable override and multi-target final tests
  src/
    main/fpc/hmake.pas           FPC entry point (host)
    main/msx/hmake.pas           MSX-DOS entry point
    main/hmakerun.pas            Shared runner (platform-independent)
    make/
      mktypes.pas                Core types: TIdentifierType, TTarget, TMakeHandle
      mkutils.pas                Init, destroy, progress spinner, debug print
      mkfile.pas                 MkOpen / MkClose — file I/O wrapper
      mkbuild.pas                Makefile parser (MkBuild)
      mkhelper.pas               Identifier lookup, type detection, variable/pattern expansion
      mkexec.pas                 Target executor (MkExecute, __ExecTarget, __ReplaceAutoVars)
      fpc/mkoscall.pas           FPC OS layer: MkExecCommand, MkGetEnv, MkCheckTarget, MkWildcard
      msx/mkoscall.pas           MSX-DOS OS layer: MkGetEnv/MkCheckTarget/MkWildcard implemented, MkExecCommand stub
```

---

## Engine architecture

Parsing (`MkBuild`) and execution (`MkExecute`) are separate phases.

**Parse phase** builds three linked lists inside `TMakeHandle`:

- `variableList` — `TIdentifierPair` records (name + value)
- `targetList` — `TTarget` records, each holding `targetNameList`, `pPreReqList`, `commandList`
- `pDefaultTarget` — pointer to the first parsed target (GNU make default-target rule)

**Execute phase** (`MkExecute`):

1. Resolves the requested targets (or falls back to the default target)
2. Locates `.PHONY` and builds the PHONY set
3. Calls `__ExecTarget`, which walks prerequisites depth-first — via an
   explicit heap-allocated frame stack rather than native recursion (see
   below), so a deep prerequisite chain costs heap, not call-stack depth
4. Checks up-to-date status via `MkCheckTarget` (file timestamps; directories are excluded)
5. Expands `$(VAR)` via `MkReplaceReferences` (makefile variables → OS env fallback)
6. Expands automatic variables via `__ReplaceAutoVars` (`$@`, `$<`, `$^`, `$?`, …)
7. Runs each command via `MkExecCommand` (platform-specific)

**Why not native recursion:** each recursive call to `__ExecTarget` used to
carry a `TIdentifierPair` (81+256 bytes) plus several more short strings on
the call stack — on MSX/TP3.3f, whose stack is only a few KB, as few as 3-4
levels of ordinary prerequisite chaining could exhaust it. `__ExecTarget`
now pushes/pops `TExecFrame` records (`New`/`Dispose`, chained via `pPrev`)
driven by a `phase` state machine (`xpInit → xpOuterTop → xpInnerTop ⇄
xpInnerAfterChild → xpAfterInner → xpCleanup`) instead of calling itself.
Verified behavior-identical to the previous recursive version by diffing
hmake's output across all `tools/hmake/samples` makefiles.

**Pattern-rule matching** tries an exact target lookup first (`MkFindTarget`); if that
fails it searches for a matching pattern target (`MkFindPatternTarget`). On a match the
stem is captured, prerequisites are instantiated (`__InstantiatePreReqList`), and
automatic variables receive concrete names rather than raw `%`-patterns.

---

## Implementation status

### Implemented

- Multi-line values and commands (`\` continuation)
- Comment stripping (`#`) in variable, target, and command lines
- Multiple targets on one rule line
- PHONY target support
- Chained prerequisite execution (depth-first)
- `$(VAR)` expansion with OS environment fallback
- Multi-line command joining before execution
- File-timestamp target checking (`MkCheckTarget`) — excludes directories, correct timestamp ordering
- Automatic variables `$@`, `$<`, `$^`, `$+`, `$*`, `$?`
- Directory/file suffix variants `$@D`/`$@F`, `$<D`/`$<F`, `$^D`/`$^F`, `$+D`/`$+F`, `$*D`/`$*F`, `$?D`/`$?F`
- TAB-indentation enforcement
- Pattern rules (`%.o: %.c`) — `MkMatchPattern`, `MkFindPatternTarget`, `__InstantiatePreReqList`
- `$(wildcard <glob>)` expansion — zero matches = empty string
- Variable override — last assignment wins (GNU make semantics)
- Duplicate target detection with descriptive error
- Built-in `$(MACHINE)`/`$(ARCH)` variables — seeded by `MkInit`, overridable like any other variable; both describe the actual build host (`MSX`/`Z80` hardcoded on MSX-DOS; `LINUX`/`MACOSX`/`WINDOWS` and the real host CPU via `%FPCTARGETCPU%` on an FPC host)
- `__ExecTarget` target-execution engine converted from native recursion to an explicit heap-allocated frame stack (`TExecFrame`, `New`/`Dispose`, chained via `pPrev`) — avoids exhausting MSX/TP3.3f's few-KB call stack on deep prerequisite chains; verified behavior-identical to the old recursive version
- MSX-DOS OS layer — `MkGetEnv` (`src/dos/envvars.pas`), `MkCheckTarget` and `MkWildcard` (`src/dos/dos2find.pas`, wrapping BDOS `_FFIRST`/`_FNEXT`). Implemented on branch `hmake_msx_dos_oscall`, not yet merged to `main` — **not yet built or run on real MSX-DOS2 hardware**

### Not yet implemented

- `$%` (archive-member name) — stubbed to empty string; not applicable without archive-member target syntax (`lib(member.o)`), which this implementation does not support
- MSX-DOS `MkExecCommand` — stub only. MSX-DOS2 has no MS-DOS-style EXEC call; running an external program means resolving it via PATH, loading it at 0100h, and `CALL`ing it directly (`_FORK`/`_JOIN` only isolate file handles around that). Needs real-hardware validation before implementing

### Wish list

- `include` directive
- `:=` immediate (non-recursive) assignment
- `ifeq` / `ifneq` conditional statements
- `${var}` brace-style variable expansion
- Tab-only indentation enforcement (reject space-indented commands with a hard error)
