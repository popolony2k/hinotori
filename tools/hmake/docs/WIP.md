# Work in Progress

1. Implement multi-line variable content parsing (`\`) and storing; (OK)
2. Implement remark processing (variables and target execution) (#); (OK)
3. Targets implementation; (OK)
    - Targets parsing; (OK)
    - Targets processing; (OK)
    - Review operation; (OK)
4. Executing commands; (WIP)
    - Variables macro substitution; (OK)
    - Commands macro substitution (including variables); (OK)
    - Implement multi-line command parsing and executing; (OK)
    - Implement remark processing on command execution; (OK)
    - Targets macro substitution (including variables); (OK)
    - Execution logic - When execute or not (based on makefile rules); (WIP)
        - Check target processing; (WIP)
            - FPC implementation; (OK)
            - MSX-DOS; (OK)
                - Implemented via src/dos/dos2find.pas (MSXFindFirst/Next
                  wrapper around BDOS 40h/41h); (OK)
                - Not yet built or run on real MSX-DOS2 hardware; (TODO)
            - Add support to multiple prerequisites processing; (OK)
                - Add support to chain requisites execution; (OK)
                - Check errors return messages for error processing cases; (OK)
            - Add support to multiples targets on the same line
                (separated by spaces). (eg. target_1 target2 : prerequisite); (OK)
            - PHONY target support (OK);
            - Target-pattern rules implementation (%.o: %.c %.h); (OK)
                - Add automatic variables processing ($@, $<, $^, $+, $*); (OK)
                    - $? — prerequisites newer than the target; recomputed
                      in __ReplaceAutoVars against the target's real prereq
                      list (re-checked at command-execution time, so it
                      reflects prereqs' post-build mtimes); (OK)
                    - $% — archive-member name; not applicable without
                      archive-member target syntax (lib(member.o)), which
                      this implementation does not support. Stubbed to
                      empty string; (TODO, low priority — obscure/unused
                      for this project's target platform)
                    - Add directory part processing ($@D, $<D, $^D, $+D, $*D); (OK)
                    - Add file part processing ($@F, $<F, $^F, $+F, $*F); (OK)
                    - $?D, $?F implemented alongside $?; (OK)
                    - $%D, $%F stubbed to empty (depends on $%); (TODO)
                - Implement wildcard processing (eg. $(wildcard *.c)); (OK)
    - OS Specific command calls (MkExecCommand); (WIP)
        - FPC implementation; (OK)
        - MSX-DOS implementation; (TODO)
            - MSX-DOS2 has no MS-DOS-style EXEC call; running an external
              program means resolving it via PATH, loading it at 0100h, and
              CALLing it directly (FORK/JOIN only isolate file handles
              around that). Needs hardware validation before writing it;
              (TODO)
    - Target execution engine (`__ExecTarget` in mkexec.pas) converted from
      native recursion to an explicit heap-allocated frame stack; (OK)
        - Motivation: each recursive call carried a TIdentifierPair (81+256
          bytes) plus several more short strings on the native call stack —
          on MSX/TP3.3f (a few KB of stack) as few as 3-4 levels of ordinary
          prerequisite chaining could exhaust it. Frames are now
          New/Dispose'd on the heap and chained via pPrev, so recursion
          depth no longer costs native stack.
        - Verified behavior-identical against the previous recursive
          version: byte-for-byte diff of hmake's output across all
          `tools/hmake/samples` makefiles (multi-target, pattern rules,
          auto-vars, errors, wildcard, variable-override) under the FPC
          build. Not yet re-verified on real MSX-DOS2 hardware; (TODO)
    - Built-in `$(MACHINE)`/`$(ARCH)` variables; (OK)
        - Seeded by MkInit (mkutils.pas) as default entries in
          handle.variableList — a makefile assignment to either name
          overrides them (last-write-wins, same as any other variable);
          (OK)
        - MACHINE is platform-specific (ctMkMachine in each mkoscall.pas):
          MSX on MSX-DOS; LINUX/MACOSX/WINDOWS on FPC hosts via
          {$IFDEF DARWIN}/{$IFDEF WINDOWS}; (OK)
        - ARCH (ctMkArch) is hardcoded to Z80 on MSX-DOS only — TP3.3f
          always targets that one CPU family. Placeholder for MSX turboR
          R800-specific code paths once Hinotori has hand-written asm
          using R800's extended instruction set to select between (none
          exist yet in src/asm/); (TODO, low priority)
        - On FPC hosts, ARCH instead reflects the actual host CPU hmake
          was compiled for (e.g. x86_64, aarch64), via FPC's
          %FPCTARGETCPU% compile-time macro — hmake is a general-purpose
          build tool usable on any project on that host, not only
          Hinotori/MSX ones, so it must report the real host architecture
          there, not MSX's Z80; (OK)
5. Operating system environment variables access by makefile; (WIP)
    - Runtime variable availability checking (when executing a command); (OK)
    - FPC implementation; (OK)
    - MSX-DOS implementation; (OK)
        - Implemented via src/dos/envvars.pas (existing GetEnv); (OK)
        - Not yet built or run on real MSX-DOS2 hardware; (TODO)
    - All environment variables are inherited by makefile scripts; (OK)
    <https://www.gnu.org/software/make/manual/html_node/Environment.html#:~:text=Variables%20in%20make%20can%20come,command%20argument%2C%20overrides%20the%20environment>.
6. Final tests
    - Test multiple variable set (the same variable set several times); (OK)
        - Fixed MkFindIdentifier to return last match (last-write-wins); (OK)
    - Test multiple targets and already defined targets; (OK)
        - Multi-target rules ($@ per target): already covered in test_auto_vars; (OK)
        - Already-defined target produces a proper error message; (OK)

## Wish list

1. Implement include on makefiles (check this);
2. Implement constants (:=);
3. Add support to use '#' after concatenation `\` at execution step;
4. Force indentation by tab instead spaces. If make file is indented by space, force make failure. (OK)
5. Implement conditional statements (ifeq, ifneq);
6. Add support to variable referencing by using ${var_name} exactly like current $(var_name) style;
