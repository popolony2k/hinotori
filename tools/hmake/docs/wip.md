Work in Progress

1. Implement multi-line variable content parsing (\) and storing; (WIP)
    - Macro substitution on variables;
2. Targets implementation; 
3. Variable reference (macro substitution or linked list item reference ??) through $(var_name) on labels or another variable;
4. Implement wildcard processing (eg. $(wildcard *.c));
5. Implement remark processing (#);
6. Operating system environament variable access by makefile; 
    - All environment variables are inherited by makefile scripts;
    https://www.gnu.org/software/make/manual/html_node/Environment.html#:~:text=Variables%20in%20make%20can%20come,command%20argument%2C%20overrides%20the%20environment.
7. Implement include on makefiles (check this);
8. Excuting commands;