# ActinidiaGames

## What's this

These are games for [Actinidia](https://github.com/mooction/Actinidia).

## How to play

**Windows**

You can drag any resource file (`*.res`) onto the program to launch the game. If no resource file specified, the program will run scripts in the `game.res` file of current directory. If no such file in the directory, the program will be under *direct mode* and launch scripts in the `game` folder.

Snapshots:
* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev1.png)
* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev2.png)
* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev3.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-1.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-2.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-3.png)

> Install [Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 and 2019](https://aka.ms/vs/16/release/vc_redist.x64.exe) for any missing DLL.

## How to build games

* Edit scripts in `lua/`, **DO NOT** modify `main.lua` and `core.lua`.
* Use `lua.exe` to check syntax.
* Use `SaveSetting(key,value)` to debug.
* Use `ActinidiaMapEditor.exe` to build tile maps.
* Use `Tools.exe` to put images together and build **resource pack**.

> *ActinidiaMapEditor* load images in `res/scene`.

## Attention

**Do NOT use non-ascii characters in file path!** That will cause some bugs.
