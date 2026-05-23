# Hinotori Library — Claude Code Context

CopyLeft (c) 1995-2024 by PopolonY2k. CopyLeft (c) since 2024 by Hinotori Team. License: GPLv3.

Hinotori is a Pascal library for **MSX retro computers**, rebranded from the PopolonY2k Framework. It includes hardware-abstraction modules written in **Turbo Pascal 3.3f** (primary target) and a host-side build tool (`hmake`) compiled with **Free Pascal (FPC)**.

---

## Repository Structure

```
src/               MSX Pascal library (TP3.3f compatible)
  asm/             Z80 assembly routines (mapper, math, sound chips, system)
  bios/            MSX BIOS interfaces (console, PSG, VDP, tape, init, misc)
  bit/             Bitwise operations
  callproc/        Function pointers and longjmp/setjmp
  collectn/        Linked list (lnkdlist.pas)
  comm/            RS232 and OptoNet drivers
  console/         CONIO and direct VRAM text I/O
  dos/             MSX-DOS 1/2, Nextor, error codes, file I/O, env vars
  dynlib/          Loadable dynamic library support
  flash/           Flash ROM driver (Mega Flash ROM SCC+)
  mapper/          MSX memory mapper allocation and paging
  math/            Fixed-point, 16/32-bit, bigint math
  memory/          Memory types, data buffer, platform pointer layers
    fpc/           FPC-specific pointer implementation
    msx/           MSX-specific pointer implementation
  ptest/           Pascal performance tests
  slot/            Slot search and utility
  sndchips/        Sound chip drivers: AY8910, SCC, OPL4, Y8950, YM2151, YM2413
  socket/          Socket definitions (UNAPI)
  sunrise/         Sunrise IDE (ATAPI) interface
  system/          Core types, system vars, hooks, interrupt, sysvars
  timer/           Sleep and wait routines
  twidgets/        Text UI widgets (menu, window, progress bar, radio, text)
  unapi/           UNAPI TCP/IP networking
  util/            String helpers (helpstr.pas, helpcnv.pas, helpchar.pas)

tools/hmake/       Custom GNU-make-like build tool (Pascal)
  src/main/fpc/    FPC entry point → hmake.pas
  src/main/msx/    MSX-DOS entry point → hmake.pas
  src/main/        Shared runner → hmakerun.pas
  src/make/        Core engine (platform-independent)
    mktypes.pas    Types: TIdentifierType, TTarget, TMakeHandle
    mkutils.pas    Init, destroy, progress, debug print
    mkfile.pas     MkOpen / MkClose
    mkbuild.pas    Makefile parser (MkBuild)
    mkhelper.pas   Identifier lookup, type detection, variable replacement
    mkexec.pas     Target executor (MkExecute)
  src/make/fpc/    FPC-specific OS calls (MkExecCommand, MkGetEnv, MkCheckTarget)
  src/make/msx/    MSX-DOS stubs (not yet implemented)
  samples/makefile Sample/test makefile
  docs/wip.md      Work-in-progress checklist

samples/           MSX sample programs (mapper, socket, sunrise, unapi, …)
test/              Unit tests (bigint × 16, memory/pointer) — branch only
build/             Compiled output (gitignored)
docs/              Project documentation and VSCode setup guide
```

---

## Language Constraints

All code under `src/` must compile cleanly with **Turbo Pascal 3.3f for MSX**:

- No object-oriented features (no classes, no inheritance, no interfaces)
- No generics
- Strings are Pascal short strings with explicit size declarations (`string[N]`)
- No `SizeOf` on dynamically-sized types
- Use `Move` for structure copies; avoid direct pointer arithmetic where possible
- All modules are `{$i include}`d into a single compilation unit — there are no separate `.TPU` files
- Include order matters; each file lists its dependencies in a header comment

FPC-specific extensions (object pascal `{$mode objfpc}{$H+}`, `uses process`, `RunCommand`, `GetEnv`, etc.) are only allowed under `tools/hmake/src/make/fpc/` and `tools/hmake/src/main/fpc/`.

---

## Building hmake (FPC — host side)

Open `tools/hmake/src/main/fpc/hmake.pas` in VSCode and use the default build task:

```
fpc -FE<workspace>/build -g -gw tools/hmake/src/main/fpc/hmake.pas
```

The binary lands in `build/hmake`. The `.vscode/tasks.json` task **"PAS build active file"** does this automatically.

To run/debug: the launch configuration **"(lldb) Debug current Pascal file"** invokes `build/hmake` with args pointing at `tools/hmake/samples/makefile`.

---

## Running hmake

```
hmake [-h] [-d] [-s] [-f <makefile>] [target ...]
  -h   Print help
  -d   Debug mode: print all variables, targets, and execution steps
  -s   Silent mode: suppress command output
  -f   Specify makefile path (default: .\Makefile)
```

Working directory during execution is `tools/hmake/samples/` (set in launch.json).

---

## hmake Engine Overview

Parsing (`MkBuild`) and execution (`MkExecute`) are separate phases.

**Parse phase** builds three linked lists inside `TMakeHandle`:
- `variableList` — `TIdentifierPair` records (name + value)
- `targetList` — `TTarget` records, each with `targetNameList`, `pPreReqList`, `commandList`
- `pDefaultTarget` — pointer to the first target (GNU make default-target rule)

**Execute phase** (`MkExecute`):
1. Resolves user-specified targets (or default target)
2. Locates `.PHONY` target and builds a PHONY list
3. Calls `__ExecTarget` recursively, walking prerequisites depth-first
4. Checks whether a target is up-to-date via `MkCheckTarget` (file timestamps)
5. Substitutes `$(VAR)` references via `MkReplaceReferences` (also falls back to OS env)
6. Runs commands via `MkExecCommand` (platform-specific)

**Variable expansion** (`MkReplaceReferences` in `mkhelper.pas`): handles `$(VAR)` only. Single-char automatic variables (`$@`, `$<`, `$^`, etc.) are not yet resolved here.

---

## Active Branch: `target_pattern_support`

### What is done
- Multi-line values and commands (`\` continuation)
- Remark stripping (`#`) in both variable and target sections
- Multiple targets on one line (`tgt1 tgt2: prereq`)
- PHONY target support
- Chained prerequisite execution (depth-first)
- `$(VAR)` and OS environment variable expansion in commands
- Multi-line command joining before execution
- FPC `MkExecCommand` / `MkGetEnv` / `MkCheckTarget` implementations

### What is in progress
- **Target-pattern rules** (`%.o: %.c %.h`) — partial; `__ReplaceMacro` in `mkexec.pas` handles `%` substitution in target/prereq names
- **Automatic variables** (`$@`, `$%`, `$<`, `$?`, `$^`, `$+`, `$*`) — infrastructure ready (`__ExecCommands` receives full `PTarget`), substitution logic not yet written
  - Directory suffix (`$@D`, `$<D`, …) — not started
  - File suffix (`$@F`, `$<F`, …) — not started
- **Wildcard expansion** `$(wildcard *.c)` — not started
- **MSX-DOS** `MkExecCommand`, `MkGetEnv`, `MkCheckTarget` — stubs only

### Wish list (future)
- `include` directive
- `:=` immediate (non-recursive) assignment
- `__ARCH__` builtin constant
- `ifeq` / `ifneq` conditionals
- `${var}` brace-style expansion
- Tab-only indentation enforcement

---

## Key Types (mktypes.pas)

| Type | Description |
|---|---|
| `TIdentifierType` | `IDENT_NONE`, `IDENT_NOP`, `IDENT_VARIABLE`, `IDENT_TARGETS`, `IDENT_COMMAND` |
| `TIdentifierPair` | `strName`, `strValue`, `identType` |
| `TTarget` | `targetNameList`, `pPreReqList`, `commandList` (all `TLinkedList`) |
| `TMakeHandle` | Central state: file handle, variable/target lists, default target, error info, debug flags |
| `TSpecialCharType` | `CHAR_PERCENT`, `CHAR_ASTERISK`, `CHAR_DOT`, `CHAR_PERCENT_DOT`, `CHAR_ASTERISK_DOT` |

---

## Coding Conventions

- Procedures and functions use Pascal-style result assignment (`FunctionName := value`)
- Nested procedures/functions are used extensively for logical grouping (prefixed `__`)
- All pointer manipulation uses `Move` for type-unsafe copies
- Linked list iteration always saves/restores `pCurrentItem` when traversal must not affect callers
- Error state is written to `handle.strLastError`; `handle.nLastLine` holds the offending line (-1 for non-parse errors)
- Progress spinner updated via `MkUpdateProgress` during parsing
