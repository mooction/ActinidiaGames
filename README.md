# ActinidiaGames

![logo](https://raw.githubusercontent.com/mooction/Actinidia/master/Actinidia/logo.png)

## What's this

These are games for [Actinidia](https://github.com/mooction/Actinidia).

## How to play

**Windows**

1. You can drag any resource file (`*.res`) onto the program to launch it.
2. If no resource file specified, the program will launch `game.res` under current directory.
3. If no such file in the directory, the program will launch scripts in the `game` folder.

> Install [Microsoft Visual C++ Redistributable for Visual Studio 2015, 2017 and 2019](https://aka.ms/vs/16/release/vc_redist.x64.exe) for any missing DLL.

**Linux**

1. Install dependencies:

```bash
# Debian
sudo apt-get install -y libgtk-3-0 zlib1g libpng16-16 liblua5.3-0 libjpeg62-turbo
# Ubuntu
sudo apt-get install -y libgtk-3-0 zlib1g libpng16-16 liblua5.3-0 libjpeg62
```

2. Install deb package:

```bash
sudo dpkg -i actinidia_1.0.0_amd64.deb
```

3. Launch your resource pack:

```bash
actinidia ./your_game.res
```

## How to build games

* Edit scripts in `lua/`, **DO NOT** modify `main.lua` and `core.lua`.
* Use `Tools.exe` generate `*.res` file. Note that the root folder MUST be named as `game`.
* Use `ActinidiaMapEditor.exe` to build tile maps. ActinidiaMapEditor load images in `res/scene`.

> A script debugger is on the way. You can now use `lua.exe` to check syntax and use interface `SaveSetting(key,value)` to observe an variable.

## Attention

**Do NOT use non-ascii characters in file path!** That may result in any problem.

## Snapshots

* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev1.png)
* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev2.png)
* [RPG](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/actinidia_prev3.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-1.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-2.png)
* [FlappyBird](https://moooc.oss-cn-shenzhen.aliyuncs.com/blog/flappybird-3.png)
