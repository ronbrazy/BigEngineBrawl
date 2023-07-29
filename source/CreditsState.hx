package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;
	var prevSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpSprites:FlxTypedGroup<AttachedSprite>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var thomas:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;
	var blinkTime:Float = 0;
    var cursorSprite:FlxSprite;
    var cursorSprite2:FlxSprite;
	var backButton:FlxSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Idling in the Station (Credits)", null);
		#end

		cursorSprite = new FlxSprite().loadGraphic(Paths.image('ui/cursor'));
        cursorSprite2 = new FlxSprite().loadGraphic(Paths.image('ui/cursor2'));

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('credits/credits_bg', 'menu'));
		add(bg);
		bg.setGraphicSize(Std.int(FlxG.width));
		bg.updateHitbox();
		bg.screenCenter();

		thomas = new FlxSprite();
		thomas.frames = Paths.getSparrowAtlas('credits/thomas_credits', 'menu');
		thomas.animation.addByPrefix('credit','thomas credits credit lookatcredit',24,false);
		thomas.animation.addByPrefix('credit loop','thomas credits credit loop',24,true);
		thomas.animation.addByPrefix('viewer','thomas credits credit lookatviewer',24,false);
		thomas.animation.play('viewer');
		thomas.setGraphicSize(Std.int(thomas.width*0.6));
		thomas.updateHitbox();
		thomas.y = FlxG.height - thomas.height;
		add(thomas);

		backButton = new FlxSprite().loadGraphic(Paths.image('freeplay/back_button',"menu"));
		backButton.x = 10;
		backButton.setGraphicSize(Std.int(backButton.width * 0.8));
		backButton.updateHitbox();
		backButton.y = FlxG.height - backButton.height - 10;
        backButton.alpha = 0;
        FlxTween.tween(backButton, {alpha: 1}, 0.25);
		add(backButton);
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grpSprites = new FlxTypedGroup<AttachedSprite>();
		add(grpSprites);

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<String>> = [ //Name - Link
			['ronbrazy', 'https://www.youtube.com/channel/UCLzE4XojDqFxM8cQbKPZEXA'],
			['Jack Orange', 'https://youtube.com/@JackOrange'],
			['boid', 'https://spaceboid.tumblr.com/'],
			['broster', 'https://twitter.com/BrosterMedia'],
			['CybbrGhost', 'https://twitter.com/CybbrGhost'],
			['DPZ', 'https://www.youtube.com/@DPZmusic'],
			['Cerbera', 'https://www.youtube.com/channel/UCgfJjMiNGlI7uZu1cVag5NA'],
			['SeaSwine9', 'https://twitter.com/SeaSwine9'],
			['Chunko', 'https://twitter.com/Chunklezz?t=UVlM9XFlLmkc3FFAw3rENQ&s=09'],
			['theoldguardsvan', ''],
			['SplendidStudios', ''],
			['Miyno', ''],
			['minuil', 'https://twitter.com/balbin_brian'],
			['DiamondHeart', ''],
			['typic', ''],
			['sketchygirl711', 'https://twitter.com/sketchygirl711/status/1681806961547911169?t=v2HAzgbUxrQeRyJNsCOncQ&s=19'],
			['Lofi', 'https://twitter.com/LofiOrSomethin'],
			['rafael wasnt here', 'https://twitter.com/rafawasnth3r3?s=21&t=CzLRF3xxDvz3l2m59jgA0Q'],
			['AndyJoeS', 'https://twitter.com/AndyJS216'],
			['Plongo', 'https://youtube.com/@PlongoYT'],
			['OvalFrankie', 'https://twitter.com/OvalFrankie'],
			['thetrainnerd', 'https://twitter.com/TheTrainNerrd'],
			['stephensons wolf', ''],
			['SteamySudric', ''],
			['DuskieWhy', ''] // lmao
		];
		
		for(i in pisspoop){
			creditsStuff.push(i);
		}
	
		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			var item2 = new AttachedSprite('credits/people/' + creditsStuff[i][0].toLowerCase(), null, 'menu');
			item2.setGraphicSize(Std.int(item2.width * 0.5));
			item2.updateHitbox();
			item2.x = FlxG.width/8*6.5;
			item2.x -= item2.width/2;
			item2.ID = i;
			item2.ignoreX = true;
			item2.sprTracker = grpOptions.members[i];
			grpOptions.members[i].visible = false;
			grpSprites.add(item2);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}

		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		blinkTime += elapsed * 1000;
		if(blinkTime >= 5000)
			{
				switch(FlxG.random.int(1, 2))
				{
					case 1:
						thomas.animation.play('credit');
						blinkTime = 0;
					case 2:
						thomas.animation.play('viewer');
						blinkTime = 0;
				}
			}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				for (i in grpSprites)
					{
						if (FlxG.mouse.overlaps(i))
							{
								if (FlxG.mouse.justPressed)
								{
									curSelected = i.ID;
									selectedSomething();
									break;
								}
								changeCursor(true);
								break;
							}
						else
							changeCursor(false);
							
							
					}

					if (FlxG.mouse.overlaps(backButton))
						{
							changeCursor(true);
							backButton.loadGraphic(Paths.image('freeplay/back_button_selected', 'menu'));
							if (FlxG.mouse.justPressed)
							{
								FlxG.sound.play(Paths.sound('cancelMenu'));
								MusicBeatState.switchState(new BebMainMenu());
								quitting = true;
							}
						}
					else
						backButton.loadGraphic(Paths.image('freeplay/back_button', 'menu'));

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
					changeSelection(-FlxG.mouse.wheel);
				}	

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
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][1] == null || creditsStuff[curSelected][1].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][1]);
			}
			if (controls.BACK)
			{

				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new BebMainMenu());
				quitting = true;
			}
		}
		
		
		super.update(elapsed);
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

	function selectedSomething()
	{
		if(prevSelected == curSelected && (creditsStuff[curSelected][1] == null || creditsStuff[curSelected][1].length > 4)) {
			CoolUtil.browserLoad(creditsStuff[curSelected][1]);
		}
		else if (prevSelected != curSelected)
		{
			changeSelection();
			
			for (item in grpSprites.members)
				{
					if (item.ID == curSelected)
						{
							item.loadGraphic(Paths.image('credits/people/${creditsStuff[curSelected][0].toLowerCase()} glow', 'menu'));
							item.updateHitbox();
						}
					else
						{
							item.loadGraphic(Paths.image('credits/people/${creditsStuff[item.ID][0].toLowerCase()}', 'menu'));
							item.updateHitbox();
						}
				}
		}
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;

			
			prevSelected = curSelected;
		} while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
		}
		for (item in grpSprites.members)
			{
				if (item.ID == curSelected)
					{
						item.loadGraphic(Paths.image('credits/people/${creditsStuff[curSelected][0].toLowerCase()} glow', 'menu'));
					}
				else
					{
						item.loadGraphic(Paths.image('credits/people/${creditsStuff[item.ID][0].toLowerCase()}', 'menu'));
					}
			}
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}