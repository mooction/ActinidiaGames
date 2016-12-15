# ActinidiaGames

## What's this

These are products made by [Actinidia](https://github.com/mooction/Actinidia).

## How to play

**Windows**

* For example, if you want to play *rpg*, rename `res-rpg` with `res` 
* Execute `DirectMode.bat` to play.

**Android**

* Download [ActinidiaOnAndroid](http://moooc.cc/actinidia.apk) and install
* Provide SD Card access permission
* Copy games here or download [ActinidiaGames](http://moooc.cc/ActinidiaGames.zip) and extract folders to `sdcard/ActinidiaGames`
* Launch ActinidiaOnAndroid and choose a game.

Snapshots:
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev1.png)
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev2.png)
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev3.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-1.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-2.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-3.png)

## How to build games

* Edit scripts in `res\lua\`, do not modify `main.lua` and `core.lua`.
* Use `luac.exe` to check syntax.
* Use `ActinidiaMapEditor.exe` to build tile maps.
* Use `IMGLinker` to put images together.

> *ActinidiaMapEditor* load images in `res\scene`.

## How to publish

* Drag `res` folder onto `APacker.exe`
* Pack `ActinidiaGo.exe`, `bass.dll`, `res.pak`, `res.dat`
* Share with others
