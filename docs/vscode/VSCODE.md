# Hinotori Library — VSCode Setup

**CopyLeft (c) 1995-2024 by PopolonY2k**  
**CopyLeft (c) since 2024 by Hinotori Team**

## VSCode Extensions

To compile samples or use Hinotori library packages, you need to install
[Free Pascal Compiler](https://www.freepascal.org/) and the following VSCode
extensions:

1. **Native Debug** (`webfreak.debug`)  
   GDB, LLDB & Mago-MI Debugger support for VSCode.  
   [Install from Marketplace](https://marketplace.visualstudio.com/items?itemName=webfreak.debug)

2. **Pascal** (`alefragnani.pascal`)  
   Pascal language support for Visual Studio Code.  
   [Install from Marketplace](https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal)

3. **Pascal Formatter** (`alefragnani.pascal-formatter`)  
   Source code formatter for Pascal.  
   [Install from Marketplace](https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal-formatter)

4. **Makefile Tools** (`ms-vscode.makefile-tools`)  
   Makefile support for Visual Studio Code.  
   [Install from Marketplace](https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools)

After installing these plugins it will be possible to start debugging all
programs by using the json sample files provided in this folder.

## Setup

Create a `.vscode` folder in the Hinotori project root and copy all sample
files below into it:

* [sample/extensions.json](sample/extensions.json)
* [sample/launch.json](sample/launch.json)
* [sample/tasks.json](sample/tasks.json)

Copying `extensions.json` enables VSCode to automatically prompt you to
install all recommended extensions when the workspace is opened.

The `launch.json` configuration is prepared to build and debug the currently
open Pascal file in your VSCode editor.

Hinotori Team
