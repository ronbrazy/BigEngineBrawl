package options;

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
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

var difficulties:Array<String> = [];

var curDiff:Int = 2;

class DifficultySubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Difficulty';
		rpcTitle = 'Difficulty Settings Menu'; //for Discord Rich Presence

		curDiff = ClientPrefs.difficulty;

		for(i in 0...difficulties.length)
		{
			var img:FlxSprite = new FlxSprite().loadGraphic;
		}

		super();
	}

}
