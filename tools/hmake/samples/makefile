# Hinotori sample makefile for hmake
#
# CopyLeft (c) 1995-2024 by PopolonY2k.
# CopyLeft (c) since 2024 by Hinotori Team.


# Name of the project
PROJ_NAME=printy # test

# .c files
C_SOURCE=$(wildcard *.c)

# .h files
H_SOURCE=$(wildcard *.h)

# Object files (Not supported)
#OBJ=$(C_SOURCE:.c=.o)

# Compiler (spaces on variable names before assignament)
CC =gcc

# Flags for compiler (Mixed TAB and space identation)
CC_FLAGS=-c         \
		 -W         \
         -Wall      \
         -ansi      \
         -pedantic

#
# Compilation and linking
#
all: $(PROJ_NAME)

$(PROJ_NAME): $(OBJ)
	$(CC) -o $@ $^

%.o: %.c %.h
	$(CC) -o $@ $< $(CC_FLAGS)

main.o: main.c $(H_SOURCE)
	$(CC) -o $@ $< $(CC_FLAGS)

clean:
	echo "cleaning"
	echo "rm -rf *.o $(PROJ_NAME) *~"
# INVALID_VAR=-c

test: setenv.txt
#	echo "Testing project remark"
	echo "Testing project"
	echo $(PROJ_NAME) \ 
	$(CC) # \
	$(CC_FLAGS) \
	HOME ($(HOME))

# test:
# 	echo true
