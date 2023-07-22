package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import flixel.FlxCamera;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class BebOptionsSubstate extends MusicBeatSubstate
{
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'difficulty'];
    var diffs:Array<String> = ['easy', 'normal', 'hard'];
    var diffMap:Map<String, String> = [

		'easy' => 'mini',
		'normal' => 'nar',
		'hard' => 'stand'

	];
	var grpOptions:FlxSpriteGroup;
    var bg:FlxSprite;
    var allowedToChange:Bool = false;
    var curSelected:Int = 0;
    var camFollow:FlxObject;
	var camFollowPos:FlxObject;
    var cursorSprite:FlxSprite;
    var cursorSprite2:FlxSprite;
	var backButton:FlxSprite;
    var diffState:Bool = false;
    var grpDiffs:FlxSpriteGroup;

    function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
            case 'difficulty':
                slideTabsOut();
                //openSubState(new options.DifficultySubState());
		}
	}

    override function create(){
        #if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end
		        
        bg = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.screenCenter();
        bg.alpha = 0;
        add(bg);

        cursorSprite = new FlxSprite().loadGraphic(Paths.image('ui/cursor'));
        cursorSprite2 = new FlxSprite().loadGraphic(Paths.image('ui/cursor2'));
        FlxG.mouse.visible = true;

        backButton = new FlxSprite().loadGraphic(Paths.image('freeplay/back_button',"menu"));
		backButton.x = 10;
		backButton.setGraphicSize(Std.int(backButton.width * 0.8));
		backButton.updateHitbox();
		backButton.y = FlxG.height - backButton.height - 10;
        backButton.alpha = 0;
        FlxTween.tween(backButton, {alpha: 1}, 0.25);
		add(backButton);

        grpOptions = new FlxSpriteGroup();
        for(i in 0...options.length){
            var optionBar:FlxSprite = new FlxSprite(1280, 0 + (172 * i)).loadGraphic(Paths.image('options/${options[i]}', 'menu'));
            optionBar.scale.set(0.3, 0.3);
            optionBar.updateHitbox();
            optionBar.ID = i;
            optionBar.active = false;
            optionBar.alpha = 0.5;
            grpOptions.add(optionBar);
        }
        add(grpOptions);

        grpDiffs = new FlxSpriteGroup();
        for(i in 0...diffs.length){
            var imgPath:String = 'options/difficulties/${diffs[i]}';
            if(i == ClientPrefs.difficulty) imgPath += ' glow';
            var optionBar:FlxSprite = new FlxSprite(1280, FlxG.height/2 + (172 * (i - 1))).loadGraphic(Paths.image(imgPath, 'menu'));
            optionBar.scale.set(0.3, 0.3);
            optionBar.updateHitbox();
            optionBar.y -= optionBar.height / 2;
            optionBar.ID = i;
            //optionBar.alpha = 0.5;
            grpDiffs.add(optionBar);
        }
        add(grpDiffs);
        curSelected = 0;

        slideTabsIn();


        super.create();
    }

    public function slideTabsIn()
        {
            FlxTween.tween(bg, {alpha: 0.75}, 0.25, {ease: FlxEase.backInOut, /* goated ease */ onComplete: function(lol:FlxTween){
                
                for(i in grpOptions){
                    FlxTween.tween(i, {x: 808}, 0.75, {ease: FlxEase.backOut, onComplete: function(lol:FlxTween){
                        allowedToChange = true;
                        changeSelection();
                    }});
                }
            }});
        }

    public function slideTabsOut(closeMenu:Bool = false)
        {
            allowedToChange = false;
            if (closeMenu) FlxTween.tween(backButton, {alpha: 0}, 0.25);
                for(i in grpOptions)
                {
                    FlxTween.tween(i, {x: 1280}, 0.75, {ease: FlxEase.backIn, onComplete: function(poop:FlxTween){
                        if (closeMenu) { close(); }
                        else {slideDiffsIn(); }
                    }});
                }
        }

        public function slideDiffsIn()
            {
                diffState = true;
                FlxG.sound.play(Paths.sound('topham_select', 'menu'), 0.7);
                FlxTween.tween(bg, {alpha: 0.75}, 0.25, {ease: FlxEase.backInOut, /* goated ease */ onComplete: function(lol:FlxTween){
                    for(i in grpDiffs){
                        FlxTween.tween(i, {x: 808}, 0.75, {ease: FlxEase.backOut});
                    }
                }});
            }
    
        public function slideDiffsOut()
            {
                diffState = false;
                    for(i in grpDiffs)
                    {
                        FlxTween.tween(i, {x: 1280}, 0.75, {ease: FlxEase.backIn, onComplete: function(poop:FlxTween){
                            slideTabsIn();
                        }});
                    }
            }

    var targetY:Float = 0;

    override function update(elapsed:Float){

        if (controls.BACK || FlxG.mouse.justPressedRight) {
            if (!diffState)
            {
                allowedToChange = false;

                FlxG.sound.play(Paths.sound('cancelMenu'));
                FlxTween.tween(bg, {alpha: 0}, 0.25);
                slideTabsOut(true);
            }
            else
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                slideDiffsOut();
            }

        }

        for (i in 0...options.length)
            {
                if (FlxG.mouse.overlaps(grpOptions.members[curSelected]))
                    {
                        if (FlxG.mouse.justPressed)
                        {
                            trace('selected');
                            if(allowedToChange)
                                {
                                    FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                                    openSelectedSubstate(options[curSelected]);
                                    break;
                                }
                        }
                    }
                if (grpOptions.members[i].ID != curSelected)
                    if (FlxG.mouse.overlaps(grpOptions.members[i]))
                        {
                            if (FlxG.mouse.justPressed)
                                {
                                    FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
                                    trace('changed to ${i}:${options[i]} from ${grpOptions.members[curSelected].ID}:${options[curSelected]}');
                                    curSelected = i;
                                    changeSelection();
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

            if (allowedToChange || diffState)
            {
            if (FlxG.mouse.overlaps(backButton))
                {
                    changeCursor(true);
                    backButton.loadGraphic(Paths.image('freeplay/back_button_selected', 'menu'));
                    if (FlxG.mouse.justPressed)
                        {
                            if (!diffState)
                                {
                                    allowedToChange = false;
                    
                                    FlxG.sound.play(Paths.sound('cancelMenu'));
                                    FlxTween.tween(bg, {alpha: 0}, 0.25);
                                    slideTabsOut(true);
                                }
                            else
                                {
                                    FlxG.sound.play(Paths.sound('cancelMenu'), 0.7);
                                    slideDiffsOut();
                                }
                        }
                }
            else
                backButton.loadGraphic(Paths.image('freeplay/back_button', 'menu'));

        }

        if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
				changeSelection(-FlxG.mouse.wheel);
			}

        if (controls.UI_UP_P) {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);
			changeSelection(1);
		}
		if (controls.ACCEPT) {
            if(allowedToChange)
                {
                    FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
                    openSelectedSubstate(options[curSelected]);
                }
		}

        if (!diffState)
        {
            grpOptions.y = FlxMath.lerp(grpOptions.y, targetY, CoolUtil.boundTo(elapsed * 7.5, 0, 1));
            grpOptions.forEach(function(spr:FlxSprite){
                if(allowedToChange){
                    if(spr.active)
                        spr.x = FlxMath.lerp(spr.x, 690, CoolUtil.boundTo(elapsed * 7.5, 0, 1));
                    else
                        spr.x = FlxMath.lerp(spr.x, 808, CoolUtil.boundTo(elapsed * 7.5, 0, 1));    
                }
            });
        }
        else
        {
            for(i in grpDiffs)
                {
                    if (FlxG.mouse.overlaps(i))
                    {
                        changeCursor(true);
                        if (FlxG.mouse.justPressed)
                            {
                                FlxG.sound.play(Paths.sound('confirmMenu'), 0.3);
                                ClientPrefs.difficulty = i.ID;
                                FlxG.sound.play(Paths.sound('topham_${diffMap.get(diffs[ClientPrefs.difficulty])}', 'menu'));
                                trace('clicked on ${i.ID} | difficulty is: ${ClientPrefs.difficulty}');
                                i.loadGraphic(Paths.image('options/difficulties/${diffs[i.ID]} glow', 'menu'));
                                i.updateHitbox();
                            }
                    }
                    if (i.ID != ClientPrefs.difficulty)
                    {
                        i.loadGraphic(Paths.image('options/difficulties/${diffs[i.ID]}', 'menu'));
                        i.updateHitbox();
                    }
                }
        }

        super.update(elapsed);

    }

    override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

    function changeSelection(change:Int = 0) {
        if(allowedToChange){
            curSelected += change;

            if(curSelected >= options.length)
                curSelected = 0;
            if(curSelected < 0)
                curSelected = options.length - 1;
    
            grpOptions.forEach(function(spr:FlxSprite)
            {
                spr.alpha = 0.5;
                spr.active = false;
                if(spr.ID == curSelected){
                    targetY = (spr.ID * -172) + 150;
                    spr.alpha = 1;
                    spr.active = true;
                }
            });
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