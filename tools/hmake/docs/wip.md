## Work in Progress

1. Implement multi-line variable content parsing (\) and storing; (OK)
2. Implement remark processing (#); (OK)
3. Targets implementation; (OK)
    - Targets parsing; (OK);
    - Targets processing (OK);
    - Review operation; (OK)
4. Excuting commands; (WIP)
    - Variables macro substitution; (WIP)
    - Targets macro substitution (including variables); (WIP)
    - Commands macro substitution (including variables); (WIP)
    - Execution logic - When execute or not; (WIP)
    - OS Specific command calls;
    - Environment variables (OS specific calls);
        - Runtime variable avaibility checking (when executing a command);
5. Operating system environment variables access by makefile; 
    - All environment variables are inherited by makefile scripts;
    https://www.gnu.org/software/make/manual/html_node/Environment.html#:~:text=Variables%20in%20make%20can%20come,command%20argument%2C%20overrides%20the%20environment.
6. Implement conditional statements (ifeq, ifneq);
7. Force identation by tab instead spaces. If make file is idented by space, force make failure.

## Whish list

1. Implement include on makefiles (check this);
2. Implement wildcard processing (eg. $(wildcard *.c));
3. Implement constants (:=);