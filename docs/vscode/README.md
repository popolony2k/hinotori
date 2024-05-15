# Hinotori Library

**CopyLeft (c) 1995-2024 by PopolonY2k**  
**CopyLeft (c) since 2024 by Hinotori Team**


## Visual Studio Code json files

For compiling some samples or even using some Hinotori library packages, is needed to install [Free Pascal Compiler](https://www.freepascal.org/) and install some extensions on VSCode described below:

1. Native Debug
    Name: Native Debug
    Id: webfreak.debug
    Description: GDB, LLDB & Mago-MI Debugger support for VSCode
    Version: 0.27.0
    Publisher: WebFreak
    VS Marketplace Link: (https://marketplace.visualstudio.com/items?itemName=webfreak.debug)

2. Pascal Extension
    Name: Pascal
    Id: alefragnani.pascal
    Description: Pascal language support for Visual Studio Code
    Version: 9.8.0
    Publisher: Alessandro Fragnani
    VS Marketplace Link: (https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal)

3. Pascal Formatter
    Name: Pascal Formatter
    Id: alefragnani.pascal-formatter
    Description: Source code formatter for Pascal
    Version: 2.8.1
    Publisher: Alessandro Fragnani
    VS Marketplace Link: (https://marketplace.visualstudio.com/items?itemName=alefragnani.pascal-formatter)

After installing these plugins will be possible start debugging all programs by using the json sample files provided at this folder.

First create a .vscode folder on the Hinotori project folder and put both files below, inside this folder.

* [json/launch.json](json/launch.json)
* [json/tasks.json](json/tasks.json)

The launch.json configuration is prepared to start the current open file on your VSCode editor and start debugging it.

Hinotori Team
