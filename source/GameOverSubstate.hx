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
import Achievements;

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

	var isLoathed:Bool = false;
	var loathedIntro:FlxSprite;
	var loathedLoop:FlxSprite;

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

		isLoathed = (PlayState.SONG.stage == 'loathed');
		loathedIntro = new FlxSprite();
		loathedLoop = new FlxSprite();
		
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

		if(ClientPrefs.shaders && !isLoathed)
		{
			FlxG.camera.setFilters([tvFilter]);
			camMenu.setFilters([tvFilter]);
		}

		if (!isLoathed)
		{
			camMenu.flash(FlxColor.WHITE, 3);
			regenMenu();
		}
		else
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					camMenu.flash(FlxColor.WHITE, 3);
					loathedLoop.frames = Paths.getSparrowAtlas('gameover/loathed_gameover_loop', 'secretStuff');
					loathedLoop.animation.addByPrefix('loop','loathed gameover loop loop',24,true);
					loathedLoop.setGraphicSize(Std.int(FlxG.width*1.05));
					loathedLoop.updateHitbox();
					loathedLoop.screenCenter();
					loathedLoop.x -= 20;
					loathedLoop.y -= 80;
					loathedLoop.animation.play('loop');
					loathedLoop.cameras = [camMenu];
					add(loathedLoop);
				});
			
		}

	}

	var isFollowingAlready:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var achieve:String = checkForAchievement(['awardgameover', 'awarduseful']);
		if(achieve != null) startAchievement(achieve);

		screenShader.iTime.value = [shaderTime];
		shaderTime += FlxG.elapsed;

		PlayState.instance.callOnLuas('onUpdate', [elapsed]);


		if (inMenu && !selectedSomethin && !isLoathed)
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
					if (daSelected == "Retry")
						{
							FlxG.sound.play(Paths.sound('gameover/gameOverEnd'));
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

		else if (isLoathed)
		{
			if (controls.ACCEPT)
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('gameover/gameOverEnd'));
					FlxG.sound.music.stop();
					endBullshit();
				}
		
				if (controls.BACK)
				{
					FlxG.sound.music.stop();
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxG.sound.music.stop();
			
					if (PlayState.isStoryMode)
						MusicBeatState.switchState(new BebMainMenu());
					else
						MusicBeatState.switchState(new FreeplayState());
			
					FlxG.sound.playMusic(Paths.music('bebmenu'));
				}
		}


		if (PlayState.SONG.stage == 'confusion' && !playingDeathSound && !FlxG.sound.music.playing && !selectedSomethin)
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
			else if (!FlxG.sound.music.playing && !selectedSomethin)
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
		if (!isLoathed)
		{
			FlxG.sound.playMusic(Paths.music('Game_Over_Start'), volume, false);
			FlxG.sound.music.onComplete = function()
				{
					FlxG.sound.playMusic(Paths.music('Game_Over_Loop'), volume, true);
				}
		}
		else
		{
			FlxG.sound.playMusic(Paths.music('altgameOver'), volume, false);
			FlxG.sound.music.onComplete = function()
				{
					FlxG.sound.playMusic(Paths.music('altgameOver_loop'), volume, true);
				}
		}
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			//FlxG.sound.play(Paths.music(endSoundName));
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

	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) 
	{
		achievementObj = new AchievementObject(achieve, camMenu);
		if (PlayState.oreoWindow) achievementObj.x += 100;
		achievementObj.scrollFactor.set(0.9);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}

	function achievementEnd():Void
	{
		achievementObj = null;
	}

	private function checkForAchievement(achievesToCheck:Array<String> = null):String
		{
			for (i in 0...achievesToCheck.length) {
				var achievementName:String = achievesToCheck[i];
				if(!Achievements.isAchievementUnlocked(achievementName)) {
					var unlock:Bool = false;
					
					switch(achievementName)
					{
						case 'awardgameover':
							unlock = true;
						case 'awarduseful':
							var check:Int = 0;
							for(i in 0...Achievements.achievementsStuff.length-3)
							{
								if(Achievements.isAchievementUnlocked(Achievements.achievementsStuff[i][2]))
								{
									check++;
								}
							}
							if(check >= Achievements.achievementsStuff.length-3)
							{
								unlock = true;
							}
					}
	
					if(unlock) {
						Achievements.unlockAchievement(achievementName);
						return achievementName;
					}
				}
			}
			return null;
		}
}
