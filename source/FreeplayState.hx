package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import TabData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	static var curSelected:Int = 0;
	var curDifficulty:Int;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	var grpOptions:FlxSpriteGroup;
	var grpButtons:FlxSpriteGroup;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var colorTween:FlxTween;

	var loadedTabs:Array<TabData> = [];
	var curSongList:Array<Dynamic> = [];

	private var curButtons:Array<Dynamic> = [];
	var allowEdward:Bool = false;

	var trains:Array<String> = [
        'thomas',
		'henry',
        'james',
        'gordon',
        'edward'
    ];

	private static var edwardList:Array<Dynamic> = [
		'old-reliable'
	];

    var cursorSprite:FlxSprite;
    var cursorSprite2:FlxSprite;
	var backButton:FlxSprite;
	var cloudSprite:FlxSprite;
	var tweening:Bool;
	var allowFatass:Bool = false;
	var fatass:FlxSprite;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();

		TitleState.checkFile();
		TabData.reloadTabFiles();

		for (i in 0...TabData.tabsList.length)
			{
				var tabFile:TabData = TabData.tabsLoaded.get(TabData.tabsList[i]);
				if (i == 3 && TitleState.rwsFuckShit) tabFile.songs.push('loathed');
				loadedTabs.push(tabFile);
			}

		curSelected = -1;
		curDifficulty = ClientPrefs.difficulty;
		trace(curDifficulty);
		curSongList = [];
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

		allowEdward = Achievements.isAchievementUnlocked('awarduseful');
		allowFatass = ClientPrefs.fatassBeat;
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		cursorSprite = new FlxSprite().loadGraphic(Paths.image('ui/cursor'));
        cursorSprite2 = new FlxSprite().loadGraphic(Paths.image('ui/cursor2'));
        FlxG.mouse.visible = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("At the Sheds (Freeplay)", null);
		#end

		/*for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}*/
		WeekData.loadTheFirstEnabledMod();

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		if (!allowEdward)
			bg = new FlxSprite().loadGraphic(Paths.image('freeplay/fp_bg','menu'));
		else
			bg = new FlxSprite().loadGraphic(Paths.image('freeplay/fp_bg2','menu'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.setGraphicSize(Std.int(FlxG.width));
		trace(bg.width);
		add(bg);
		bg.screenCenter();

		backButton = new FlxSprite().loadGraphic(Paths.image('freeplay/back_button',"menu"));
		backButton.x = 10;
		backButton.setGraphicSize(Std.int(backButton.width * 0.8));
		backButton.updateHitbox();
		backButton.y = FlxG.height - backButton.height - 10;
		add(backButton);

		grpOptions = new FlxSpriteGroup();
		grpButtons = new FlxSpriteGroup();
		for (i in 0...trains.length)
			{
				if (i == trains.length - 1 && !allowEdward) break;
				var train:FlxSprite = new FlxSprite((i * 220 + i * 30) + 35, 275);
				train.ID = i;
				if (trains[i] != 'edward')
					train.frames = Paths.getSparrowAtlas('freeplay/freeplay_${trains[i]}', 'menu');
				else
					train.frames = Paths.getSparrowAtlas('freeplay/freeplay_${trains[i]}', 'secretStuff');
				train.animation.addByPrefix('idle', 'freeplay_${trains[i]} idle', 12);
				train.animation.addByPrefix('select', 'freeplay_${trains[i]} select', 12, false);
				train.animation.addByPrefix('selected', 'freeplay_${trains[i]} selected', 12);
				train.animation.addByPrefix('deselect', 'freeplay_${trains[i]} deselect', 12, false);
				train.animation.play('idle');
				train.scale.x = 0.35;
				train.scale.y = 0.35;
				train.antialiasing = ClientPrefs.globalAntialiasing;
				train.updateHitbox();
				grpOptions.add(train);

				var testArray:Array<FlxSprite> = [];

				if (i == 4)
					{
						if(allowEdward)
							{
								var songSprite:FlxSprite = new FlxSprite(500, 75).loadGraphic(Paths.image('freeplay/songbuttons/${edwardList[0]}','secretStuff'));
								grpButtons.add(songSprite);
								songSprite.setGraphicSize(Std.int(songSprite.width * 0.6));
								songSprite.updateHitbox();
								songSprite.visible = false;
								testArray.push(songSprite);

								if (curSelected == i)
									{
										songSprite.alpha = 1;
									}
								
								curButtons.push(testArray);
									
							}
						else continue;
					}
				else
				for (j in 0...loadedTabs[i].songs.length)
					{
						trace(loadedTabs[i].songs[j]);
						var songSprite:FlxSprite = null;
						if(loadedTabs[i].songs[j] != 'loathed')
							songSprite = new FlxSprite(100 + (j * 500), 100).loadGraphic(Paths.image('freeplay/songbuttons/${loadedTabs[i].songs[j]}','menu'));
						else
							songSprite = new FlxSprite(100 + (j * 500), 100).loadGraphic(Paths.image('freeplay/songbuttons/${loadedTabs[i].songs[j]}','secretStuff'));
						if (i == 3 && j == 1)
							{
								songSprite.x += 100;
							}
						if (i != 3)
							{
								songSprite.x += 125;
							}
						songSprite.y -= songSprite.height/4;
						if (loadedTabs[i].songs.length < 3)
							{
								songSprite.y += 25;
							}
						if (j == 2)
							{
								if (i == 1)
									songSprite.x -= 800;
								else
									songSprite.x -= 600;
								songSprite.y += 100;
							}
						grpButtons.add(songSprite);
						songSprite.setGraphicSize(Std.int(songSprite.width * 0.6));
						songSprite.updateHitbox();
						songSprite.antialiasing = ClientPrefs.globalAntialiasing;
						songSprite.visible = false;
						testArray.push(songSprite);

						if (curSelected == i)
							{
								songSprite.alpha = 1;
							}

						if (j == loadedTabs[i].songs.length - 1)
							{
								curButtons.push(testArray);
							}

						
					}
			}
		add(grpOptions);

		if (allowFatass)
		{
			fatass = new FlxSprite().loadGraphic(Paths.image('freeplay/fp_topham', 'menu'));
			fatass.setGraphicSize(Std.int(fatass.width * 0.6));
			fatass.updateHitbox();
			fatass.x = FlxG.width - fatass.width;
			fatass.y = FlxG.height - fatass.height;
			add(fatass);
			
		}


		cloudSprite = new FlxSprite(25, 0);
		cloudSprite.frames = Paths.getSparrowAtlas('freeplay/fp_cloud', 'menu');
		cloudSprite.animation.addByPrefix('intro', 'fp cloud intro', 24, false);
		cloudSprite.animation.addByPrefix('idle', 'fp cloud loop', 24, true);
		cloudSprite.animation.play('idle');
		cloudSprite.visible = false;
		cloudSprite.scale.x = 0.75;
		cloudSprite.scale.y = 0.75;
		cloudSprite.updateHitbox();
		add(cloudSprite);

		add(grpButtons);


		
		WeekData.setDirectoryFromWeek();


		//if(curSelected >= songs.length) curSelected = 0;

		//if(lastDifficultyName == '')
		//{
		//	lastDifficultyName = CoolUtil.defaultDifficulty;
		//}
		//curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		//changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		/*var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);*/
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		
			for (i in 0...trains.length)
				{
					if (i == trains.length - 1 && !allowEdward) break;
					if (!tweening)
					{
							if (grpOptions.members[i].ID != curSelected && FlxG.mouse.overlaps(grpOptions.members[i]) && FlxG.mouse.justPressed)
								{
											if (curSelected > -1)
											{
												for (j in 0...curButtons[curSelected].length)
													{
														curButtons[curSelected][j].visible = false;
														//FlxTween.tween(curButtons[curSelected][i], {alpha: 0}, 1, {ease: FlxEase.circOut/*, startDelay: 0.5 + (0.2 * i)*/});
													}
												grpOptions.members[curSelected].animation.play('deselect');
												//grpOptions.members[curSelected].animation.curAnim.finishCallback = function(name:String) {grpOptions.members[i].animation.play('idle'); trace(grpOptions.members[curSelected].animation.name);};
											}
											else
												{
													cloudSprite.visible = true;
													cloudSprite.animation.play('intro');
													cloudSprite.animation.finishCallback = function(name:String) { cloudSprite.animation.play('idle');};
												}

											trace('changed to ${i}:${trains[i]}');
											var prevSelected:Int = curSelected;
											trace(prevSelected);
											curSelected = i;
											trace(curSelected);

											
											for (i in 0...curButtons[curSelected].length)
												{
													if (prevSelected > -1)
														{
															trace('no tween');
															curButtons[curSelected][i].visible = true;
															curButtons[curSelected][i].alpha = 1;
															trace(curButtons[curSelected][i].alpha);
														}
													else
														{
															tweening = true;
															curButtons[curSelected][i].visible = true;
															curButtons[curSelected][i].alpha = 0;
															FlxG.sound.play(Paths.sound('cloudappear', 'menu'));
															FlxTween.tween(curButtons[curSelected][i], {alpha: 1}, 0.5, {startDelay: 0.75, onComplete: function(twn:FlxTween)
																{tweening = false;}});
														}
												}
											if(curSelected == 4)
												curSongList = edwardList;
											else
												curSongList = loadedTabs[curSelected].songs;

											grpOptions.members[i].animation.play('select');
											FlxG.sound.play(Paths.sound('engineselect', 'menu'));
											//grpOptions.members[i].animation.finishCallback = function(name:String) {grpOptions.members[i].animation.play('selected'); trace(grpOptions.members[curSelected].animation.name);};
											
											//changeSelection();
										
								}
						}
					
					if (FlxG.mouse.overlaps(grpOptions.members[i]))
						{
							changeCursor(true);
							break;
						}
					else
						changeCursor(false);
						
						
				}
		if (curSelected > -1)
		{
			for (i in 0...curButtons[curSelected].length)
				{
					if (FlxG.mouse.overlaps(curButtons[curSelected][i]) && FlxG.mouse.x < curButtons[curSelected][i].x + curButtons[curSelected][i].width/2 && FlxG.mouse.y < curButtons[curSelected][i].y + curButtons[curSelected][i].height/2)
						{
							changeCursor(true);
							if (curSelected != 4)
							{
								if(curSelected == 3 && i == 2)
									curButtons[curSelected][i].loadGraphic(Paths.image('freeplay/songbuttons/${loadedTabs[curSelected].songs[i]} glow','secretStuff'));
								else
									curButtons[curSelected][i].loadGraphic(Paths.image('freeplay/songbuttons/${loadedTabs[curSelected].songs[i]} glow','menu'));
							}
							else
								curButtons[curSelected][i].loadGraphic(Paths.image('freeplay/songbuttons/${edwardList[0]} glow','secretStuff'));
							if (FlxG.mouse.justPressed)
								{
									FlxG.sound.play(Paths.sound('confirmMenu'));
									loadSong(i);
								}
							break;
						}
					else
					{
						if (curSelected != 4)
							{
								if(curSelected == 3 && i == 2)
									curButtons[curSelected][i].loadGraphic(Paths.image('freeplay/songbuttons/${loadedTabs[curSelected].songs[i]}','secretStuff'));
								else
									curButtons[curSelected][i].loadGraphic(Paths.image('freeplay/songbuttons/${loadedTabs[curSelected].songs[i]}','menu'));
							}
						else
							curButtons[curSelected][i].loadGraphic(Paths.image('freeplay/songbuttons/${edwardList[0]}','secretStuff'));
					}
				}
		}

		if (fatass != null && FlxG.mouse.overlaps(fatass))
			{
				changeCursor(true);
				if (FlxG.mouse.justPressed)
					{
						loadSong2('confusion-and-delay');
					}
			}

		if (FlxG.mouse.overlaps(backButton))
			{
				changeCursor(true);
				backButton.loadGraphic(Paths.image('freeplay/back_button_selected', 'menu'));
				if (FlxG.mouse.justPressed)
					{
						persistentUpdate = false;
						FlxG.sound.play(Paths.sound('cancelMenu'));
						MusicBeatState.switchState(new BebMainMenu());
					}
			}
		else
			backButton.loadGraphic(Paths.image('freeplay/back_button', 'menu'));
		



		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		/*if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);
		else if (upP || downP) changeDiff();

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new BebMainMenu());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if (accepted)
			{
				loadSong(0);
			}

		
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}*/
		if (controls.BACK)
			{
				persistentUpdate = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new BebMainMenu());
			}
		super.update(elapsed);
	}

	function loadSong(id:Int)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(curSongList[id]);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			

			LoadingState.loadAndSwitchState(new DebugPlaystate());
			

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}

		function loadSong2(id:String)
			{
				persistentUpdate = false;
				var songLowercase:String = Paths.formatToSongPath(id);
				var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
				/*#if MODS_ALLOWED
				if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
				#else
				if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
				#end
					poop = songLowercase;
					curDifficulty = 1;
					trace('Couldnt find file');
				}*/
				trace(poop);
	
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
	
				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
				

				LoadingState.loadAndSwitchState(new DebugPlaystate());
				
	
				FlxG.sound.music.volume = 0;
						
				destroyFreeplayVocals();
			}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];


		PlayState.storyDifficulty = curDifficulty;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		if (loadedTabs[curSelected] != null)
			curSongList = loadedTabs[curSelected].songs;
		

		// selector.y = (70 * curSelected) + 30;


		var bullShit:Int = 0;


		
		
		//Paths.currentModDirectory = songs[curSelected].folder;
		//PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}
	}

	function changeCursor(value:Bool)
        {
            if (value)
                {
                    FlxG.mouse.load(cursorSprite2.pixels);
                }
            if (!value)
                {
                    FlxG.mouse.load(cursorSprite.pixels);
                }
        }

}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}