## Work in Progress

1. Implement multi-line variable content parsing (\) and storing; (OK)
2. Implement remark processing (variables and target execution) (#); (OK)
3. Targets implementation; (OK)
    - Targets parsing; (OK);
    - Targets processing (OK);
    - Review operation; (OK)
4. Excuting commands; (WIP)
    - Variables macro substitution; (OK)
    - Commands macro substitution (including variables); (OK)
    - Implement multi-line command parsing and executing; (OK)
    - Implement remark processing on command execution; (OK)
    - Targets macro substitution (including variables); (WIP)
    - Execution logic - When execute or not (based on makefile rules); (WIP)
    - OS Specific command calls;
        - FPC implementation; (OK)
        - MSX-DOS implementation;
5. Implement conditional statements (ifeq, ifneq);
6. Operating system environment variables access by makefile;
    - Runtime variable avaibility checking (when executing a command); (ok)
    - FPC implementation; (OK)
    - MSX-DOS implementation;
    - All environment variables are inherited by makefile scripts; (OK)
    https://www.gnu.org/software/make/manual/html_node/Environment.html#:~:text=Variables%20in%20make%20can%20come,command%20argument%2C%20overrides%20the%20environment.
7. Final tests
    - Test multiple variable set (the same variable set several times);
    - Test multiple targets and already defined targets;
8. Force identation by tab instead spaces. If make file is idented by space, force make failure.

## Wish list

1. Implement include on makefiles (check this);
2. Implement wildcard processing (eg. $(wildcard *.c));
3. Implement constants (:=);
    - Add some builtin constants
        - __ARCH__ (Default value set depending on archtecture - MSX, MACOSX, LINUX, WINDOWS); 
4. Add support to use '#' after concatenation '\' at execution step;