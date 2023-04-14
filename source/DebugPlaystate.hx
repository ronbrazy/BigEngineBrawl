package;

import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class DebugPlaystate extends PlayState
{
    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (!startingSong && !endingSong)
            if (FlxG.keys.justPressed.F1)
                endSong();
            else if (FlxG.keys.justPressed.F2)
                {
                    Conductor.songPosition = Conductor.songPosition + 5000; 
                    FlxG.sound.music.time = Conductor.songPosition;
                    vocals.time = Conductor.songPosition;
                }
            else if (FlxG.keys.justPressed.F3)
                {
                    if (!cpuControlled)
                        {
                            cpuControlled = true;
                            trace("botPlay On");
                            botplayTxt.visible = true;
                        }
                    else
                        {
                            cpuControlled = false;
                            botplayTxt.visible = false;
                            trace("botPlay Off");
                        }
                }
            else if (FlxG.keys.justPressed.F4)
                {
                    defaultCamZoom = defaultCamZoom + 0.1;
					FlxTween.tween(camGame, {zoom: defaultCamZoom + 0.1}, 0.1, {ease: FlxEase.cubeInOut});
                }
            else if (FlxG.keys.justPressed.F5)
                {
                    defaultCamZoom = defaultCamZoom - 0.1;
                    FlxTween.tween(camGame, {zoom: defaultCamZoom - 0.1}, 0.1, {ease: FlxEase.cubeInOut});
                }
    }
}