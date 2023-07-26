package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.FlxCamera;
import flixel.effects.FlxFlicker;
import openfl.filters.ShaderFilter;

class GameOverSubstate extends MusicBeatSubstate
{
	var updateCamera:Bool = false;
	var playingDeathSound:Bool = false;

	var stageSuffix:String = "";

	public static var characterName:String = 'bf-dead';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	var inMenu:Bool = false;
	var menuItems:Array<String> = ['Retry'];
	var curSelected:Int = 0;
	var camMenu:FlxCamera;
	var selectedSomethin:Bool = false;
	var tweening:Bool = false;
	var gameOverSprite:FlxSprite;
	var grpMenuShit:FlxTypedGroup<AlphaBetter>;

	
	var tvFilter:ShaderFilter;
	var screenShader:Screen = new Screen();
	var shaderTime:Float = 0;

	public static var instance:GameOverSubstate;

	public static function resetVariables() {
		characterName = 'bf-dead';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	override function create()
	{
		instance = this;
		PlayState.instance.callOnLuas('onGameOverStart', []);

		super.create();
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();
		
		tvFilter = new ShaderFilter(screenShader);
		screenShader.noiseIntensity.value = [0.75];

		if(!ClientPrefs.firstTime) menuItems.push('Quit');

		PlayState.instance.setOnLuas('inGameOver', true);

		Conductor.songPosition = 0;


		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);



		grpMenuShit = new FlxTypedGroup<AlphaBetter>();
		add(grpMenuShit);

		camMenu = new FlxCamera();
		camMenu.bgColor.alpha = 0;

		FlxG.cameras.add(camMenu);

		FlxG.camera.setFilters([tvFilter]);
		camMenu.setFilters([tvFilter]);

		regenMenu();

	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		screenShader.iTime.value = [shaderTime];
		shaderTime += FlxG.elapsed;

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);


		if (inMenu && !selectedSomethin)
			{
				if (controls.UI_UP_P)
					{
						changeSelection(-1);
					}
					if (controls.UI_DOWN_P)
					{
						changeSelection(1);
					}
	
				if (controls.ACCEPT)
				{
					selectedSomethin = true;
					var daSelected:String = menuItems[curSelected];
					if (daSelected == "continue")
						{
							FlxG.sound.play(Paths.music(endSoundName));
							FlxG.sound.music.stop();
						}
					else
						{
							FlxG.sound.play(Paths.sound('cancelMenu'));
							FlxG.sound.music.stop();
						}
					FlxFlicker.flicker(grpMenuShit.members[curSelected], 0.6, 0.05, true, false, function(flick:FlxFlicker)
						{
							switch (daSelected)
							{
								case "Retry":
									endBullshit();
								case "Quit":
									FlxG.sound.music.stop();
									PlayState.deathCounter = 0;
									PlayState.seenCutscene = false;
			
									if (PlayState.isStoryMode)
										MusicBeatState.switchState(new BebMainMenu());
									else
										MusicBeatState.switchState(new FreeplayState());
			
									FlxG.sound.playMusic(Paths.music('bebmenu'));
									PlayState.instance.callOnLuas('onGameOverConfirm', [false]);
							}
						});
					
				}
				if (controls.BACK)
					{
						curSelected = menuItems.length - 1;
						changeSelection();
					}
			}


		if (PlayState.SONG.stage == 'confusion' && !playingDeathSound && !FlxG.sound.music.playing)
			{
				playingDeathSound = true;
				coolStartDeath(0.2);
				
				var exclude:Array<Int> = [];
				//if(!ClientPrefs.cursing) exclude = [1, 3, 8, 13, 17, 21];

				FlxG.sound.play(Paths.sound('cnd/gameover/confusion_gameover_' + FlxG.random.int(1, 6, exclude), 'menu'), 1, false, null, true, function() {
					if(!isEnding)
					{
						FlxG.sound.music.fadeIn(0.2, 1, 4);
					}
				});
			}
			else if (!FlxG.sound.music.playing)
			{
				coolStartDeath();
			}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		PlayState.instance.callOnLuas('onUpdatePost', [elapsed]);
	}

	function changeSelection(change:Int = 0):Void
		{
			curSelected += change;
	
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			if (curSelected >= menuItems.length)
				curSelected = 0;
	
			var bullShit:Int = 0;
	
			for (item in grpMenuShit.members)
			{
				item.alpha = 0.6;
	
				if (item.ID == curSelected)
				{
					item.alpha = 1;
				}
			}

		}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new AlphaBetter(0, 75 * i + FlxG.height/2 + 25, 0, menuItems[i], 48, false);
			item.alpha = 0;
			item.ID = i;
			item.cameras = [camMenu];
			item.screenCenter(X);
			grpMenuShit.add(item);

		}

		gameOverSprite = new FlxSprite().loadGraphic(Paths.image('game_over', 'menu'));
		gameOverSprite.setGraphicSize(Std.int(gameOverSprite.width/4));
		gameOverSprite.updateHitbox();
		gameOverSprite.screenCenter(X);
		gameOverSprite.y = 100;
		gameOverSprite.alpha = 0;
		gameOverSprite.cameras = [camMenu];
		add(gameOverSprite);

		curSelected = 0;

		setMenu();
	}

	function setMenu()
		{
			tweening = true;
			for (item in grpMenuShit)
				{
					if (item.ID == curSelected)
						FlxTween.tween(item, {alpha: 1}, 1, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
								{
									inMenu = true;
									changeSelection();
								}
						});
					else
						FlxTween.tween(item, {alpha: 0.6}, 1, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
								{

								}
						});
				}

					FlxTween.tween(gameOverSprite, {alpha: 1}, 1, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
							{

							}
					});
		}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			PlayState.instance.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
