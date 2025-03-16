# Work in Progress

1. Implement multi-line variable content parsing (\) and storing; (OK)
2. Implement remark processing (variables and target execution) (#); (OK)
3. Targets implementation; (OK)
    - Targets parsing; (OK)
    - Targets processing (OK)
    - Review operation; (OK)
4. Excuting commands; (WIP)
    - Variables macro substitution; (OK)
    - Commands macro substitution (including variables); (OK)
    - Implement multi-line command parsing and executing; (OK)
    - Implement remark processing on command execution; (OK)
    - Targets macro substitution (including variables); (OK)
    - Execution logic - When execute or not (based on makefile rules); (WIP)
        - Check target processing; (WIP)
            - FPC implementation; (OK);
            - MSX-DOS;
            - Add support to multiple prerequisites processing; (OK)
                - Add support to chain requisites execution; (OK)
                - Check errors return messages for error processing cases; (WIP)
            - Add support to multiples targets on the same line 
                (separated by spaces). (eg. target_1 target2 : prerequisite); (OK)
            - PHONY target support (OK);
            - Target-pattern rules implementation (%.o: %.c %.h);
                - Add automatic variables processing ($@, $%, $<, $?, $^, $+, $*);
                - Implement wildcard processing (eg. $(wildcard *.c));
    - OS Specific command calls; (WIP)
        - FPC implementation; (OK)
        - MSX-DOS implementation;
5. Operating system environment variables access by makefile; (WIP)
    - Runtime variable avaibility checking (when executing a command); (OK)
    - FPC implementation; (OK)
    - MSX-DOS implementation;
    - All environment variables are inherited by makefile scripts; (OK)
    <https://www.gnu.org/software/make/manual/html_node/Environment.html#:~:text=Variables%20in%20make%20can%20come,command%20argument%2C%20overrides%20the%20environment>.
6. Final tests
    - Test multiple variable set (the same variable set several times);
    - Test multiple targets and already defined targets;

## Wish list

1. Implement include on makefiles (check this);
2. Implement constants (:=);
    - Add some builtin constants
        - __ARCH__ (Default value set depending on archtecture - MSX, MACOSX, LINUX, WINDOWS);
3. Add support to use '#' after concatenation '\' at execution step;
4. Force identation by tab instead spaces. If make file is idented by space, force make failure.
5. Implement conditional statements (ifeq, ifneq);
6. Add support to variable referencing by using ${var_name} exactly like current $(var_name) style;
