package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

#if VIDEOS_ALLOWED
#if (hxCodec >= "2.6.1") import hxcodec.VideoHandler as MP4Handler;
#elseif (hxCodec == "2.6.0") import VideoHandler as MP4Handler;
#else import vlc.MP4Handler; #end
import hxcodec.VideoSprite;
#end

#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class ThomasState extends MusicBeatState
{

	override function create()
	{
		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		startVideo('intro');

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function loadSong()
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath('puffball');
			var poop:String = Highscore.formatSong(songLowercase, ClientPrefs.difficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = ClientPrefs.difficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			

			LoadingState.loadAndSwitchState(new DebugPlaystate());
			

			FlxG.sound.music.volume = 0;
		}

	public function startVideo(name:String)
		{
			
			#if VIDEOS_ALLOWED
			var filepath:String = Paths.video(name);
			#if sys
			if(!FileSystem.exists(filepath))
			#else
			if(!OpenFlAssets.exists(filepath))
			#end
			{
				FlxG.log.warn('Couldnt find video file: ' + name);
				return;
			}
	
			var video:MP4Handler = new MP4Handler();
			video.skipKeys = [FlxKey.ENTER];
			video.playVideo(filepath);
			video.finishCallback = function()
				{
					loadSong();
				}
			#end
		}

}
