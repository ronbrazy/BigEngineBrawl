package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef BonusTab =
{
	var songs:Array<Dynamic>;
}

class TabData {
	public static var tabsLoaded:Map<String, TabData> = new Map<String, TabData>();
	public static var tabsList:Array<String> = [];
	public var folder:String = '';
	
	// JSON variables
	public var songs:Array<Dynamic>;

	public var fileName:String;

	public static function createTabFile():BonusTab {
		var tabFile:BonusTab = {
			songs: [["puffball"]]
		};
		return tabFile;
	}

	public function new(tabFile:BonusTab, fileName:String) {
		songs = tabFile.songs;

		this.fileName = fileName;
	}

	public static function reloadTabFiles()
		{
			tabsList = [];
			tabsLoaded.clear();
			
			var directories:Array<String> = [Paths.getPreloadPath()];
			var originalLength:Int = directories.length;
	
			var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('freeplay/tabList.txt'));
			for (i in 0...sexList.length) {
				for (j in 0...directories.length) {
					var fileToCheck:String = directories[j] + 'freeplay/' + sexList[i] + '.json';
					if(!tabsLoaded.exists(sexList[i])) {
						var tab:BonusTab = getTabFile(fileToCheck);
						if(tab != null) {
							var tabFile:TabData = new TabData(tab, sexList[i]);
	
							if(tabFile != null) {
								tabsLoaded.set(sexList[i], tabFile);
								tabsList.push(sexList[i]);
							}
						}
					}
				}
			}
	
		}

	private static function addTab(tabToCheck:String, path:String, directory:String, i:Int, originalLength:Int)
	{
		if(!tabsLoaded.exists(tabToCheck))
		{
			var tab:BonusTab = getTabFile(path);
			if(tab != null)
			{
				var tabFile:TabData = new TabData(tab, tabToCheck);

					tabsLoaded.set(tabToCheck, tabFile);
					tabsList.push(tabToCheck);
				
			}
		}
	}

	private static function getTabFile(path:String):BonusTab {
		var rawJson:String = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end

		if(rawJson != null && rawJson.length > 0) {
			return cast Json.parse(rawJson);
		}
		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE

	//To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String {
		return tabsList[PlayState.storyWeek];
	}

	//Used on LoadingState, nothing really too relevant
	public static function getCurrentWeek():TabData {
		return tabsLoaded.get(tabsList[PlayState.storyWeek]);
	}

	public static function setDirectoryFromWeek(?data:TabData = null) {
		Paths.currentModDirectory = '';
		if(data != null && data.folder != null && data.folder.length > 0) {
			Paths.currentModDirectory = data.folder;
		}
	}
}