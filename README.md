# Hinotori Library

**CopyLeft (c) 1995-2024 by PopolonY2k**  
**CopyLeft (c) since 2024 by Hinotori Team**


## History
Hinotori Library is the rebrand of PopolonY2k Framework  now moved to GitHub and open to community collaboration.

The name Hinotori is a tribute to [Ozamu Tezuka's Hi no Tori unfinished manga (and movie) series](https://en.wikipedia.org/wiki/Phoenix_(manga))

![Hi no Tori (Phoenix)](/resource/hinotori_logo.jpg)


Original PopolonY2k Framework can be reached [here](https://sourceforge.net/projects/oldskooltech/) 


## Rules for contributors

The system is developed using the MCCE Turbo Pascal 3.3f for MSX machines, but 
code made with any other Pascal compilers available for MSX, like the HiSoft 
Pascal are welcome but just will be accepted on repository, if the code keeps the 
compatibility with Turbo Pascal 3.3f compiler, and following our directories 
structure.
Another restriction is about the use of non open source code GPLv3. All code are
written and released under this license, so if you're sending code based on closed
source or even using another restrict license your code won't be accepted in our main 
branch.

## Setup Hinotori 

On Hinotori base path there's a sample set environment variable batch file called **setenv.sam** that can be used as reference to create your own customized environment variable set file.
Please rename it to **setenv.bat** and edit its content like explained below: 


```console
REM Set envionment variables needed by Hinotori integration with TP33f
REM
REM 1) Change the TPPATH variable below to your TP33F compiler binaries path;
REM 2) Setup HPATH for Hinotori destination path;
REM 3) After performing all settings rename the resulting file from setenv.sam
REM    to setenv.bat;
REM
SET TPPATH=<drive:\your_tp33f_turbo_compiler_path>
SET TP3=%TPPATH%\TURBO
SET TPPATH=
SET HPATH=<drive:\your_hinotori_library_path>
SET PATH=%PATH% %HPATH%
SET HPATH=
ECHO "Hinotori environment variables set"

```

The content of variable TPPATH below:

**SET TPPATH=<drive:\your_tp33f_turbo_compiler_path>**

Must be replaced with the path of your TP33f installation, so suppose that your TP33 is located at **C:\TP33F**, so its content must replaced like below:

**SET TPPATH=C:\TP33F**

The same logic must be used to Hinitori installation path. Suppose that your Hinotori library is installed at **C:\HINOTORI**, so your variable must be set as below :

**SET HPATH=C:\HINOTORI**

After setting these variables and renaming the **setenv.sam** to **setenv.bat**, just call **setenv.bat** on DOS command prompt to setup all variables needed by hinotori project compilation.

## Compiling Hinotori Samples and tests

Compiling Hinotori samples and tests is easy. After performing all steps above, only enter the desired test or sample to compile and type **HMAKE <your_pascal_source_code.pas>**.

Eg:

**cd SAMPLES\MAPPER**
**HMAKE mappdemo.pas**


Hinotori Team
