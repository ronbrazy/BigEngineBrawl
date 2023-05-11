package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.system.FlxSound;

class BebMainMenu extends MusicBeatState
{
    var curTrain:String = 'thomas';
    var trains:Array<String> = [
        'edward',
        'gordon',
        'henry',
        'james',
        'thomas',
        'thomas',
    ];
    var btns:Array<String> = [
        'StoryButton',
        'FreePlayButton',
        'AwardsButton',
        'OptionsButton',
        'CreditsButton'
    ];
    var tankEngine:FlxSprite;
    var buttons:Array<FlxSprite> = [];
    var curButton:Int = 0;
    var cursorSprite:FlxSprite;
    var cursorSprite2:FlxSprite;
    var trainWhistle:FlxSound = new FlxSound();

    public static var previousState:String = '';
    //var selectingCursor:Bool = false;
    override function create()
    {
        if (previousState == 'awards')
        {
            FlxG.sound.playMusic(Paths.music('bebmenu'), 0);
            FlxG.sound.music.fadeIn(1, 0, 0.7);
        }

        else if (FlxG.sound.music == null)
        {
            FlxG.sound.playMusic(Paths.music('bebmenu'), 0);
            FlxG.sound.music.fadeIn(1, 0, 0.7);
        }

        previousState = '';

        cursorSprite = new FlxSprite().loadGraphic(Paths.image('ui/cursor'));
        cursorSprite2 = new FlxSprite().loadGraphic(Paths.image('ui/cursor2'));
        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('main/menubackground', 'menu'));
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        bg.setGraphicSize(Std.int(bg.width / 1.5));
        bg.updateHitbox();
        add(bg);

        if (!ClientPrefs.firstTime){
            var shit = FlxG.random.int(0, trains.length - 1);
            curTrain = trains[shit];
            trace(shit);
        }
        else
        {
            ClientPrefs.firstTime = false;
            ClientPrefs.saveSettings();
        }

        trainWhistle = FlxG.sound.load(Paths.sound('${curTrain}Whistle', 'menu'));

        tankEngine = new FlxSprite().loadGraphic(Paths.image('main/menu$curTrain', 'menu'));
        tankEngine.antialiasing = ClientPrefs.globalAntialiasing;
        tankEngine.setGraphicSize(Std.int(tankEngine.width / 1.5));
        tankEngine.updateHitbox();
        add(tankEngine);

        var poleAndBtnsOffset:Array<Float> = [10,0];

        var pole:FlxSprite = new FlxSprite(poleAndBtnsOffset[0],poleAndBtnsOffset[1]).loadGraphic(Paths.image('main/pole', 'menu'));
        pole.antialiasing = ClientPrefs.globalAntialiasing;
        pole.setGraphicSize(Std.int(pole.width / 1.8));
        pole.updateHitbox();
        add(pole);

        var leInt:Int = 0;
        for (i in btns)
        {
            var button:FlxSprite = new FlxSprite(3+poleAndBtnsOffset[0],3+(100*leInt)+(leInt == 0 ? 0 : 80)+poleAndBtnsOffset[1]);
            button.antialiasing = ClientPrefs.globalAntialiasing;
            button.frames = Paths.getSparrowAtlas('main/buttons/$i', 'menu');
            button.animation.addByPrefix('up','${i}0',48,false);
            button.animation.addByPrefix('down','${i}Un',48,false);
            button.animation.play('down');
            button.setGraphicSize(Std.int(button.width / 1.8));
            button.updateHitbox();
            button.ID = leInt;
            add(button);
            buttons.push(button);
            leInt++;
        }
        
        var bg2:FlxSprite = new FlxSprite().loadGraphic(Paths.image('main/menustation', 'menu'));
        bg2.antialiasing = ClientPrefs.globalAntialiasing;
        bg2.setGraphicSize(Std.int(bg2.width / 1.5));
        bg2.updateHitbox();
        add(bg2);
        
        selecting(0);
        super.create();
    }
    override function update(elapsed:Float)
    {
        
        for (i in 0...btns.length)
        {
            if (FlxG.mouse.overlaps(buttons[curButton]) && FlxG.mouse.y < (buttons[curButton].y + 75))
                {
                    if (FlxG.mouse.justPressed)
                    {
                        selectedSomething();
                        break;
                    }
                }
            if (buttons[i].ID != curButton)
                if (FlxG.mouse.overlaps(buttons[i]) && FlxG.mouse.y < (buttons[i].y + 75))
                    {
                        curButton = i;
                        selecting();
                    }
            if (FlxG.mouse.overlaps(buttons[i]) && FlxG.mouse.y < (buttons[i].y + 75))
                {
                    changeCursor(true);
                    break;
                }
            else
                changeCursor(false);
                
                
        }

        if (FlxG.mouse.overlaps(tankEngine) && FlxG.mouse.y > 238 && FlxG.mouse.y < 465 && FlxG.mouse.x > 324 && FlxG.mouse.x < 525)
            {
                changeCursor(true);
                if (FlxG.mouse.justPressed && !trainWhistle.playing)
                    {
                        trainWhistle.play();
                    }
            }
        
        if(FlxG.keys.justPressed.C)
            {
                trace('mousepos\nx:${FlxG.mouse.x}\ny:${FlxG.mouse.y}');
            }

        if (controls.UI_UP_P)
            selecting(-1);
        if (controls.UI_DOWN_P)
            selecting(1);
        if (controls.ACCEPT)
            {
                selectedSomething();
            }
        super.update(elapsed);
    }
    function selecting(huh:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        curButton += huh;
        if (curButton >= buttons.length)
            curButton = 0;
        if (curButton < 0)
            curButton = buttons.length - 1;
        for (i in buttons)
        if (i.ID == curButton || (i.ID != curButton && i.animation.curAnim.name != 'down'))
        i.animation.play(i.ID == curButton ? 'up' : 'down');
    }

    function selectedSomething()
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
                switch(btns[curButton])
                {
                    case 'StoryButton':
                    case 'FreePlayButton':
                        MusicBeatState.switchState(new FreeplayState());
                    case 'AwardsButton':
                        MusicBeatState.switchState(new BebAwardsState());
                        FlxG.sound.music.fadeOut(1, 0);
                    case 'OptionsButton':
                        openSubState(new BebOptionsSubstate());
                    case 'CreditsButton':
                        //yeah
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