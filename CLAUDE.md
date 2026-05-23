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
  samples/makefile              Sample/test makefile
  samples/makefile.test_auto_vars  Auto-var and pattern-rule test suite
  docs/WIP.md                  Work-in-progress checklist

samples/           MSX sample programs (mapper, socket, sunrise, unapi, …)
test/              Unit tests (bigint × 16, memory/pointer) — branch only
build/             Compiled output (gitignored)
docs/              Project documentation
  vscode/VSCODE.md   VSCode setup guide (extensions, launch configs, tasks)
  vscode/sample/     Template .vscode files (extensions.json, launch.json, tasks.json)
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

To run/debug, use one of the named launch configurations in `.vscode/launch.json`:
- `(lldb) test_multiple_targets` — builds multiple targets (`-f makefile`)
- `(lldb) test_main` / `(lldb) test_no_main` — single target tests (`-f makefile`)
- `(lldb) test_auto_vars ($@)` — full auto-var + pattern-rule suite (`-f makefile.test_auto_vars`)
- `(lldb) debug all` — runs with `-d` flag across all main targets (`-f makefile`)
- `(gdb) test_multiple_targets` — Linux/GDB equivalent

All configurations set `cwd` to `tools/hmake/samples/`.

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

**Variable expansion** (`MkReplaceReferences` in `mkhelper.pas`): handles `$(VAR)` only, with OS environment fallback.

**Automatic variable expansion** (`__ReplaceAutoVars` in `mkexec.pas`): called from `__ExecCommands` after `MkReplaceReferences`. Resolves `$@` (target name), `$<` (first prereq), `$^` (all prereqs), `$+` (same as `$^`), `$*` (pattern stem). `$%`, `$?` replaced with empty string (not yet implemented). Directory/file suffix variants (`$@D`, `$@F`, etc.) not yet implemented.

**Pattern-rule matching** (`mkhelper.pas`):
- `MkMatchPattern` — tests a concrete name against a `%`-pattern; on match, returns the stem
- `MkFindPatternTarget` — scans `targetList` for a pattern target whose name matches a concrete name

**Pattern-rule execution** (`mkexec.pas`):
- `__InstantiatePreReqList` — builds a fresh prereq list with `%` replaced by the stem (used so `$<`/`$^` expand to concrete names, not raw patterns)
- `__ExecTarget` — tries exact match first (`MkFindTarget`), falls back to `MkFindPatternTarget`; passes instantiated prereq list to `__ExecCommands` for auto-var substitution

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
- Automatic variables `$@`, `$<`, `$^`, `$+`, `$*` — implemented in `__ReplaceAutoVars` (`mkexec.pas`)
- TAB-indentation enforcement: TAB-prefixed lines with existing targets are always `IDENT_COMMAND`
- **Target-pattern rules** (`%.o: %.c %.h`) — fully implemented and tested
  - `MkMatchPattern` + `MkFindPatternTarget` in `mkhelper.pas`
  - `__InstantiatePreReqList` in `mkexec.pas` — instantiates prereqs for pattern rules
  - `__ExecTarget` — exact-match first, pattern fallback second; nil-guards for missing rules
  - `$*` carries the stem; `$<`/`$^` expand to instantiated (concrete) prereq names
- `lnkdlist.pas` — fixed O(n²) insertion (`pLastItem` tail pointer), fixed cursor-mutation side effects

### What is in progress
- **Automatic variables** — `$%`, `$?` replaced with empty string; not yet implemented
- **Directory/file suffix variants** (`$@D`, `$@F`, `$<D`, `$<F`, etc.) — not started
- **Wildcard expansion** `$(wildcard *.c)` — not started
- **MSX-DOS** `MkExecCommand`, `MkGetEnv`, `MkCheckTarget` — stubs only (intentional: FPC engine must be 100% first)

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
- Linked list iteration that must not affect callers walks via raw `pFirstItem`/`pNextItem` pointers (no cursor mutation); `GetFirstLinkedListItem`/`GetNextLinkedListItem` are used only when cursor advancement is acceptable
- Error state is written to `handle.strLastError`; `handle.nLastLine` holds the offending line (-1 for non-parse errors)
- Progress spinner updated via `MkUpdateProgress` during parsing
