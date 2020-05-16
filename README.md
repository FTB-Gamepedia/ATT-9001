# ATT-9001

**Automatic Tile Translator 9001** is used to automatically translate the [Official FTB Wiki's](https://ftb.gamepedia.com/FTB_Wiki) [tiles](https://ftb.gamepedia.com/Special:TileList) based on already existing language files.

**NOTE**: ATT-9001 only supports language files made in the [`.properties`](https://en.wikipedia.org/wiki/.properties) format. This means languages files made with [JSON](https://en.wikipedia.org/wiki/JSON), which should be all language files starting with Minecraft 1.13, will not function. A ATT-9002 version will be created to newer versions, but ATT-9001 will remain for older mods.

## Usage
1. Make sure you have Ruby.
2. Open a Terminal or whatever and change the directory to this directory.
3. Make sure you have everything in the Gemfile (`bundle install`).
4. Copy example_config.yml to config.yml.
5. Fill in the details. Note `login` is NOT the same as the bot's username on Gamepedia. This is viewable on [Special:BotPasswords](https://ftb.gamepedia.com/Special:BotPasswords). `token` is NOT the same as the bot's password on Gamepedia; it is also on Special:BotPasswords. Note when generated, it cannot be viewed again, so make sure to put it in the properties file so it isn't lost.
5. Copy the language files of your mod to `/resources/<the mod's FTB Wiki abbreviation>/*`. Make sure they are named correctly.
6. Run with `ruby run.rb <the mod's FTB Wiki abbreviation>` (if there are errors caused by missing gems, try doing `bundle exec ruby run.rb`).
7. Profit. Make sure to not import the tiles through your regular account, but through a bot account. If you don't, FTB Wiki editors might get angry since it spams the recent changes.

The console will output what tiles are being translated as they are translated. Example output:
```
47402; Lapis Electron Tube (item.for.thermionicTubes.lapis.name) => Tubo de electrones de Lapis (es-ni)
```

If nothing needs an update, nothing will be updated, and the output will be rather lame.
