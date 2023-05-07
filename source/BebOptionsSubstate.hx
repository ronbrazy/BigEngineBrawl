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
	var options:Array<String> = ['Note Colors', 'Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay'];
	var grpOptions:FlxSpriteGroup;
    var bg:FlxSprite;
    var allowedToChange:Bool = false;
    var curSelected:Int = 0;
    var camFollow:FlxObject;
	var camFollowPos:FlxObject;
    var cursorSprite:FlxSprite;
    var cursorSprite2:FlxSprite;

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

        FlxTween.tween(bg, {alpha: 0.75}, 0.25, {ease: FlxEase.backInOut, /* goated ease */ onComplete: function(lol:FlxTween){
            allowedToChange = true;
            curSelected = 0;
            changeSelection();
            for(i in grpOptions){
                FlxTween.tween(i, {x: 808}, 0.75, {ease: FlxEase.backOut});
            }
        }});


        super.create();
    }

    var targetY:Float = 0;

    override function update(elapsed:Float){

        if (controls.BACK || FlxG.mouse.justPressedRight) {
            allowedToChange = false;

			FlxG.sound.play(Paths.sound('cancelMenu'));
            FlxTween.tween(bg, {alpha: 0}, 0.25);
            for(i in grpOptions){
                FlxTween.tween(i, {x: 1280}, 0.75, {ease: FlxEase.backIn, onComplete: function(poop:FlxTween){
                    close();
                }});
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

        if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeSelection(-FlxG.mouse.wheel);
			}

        if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}
		if (controls.ACCEPT) {
            if(allowedToChange)
                openSelectedSubstate(options[curSelected]);
		}

        grpOptions.y = FlxMath.lerp(grpOptions.y, targetY, CoolUtil.boundTo(elapsed * 7.5, 0, 1));
        grpOptions.forEach(function(spr:FlxSprite){
            if(allowedToChange){
                if(spr.active)
                    spr.x = FlxMath.lerp(spr.x, 690, CoolUtil.boundTo(elapsed * 7.5, 0, 1));
                else
                    spr.x = FlxMath.lerp(spr.x, 808, CoolUtil.boundTo(elapsed * 7.5, 0, 1));    
            }
        });

        super.update(elapsed);

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
            trace(targetY);
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