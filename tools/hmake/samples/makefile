# Hinotori hmake sample makefile test cases
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

# all: $(PROJ_NAME) %.c

$(PROJ_NAME): $(OBJ)
	$(CC) -o $@ $^

%.o: %.c %.h
#	$(CC) -o $@ $< $(CC_FLAGS)
	echo "building %o"

#%.o: %.c %.h %.hxx
#	$(CC) -o $@ $< $(CC_FLAGS)
#	echo "building %o"

# %.o: %.c %.h
# 	$(CC) -o $@ $< $(CC_FLAGS)

#
# test_no_main
#
no_main.o: no_main.c
	echo "No main executed succesfully"
#
# end test_no_main
#

#
# test_main
#
# main.o: main.c $(H_SOURCE)
# 	$(CC) -o $@ $< $(CC_FLAGS)
main.o: main.c
	echo "main.o executed succesfully"

main.c:
	echo "main.c executed succesfully"

test.o: main.c
	echo "test.o executed succesfully"
#
# end test_main
#

#
# test_multiple_targets
#
first.c second.c: main.c
	echo "Test multiple targets executed succesfully"
#
# end test_multiple_targets
#

test.c: teste.x
	echo "teste.c executed succesfully"

teste.x:
	echo "teste.x executed succesfully"

clean:
	echo "cleaning"
	echo "rm -rf *.o $(PROJ_NAME) *~"
# INVALID_VAR=-c

test_no_main: no_main.o test.c
	echo "Testing test_no_main target success"

test_main: main.o test.c
	echo "Testing test_main target success"

test_no_pre:
	echo "Testing test_no_pre target success"

test_multiple_targets: first.c
	echo "Testing test_multiple_targets success"

build: test.o
	echo "Testing build target success"
