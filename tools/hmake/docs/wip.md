## Work in Progress

1. Implement multi-line variable content parsing (\) and storing; (OK)
    - Variables macro substitution; (WIP - item 5)
2. Implement remark processing (#); (OK)
3. Targets implementation; (WIP)
    - Targets parsing; (OK);
    - Targets processing (OK);
    - Targets macro substitution (including variables);
    - Review operation; (WIP)
4. Excuting commands;
    - Commands macro substitution (including variables);
5. Variable reference (macro substitution or linked list item reference ??) through $(var_name) on labels or another variable;
6. Operating system environment variables access by makefile; 
    - All environment variables are inherited by makefile scripts;
    https://www.gnu.org/software/make/manual/html_node/Environment.html#:~:text=Variables%20in%20make%20can%20come,command%20argument%2C%20overrides%20the%20environment.
7. Force identation by tab instead spaces. If make file is idented by space, force make failure.

## Whish list

1. Implement include on makefiles (check this);
2. Implement wildcard processing (eg. $(wildcard *.c));
3. Implement constants (:=);