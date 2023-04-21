package;

import flixel.FlxSprite;
import flixel.FlxG;

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
    var buttons:Array<FlxSprite> = [];
    var curButton:Int = 0;
    override function create()
    {
        if(FlxG.sound.music == null) {
            FlxG.sound.playMusic(Paths.music('bebmenu'), 0);
            FlxG.sound.music.fadeIn(1, 0, 0.7);
        }
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

        var tankEngine:FlxSprite = new FlxSprite().loadGraphic(Paths.image('main/menu$curTrain', 'menu'));
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
        if (controls.UI_UP_P)
            selecting(-1);
        if (controls.UI_DOWN_P)
            selecting(1);
        if (controls.ACCEPT)
            {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                switch(btns[curButton])
                {
                    case 'StoryButton':
                    case 'FreePlayButton':
                        MusicBeatState.switchState(new FreeplayState());
                    case 'AwardsButton':
                        //yeah
                    case 'OptionsButton':
                        openSubState(new BebOptionsSubstate());
                    case 'CreditsButton':
                        //yeah
                }
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
}