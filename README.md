# Modding Guide (08.06.2025)

This is just a quick modding guide explaining how to use the linked tools.

## 0. Getting the tools

First extract the repository zip file into a folder of its own for example `CCS Mods`.

Go through `__tools` and read each `README.md` to know where to download the tool from and where to place it

If you just want to browse assets and extract models/textures and not create mods all you need is `__tools\FModel`.

If you want to create mods you will need everything including `__tools\Kismet-Analyzer` probably.

## 1. FModel for exploration or dumping Models/Textures

This is the easiest step and also the base for modding later as finding what you want to mod and extracting it is easiest with `FModel`.

### 1.1. Setting up the tools

1. Go to `__tools` in the files you just extracted.
2. Open `FModel` and then start `FModel.exe`
3. At the bottom of the window you can select the `CashCleanerSimulator` game folder in your steam library and name it
4. Click the blue `+` icon to add it as a selectable game and select it at the top
5. Set the version to GAME_UE5_4
6. Click `OK`

So now we are in `FModel` and can explore the Zen compressed files. We now just need to set the mappings and then we can get started with looking at models and textures as well as datamining stuff.

### 1.2. Setting up mappings in FModel

1. Click `Settings` in the ribbon menu at the top
2. Near the bottom you will see `Local Mapping File` make sure to check the box.
3. Click the `...` button behind `Mapping File Path`
4. Select `Mappings.usmap` from the `__tools` folder you extracted
5. Click `Ok` in the bottom right

Now there should be no errors or anything no matter what files you open for this game.

## 2. Converting Zen files to Legacy format

This is best as there is a script and we can just repoint `FModel` to the new folder with the legacy format assets we are making.

### 2.1. Actual conversion

1. Execute `start_tools.ps1` from the files you extracted by right clicking it (or start a terminal in the folder/navigate to it)
2. Then we run `.\convert_game.ps1 'C:\Program Files\Steam\steamapps\common\Cash Cleaner Simulator\CashCleanerSimulator\Content\Paks\' .\legacy_files\legacy_p.pak`

You will most likely have to replace `C:\Program Files\Steam` with the actual path to your steam installation/library that the game is in.

You can also store the resulting legacy file somewhere else but I personally like to have it contained in the same folder so its just easier to find.

### 2.2. Setting up FModel to use the legacy assets instead

1. Open `FModel.exe`
2. Click `Settings` in the ribbon menu at the top
3. Change `Archive Directory` to point to the folder containing the `legacy_p.pak` (or however you named it)
4. Click `Ok` in the bottom right
5. Restart `FModel` if it doesn't automatically

This means you can now browse the legacy assets and extract blueprints for UE modding tools.

Most tools don't work with the Zen format (and in general UE5 modding is not well supported from the tooling side of things)

## 3. Creating a mod

To create a mod you will now need to combine the legacy assets and stuff you extract from them together with modifying stuff in them as well as packing them back up and converting them back into the Zen format.

### 3.1. Finding what you want to mod

For our example we will use the Money Counter Euro L.

The file responsible for it is called `BP_MoneyCounterTier2_Euro`.

Finding the file you want to modify isn't always the easiest but should generally be quite easy given that you are experienced with general programming.

To search for asset names you can use `FModels` search function after opening the legacy package file and clicking `Packages` and then `Search` in the menu ribbon at the top (or by pressing `Ctrl+Shift+F`).

The file we want is located at `CashleanerSimulator/Content/Core/Object`.

To extract the wanted asset (in this case a blueprint file) we right click it and press `Export raw data (.uasset)`.

This creates the `.uasset` and the `.uexp` files we need for `UAssetGUI` to properly work later when modifying.

If you don't know where the files were stored you can check by clicking `Settings` in the ribbon menu at the top and looking at `Output directory`.

In that folder there is an `Exports` folder which then contains the exported data in the same structure as in the original legacy `.pak` file.

### 3.2. Creating a cleaner workspace for the mod

As you may extract multiple files its wise to move the files you need for a specific mod into their own folder.

For this I will assume we make a folder like `counter_mod_1234` in the folder with the scripts etc. e.g.: `CCS Mods\counter_mod_1234`.

This makes repacking it later a bit easier as the file paths can all be nice and relative.

1. Open the `counter_mod_1234`
2. Create the folder structure `CashCleanerSimulator\Content\Core\Objects\`
3. Go to the `Objects` folder
4. Paste `BP_MoneyCounterTier2_Euro.uasset`
5. Paste `BP_MoneyCounterTier2_Euro.uexp`

You should have the following files then:

- `CCS Mods\counter_mod_1234\CashCleanerSimulator\Content\Core\Objects\BP_MoneyCounterTier2_Euro.uasset`
- `CCS Mods\counter_mod_1234\CashCleanerSimulator\Content\Core\Objects\BP_MoneyCounterTier2_Euro.uexp`

If whatever you want to mod needs more files you basically just recreate the package structure under the `counter_mod_1234` folder for whatever other file you need as well.

So if you modify something in `CashCleanerSimulator/Content/Core/Market` in the legacy `.pak` file you create the file in `CCS Mods\counter_mod_1234\CashCleanerSimulator\Content\Core\Market\`.

### 3.3. Modifying data

This tutorial will only go into modifying simple data values and not logic the objects run.

This is mainly cause for logic modification you will need to poke around the kismet bytecode or the flattened JSON structure representing it.

There is currently no tooling to nicely edit UE5 blueprint kismet code.

For our example we will change the input size of the counter to be more than 600 bills.

For this we will first open `UAssetGUI` by running the `start_tools.ps1` script so we get a terminal for later when repackaging and a window of `UAssetGUI` for editing data.

In `UAssetGUI` we first make sure `5.4` is selected in the top right version selector.

Then we import the mappings by clicking `Utils` in the menu ribbon at the top and selecting `Import mappings`.

Navigate to the same `Mappings.usmap` file we used in `FModel` which should be in `CCS Mods\__tools\` (or wherever you extracted the zip file to).

This should only be required once on initial start.

You can of course check every time you start `UAssetGUI` just to be safe.

Now we wanna load `BP_MoneyCounterTIer2_Euro` into `UAssetGUI`.

For this we click `File` in the ribbon menu at the top and click `Open` (or press `Ctrl+O`).

Now that the file is loaded we can click `Edit` in the ribbon menu at the top and the `Find` (or press `Ctrl+F`).

In the find box that opens we type the amount of bills the counter can hold so `600` and then click `Next` at the bottom.

We click the `Next` button until we see something that looks like it is what we are looking for.

In this case it is when it highlights a line in a data table that has the index `1` and the name value is `MaxIncomingBillsCount`.

The Value should be `600` as thats what we knew.

In this case we can see the type for this property is `IntProperty` meaning it can range from `-2147483648` to `2147483647`.

So we enter the new amount we want the input to hold.

In this example we will choose `2000` just for demonstration purposes.

Double click the `600` field in the table.

Then replace the value with `2000`.

Clicking on `File` in the ribbon menu at the top and then `Save` (or pressing `Ctrl+S`) will save the change we made to the `.uasset` AND `.uexp` files.

### 3.4. packaging the mod

This is quite an easy step as I wrote a Powershell script to take care of all the more painful parts.

For this we can use the terminal that `start_tools.ps1` opened. We then type `pack` and press tab (or type out `.\pack.ps1`) and we will follow it up with the folder to compress.

In this case thats `.\counter_mod_1234\`. Then we specify the output filename and path.

For this example we will use the local directory and a simple name so `.\my_counter_mod_P.pak`.

Make sure that the filename ends in `_P.pak`.

Now comes already the most tricky part of this all: deciding a few things like mod priority, zipping the output, cleaning up the files if zipping and compressing the unreal `.pak` files.

Here is a list of the options
|Command line argument|Explanation|
|--|--|
|`-SourcePath`, `-src`, `-in`, `-input`|Specifies the source path if you don't specify it as the first argument of the script|
|`-OutputPath`, `-out`, `-output`|Specifies the output path if you don't specify it as the second argument of the script|
|`-compress`, `-c`|Compress the unreal `.pak` files of the mod (usually not needed)|
|`-zi[`, `-z`|Zip the unreal `.pak` files of the mod in a same name zip file as the `.pak` files|
|`-removeFiles`, `-cleanup`|Cleanup the `.pak` files to only leave the finished `.zip` file|
|`-priority`, `-p`, `-prio`|Specify a load order priority for UE to follow when loading all game mods|

For example if we want to set out mod to priority `10` so it loads after other mods with a lower priority that may also modify the exact same file we do, we would run `.\pack.ps1 .\money_counter_1234\ .\my_counter_mod_P.pak -p 10`.

If we want to zip the output it is `.\pack.ps1 .\money_counter_1234\ .\my_counter_mod_P.pak -z` or (`.\pack.ps1 .\money_counter_1234\ .\my_counter_mod_P.pak -z -cleanup` if we want to delete the files we zipped).

Of course these can be combined as well into `.\pack.ps1 .\money_counter_1234\ .\my_counter_mod_P.pak -p 10 -z -cleanup` so we give a priority, zip the files and then delete the files we zipped.

## 4. Using the mod

To use the mod we place the `.pak`, `.utoc` and `.ucas` files we created into `C:\Program Files\Steam\steamapps\common\Cash Cleaner Simulator\CashCleanerSimulator\Content\Paks\~mods`.

The folder `~mods` is mainly chosen as a sort of community convention of Unreal Engine game mods.

The mods will load when just putting them in `Paks` but it keeps it nice and clean if they just go into `~mods` especially if the game expands to have more `.pak`, `.utoc` and `.ucas` files itself instead of 1 monolithic file as it does now.

## 5. Special section for people adventurous enough to try kismet modding

There is a tool included in this for generating kismet graphs (one of the few tools that work with UE5 kismet blueprints).

To use it just run `.\__tools\Kismet-Analyzer\kismet-analyzer.exe cfg .\counter_mod_1234\CashCleanerSimulator\Content\Core\Objects\BP_MoneyCounterTier2_Euro.uasset --ue-version VER_UE5_4 -m .\__tools\Mappings.usmap --dot .\__tools\Graphviz\bin\dot.exe`.

The path of `.\counter_mod_1234\CashCleanerSimulator\Content\Core\Objects\BP_MoneyCounterTier2_Euro.uasset` is from the example above just to have an example in general.

This will generate an HTML file with a graph explorer.

I wish you the best of luck navigating it and trying to not lose your sanity.

If you are talented and want to help please try and update [KismetKompiler](https://github.com/tge-was-taken/KismetKompiler) or try to figure out LUA/C++ mods via [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) as these are the most viable strategies for better mods and especially more mods in the future.

Most people probably wont try to poke at the Kismet code as it stands.

If you found what you want to mod you need to open the blueprint in `UAssetGUI` then click `File` in the ribbon menu at the top and select `Save as`.

Then make sure to save the file as a `.json` preferably of the same name as the `.uasset` file.

Edit the kismet code in the `.json` file.

Open the `.json` file in `UAssetGUI` via `File` in the ribbon menu at the top and clicking `Open`. Then select the `.json` to open.

After its opened you go to `File` in the ribbon menu at the top and click `Save` (or pressing `Ctrl+S`).

If you didn't name the `.json` file like the `.uasset` file you need to go to `File` in the ribbon menu at the top and click `Save as`.

Then make sure to save it as the `.uasset` you originally wanted to mod.

The packing is the same as simple property modifications in section `3.4`
