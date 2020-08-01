# ActinidiaGames

## What's this

These are games for [Actinidia](https://github.com/mooction/Actinidia).

## How to play

**Windows**

1. You can drag any resource file (`*.res`) onto the program to launch it.
2. If no resource file specified, the program will launch `game.res` under current directory.
3. If no such file in the directory, the program will launch scripts in the `game` folder.

> Install [Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 and 2019](https://aka.ms/vs/16/release/vc_redist.x64.exe) for any missing DLL.

## How to build games

* Edit scripts in `lua/`, **DO NOT** modify `main.lua` and `core.lua`.
* Use `Tools.exe` generate `*.res` file. Note that the root folder MUST be named as `game`.
* Use `ActinidiaMapEditor.exe` to build tile maps. ActinidiaMapEditor load images in `res/scene`.

> A script debugger is on the way. You can now use `lua.exe` to check syntax and use interface `SaveSetting(key,value)` to observe an variable.

## Attention

**Do NOT use non-ascii characters in file path!** That will cause some problems.

## Snapshots

* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev1.png)
* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev2.png)
* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev3.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-1.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-2.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-3.png)
