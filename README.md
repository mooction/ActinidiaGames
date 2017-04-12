# ActinidiaGames

## What's this

These are games on [Actinidia](https://github.com/mooction/Actinidia).

## How to play

**Windows**

* For example, if you want to play *rpg*, rename `res-rpg` with `res` 
* Execute `DirectMode.bat` to play.

**Android**

* Download [ActinidiaOnAndroid](http://moooc.cc/actinidia.apk) and install
* Download games with it.
* If you have built your own game, copy it to `sdcard/ActinidiaGames`
* Launch Actinidia and choose a local game. (If failed, make sure you have SDCard permission.)

Snapshots:
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev1.png)
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev2.png)
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev3.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-1.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-2.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-3.png)

## How to build games

* Edit scripts in `res\lua\`, do not modify `main.lua` and `core.lua`.
* Use `lua.exe` to check syntax.
* Use `SaveSetting(key,value)` to debug.
* Use `ActinidiaMapEditor.exe` to build tile maps.
* Use `IMGLinker` to put images together.

> *ActinidiaMapEditor* load images in `res\scene`.

## How to publish

**Windows**

* Drag `res` folder onto `APacker.exe`
* Pack `ActinidiaGo.exe`, `bass.dll`, `res.pak`, `res.dat`
* Share with others

**Android**

Please visit [](http://bbs.moooc.cc/) to submit your application. We will upload your game after verified.
