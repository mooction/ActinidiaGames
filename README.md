# ActinidiaGames

## What's this

These are products made by [Actinidia](https://github.com/mooction/Actinidia).

## How to play

* For example, if you want to play *rpg*, rename `res-rpg` with `res` 
* Execute `DirectMode.bat` to play.

Snapshots:
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev1.png)
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev2.png)
* [RPG](http://7nas1f.com1.z0.glb.clouddn.com/actinidia_prev3.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-1.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-2.png)
* [FlappyBird](http://7nas1f.com1.z0.glb.clouddn.com/flappybird-3.png)

## How to build games

* Edit scripts in `res\lua\`, do not modify `main.lua` and `core.lua`.
* Using `luac.exe` to check syntax, using `ActinidiaMapEditor.exe` to build tile maps.

> *ActinidiaMapEditor* load images in `res\scene`.

## How to publish

* Drag `res` folder onto `APacker.exe`
* Pack `ActinidiaGo.exe`, `bass.dll`, `res.pak`, `res.dat`
* Share with others
