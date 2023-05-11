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

class BebAwardsState extends MusicBeatState
{
	var grpOptions:FlxSpriteGroup;
    var bg:FlxSprite;
    var topham:FlxSprite;
    var overlay:FlxSprite;
    var overlay2:FlxSprite;
    var allowedToChange:Bool = false;
    var curSelected:Int = 0;
    var camFollow:FlxObject;
	var camFollowPos:FlxObject;
    var cursorSprite:FlxSprite;
    var cursorSprite2:FlxSprite;
	var backButton:FlxSprite;

    var photos:FlxSpriteGroup;
    var inPhoto:Bool;

    var photoBG:FlxSprite;
    var photoZoom:FlxSprite;

    var tophamState:Int = 0;

    var achieves:Array<String> = [
        'awardpuffball',
        'awardmainweek',
        'awardsadstory',
        'awardremix',
        'awardgameover',
        'awardconfusiondelay',
        'awardexpress',
        'awardloathed',
        'awarduseful'
    ];

    override function create(){
        #if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

        FlxG.sound.playMusic(Paths.music('beb_awards'), 0);
        FlxG.sound.music.fadeIn(1, 0, 0.7);

        BebMainMenu.previousState = 'awards';
		        
        bg = new FlxSprite().loadGraphic(Paths.image('awards/tophamoffice','menu'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.setGraphicSize(Std.int(FlxG.width));
        bg.screenCenter();
        add(bg);

        photos = new FlxSpriteGroup();
        var xFuckShit:Int = 0;
        for (i in 0...achieves.length-2)
            {
                var achieveImage:FlxSprite = new FlxSprite().loadGraphic(Paths.image('awards/award portraits/${achieves[i]}','menu'));
                achieveImage.scale.x = 0.2;
                achieveImage.scale.y = 0.2;
                achieveImage.updateHitbox();
                achieveImage.x = 10 + achieveImage.width * i;
                if (i > 0)
                    achieveImage.x += 15 * i;
                achieveImage.y += 25;
                if (xFuckShit > 4)
                {
                    achieveImage.x = 10 + achieveImage.width * (i - 5);
                    if (i - 5 > 0)
                        achieveImage.x += 15 * (i - 5);
                    achieveImage.y += achieveImage.height;
                }
                
                xFuckShit++;
                photos.add(achieveImage);
            }

            add(photos);

            topham = new FlxSprite().loadGraphic(Paths.image('awards/topham1','menu'));
            topham.antialiasing = ClientPrefs.globalAntialiasing;
            topham.setGraphicSize(Std.int(FlxG.width));
            topham.screenCenter();
            add(topham);

        cursorSprite = new FlxSprite().loadGraphic(Paths.image('ui/cursor'));
        cursorSprite2 = new FlxSprite().loadGraphic(Paths.image('ui/cursor2'));
        FlxG.mouse.visible = true;

        backButton = new FlxSprite().loadGraphic(Paths.image('freeplay/back_button',"menu"));
		backButton.setGraphicSize(Std.int(backButton.width * 0.8));
		backButton.updateHitbox();
		backButton.x = FlxG.width - backButton.width - 10;
		backButton.y = FlxG.height - backButton.height - 10;
        backButton.alpha = 0;
        FlxTween.tween(backButton, {alpha: 1}, 0.25);
		add(backButton);

        overlay = new FlxSprite().loadGraphic(Paths.image('awards/awardsoverlaymultiply','menu'));
		overlay.antialiasing = ClientPrefs.globalAntialiasing;
        overlay.setGraphicSize(Std.int(FlxG.width));
        overlay.screenCenter();
        overlay.blend = MULTIPLY;
        add(overlay);

        overlay2 = new FlxSprite().loadGraphic(Paths.image('awards/awardsoverlay2add','menu'));
		overlay2.antialiasing = ClientPrefs.globalAntialiasing;
        overlay2.setGraphicSize(Std.int(FlxG.width));
        overlay2.screenCenter();
        overlay2.blend = ADD;
        add(overlay2);


        photoBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        photoBG.alpha = 0;
        add(photoBG);

        photoZoom = new FlxSprite().loadGraphic(Paths.image('awards/award full imgs/${achieves[0]}','menu'));
        photoZoom.alpha = 0;
        add(photoZoom);

        super.create();
    }

    var targetY:Float = 0;

    override function update(elapsed:Float){

        if (!inPhoto)
        {
            if (controls.BACK || FlxG.mouse.justPressedRight) {
                allowedToChange = false;

                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new BebMainMenu());
                FlxG.sound.music.fadeOut(1, 0);
                

            }

            for (i in 0...photos.members.length)
                {
                    if (FlxG.mouse.overlaps(photos.members[i]))
                        {
                            if (FlxG.mouse.justPressed)
                            {
                                inPhoto = true;
                                photoZoom.loadGraphic(Paths.image('awards/award full imgs/${achieves[i]}','menu'));
                                photoZoom.setGraphicSize(0, Std.int(FlxG.height));
                                photoZoom.screenCenter();
                                FlxTween.tween(photoZoom, {alpha: 1}, 0.25);
                                FlxTween.tween(photoBG, {alpha: 0.75}, 0.25);
                            }
                        }
                    
                    if (FlxG.mouse.overlaps(photos.members[i]))
                        {
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
                            FlxG.sound.music.fadeOut(1, 0);
                        }
                    }
                else
                    {
                        backButton.loadGraphic(Paths.image('freeplay/back_button', 'menu'));
                    }

                    if (FlxG.mouse.overlaps(topham) && FlxG.mouse.x > (FlxG.width / 2 - 150) && FlxG.mouse.x < (FlxG.width / 2 + 50) && FlxG.mouse.y > (FlxG.height / 2 - 100) && FlxG.mouse.y < (FlxG.height / 2 + 100))
                        {
                            changeCursor(true);
                            
                            if (FlxG.mouse.justPressed)
                            {
                                if (tophamState < 3)
                                {
                                    tophamState++;
                                    topham.loadGraphic(Paths.image('awards/topham${tophamState}', 'menu'));
                                }
                            }
                        }
        
        }
        else
            {
                if (FlxG.mouse.justPressed)
                    {
                        FlxTween.tween(photoZoom, {alpha: 0}, 0.25);
                        FlxTween.tween(photoBG, {alpha: 0}, 0.25, {onComplete: function(lol:FlxTween){inPhoto = false; }});
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
}