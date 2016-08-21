# ATT-9001

**Automatic Tile Translator 9001**- used to automatically translate the [Official FTB Wiki's](https://ftb.gamepedia.com/FTB_Wiki) [tiles](https://ftb.gamepedia.com/Special:TileList) based on already existing language files.

## Usage
Simple steps-

1. Make sure you have Ruby.
2. Open a Terminal or whatever and change the directory to this directory.
3. Make sure you have everything in the Gemfile (`bundle install`).
4. Copy example_config.yml to config.yml. Fill in the details.
5. Copy the language files of your mod to `/resources/<the mod's FTB Wiki abbreviation>/`. Make sure they are named correctly.
6. Run with `ruby run.rb <the mod's FTB Wiki abbreviation>` (if there are errors caused by missing gems, try doing `bundle exec ruby run.rb`).
7. Profit. Make sure to not import the tiles through your regular account, but through a bot account. If you don't, the FTB Wiki Staff might get angry.

Also- the console will output what tiles are being translated as they are translated. Example output-
```
47402; Lapis Electron Tube (item.for.thermionicTubes.lapis.name) => Tubo de electrones de Lapis (es-ni)
```

If nothing needs an update, nothing will be updated, and the output will be rather lame.

## Copyright
Copyright (c) 2016 Eric Schneider (xbony2)

This project was created to be used only on the Official Feed The Beast Wiki (ftb.gamepedia.com). Please contact me if you want to use for anything else.
