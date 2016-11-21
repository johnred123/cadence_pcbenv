Author:
Evgeniy Kapustin, kap.e.v "atata" tut "dot" by
Copyright: Evgeniy Kapustin, 2011
$Revision$

Purpose:
Cadence SKILL script for defining layer visibility hotkeys.
Hotkeys are individually for each design.
Layers are combined into groups. For each group you can assign hotkey for toggle visibility of these layers.
For example:
	Layer Group:
	Name: TOP
	  DRC ERROR CLASS/TOP
	  ETCH/TOP
	  PIN/TOP
	  VIA CLASS/TOP
	Hotkey: 1
	Will be set as:
	alias TOP "color -toggle 'DRC ERROR CLASS/TOP'; color -toggle 'ETCH/TOP'; color -toggle 'PIN/TOP'; color -toggle 'VIA CLASS/TOP';"
	funckey 1 TOP
If hotkey not defined then will be set only alias with appropriate name.

Features:
+ manage hotkeys for toggle layer visibility
+ validation for added hotkeys
+ save hotkey definitions to design
+ export to text file
+ import from text file
+ buttons on form for switching group visibility
- support APD
+ set default hotkeys (without saving) for new design
+ load default hotkeys from separated file (./default.lhk or $SITE_SKILLPATH$/layerHotKey/default.lhk)

Tested:
Windows XP SP3, Allegro PCB Editor 16.5.2

Issues:
- hotkey validation not full (e.g. xxxUp - not valid)
- not validate duplicating hotkeys

Install:
1 Use auto load mechanism
- Copy folder "layerHotKey" with .il and .form files to any place (e.g. o:/Sripts).
- Define OS or Allegro environmental variable "SITE_SKILLPATH" with a value equal to the path where located folder "layerHotKey" (properly o:/Sripts).
- Load layerHotKey.il by ilinit-file or manualy by command line.
2 Use standart mechanism
- Place form files to %formpath% (e.g. "." ".../share/local/pcb/forms" ".../share/pcb/text/forms")
- Load all three files by .ilinit file or manualy by command line.
	Print in allegro command line for each file: 
	  skill load "<full path>/layerHotKey/layerHotKey*.il"
	For sripts autoload place loading commands in .../pcbenv/allegro.ilinit file:
	  load( "<full path>/layerHotKey/layerHotKey*.il" )
In case of using both, auto load has higher priority.

Usage:
- Launch the tool. Command: lhk; Menu: View->Layers HotKeys; Hot key: alt+v+k.
- For reload the default settings click Default button.
- For Group/Layer add/remove use RMB on Layer Groups tree.
- Then in HotKeys area define hot key for each Layer Group. 
- If hot key not valid then it will be red colored. 
- If hot key already defined (in "env" file, for example) then it will be yellow colored.
- Click Ok or Apply for set and save hotkeys. Not valid hotkeys (red) will not set. Already defined hot key (yellow) will be set silently, without any warnings.
- Layer Group with undefined hotkey will be set only as "alias".
- Click Cancel for exit without saving.
- For next launch of that brd-file, saved hotkey definitions will be auto set.

For better usability define funckey in "env" file for toggle all layers visibility:
  funckey 0 'settoggle gvis off on; color -globvis $gvis'

DISCLAIMER:
No any warranties. This program is free software and is available AS-IS.
There is no formal support.

Modification and Distribution:
You may redistribute and/or modify this software. In this case every improvement and enhancement should be submitted to the author.
This software can not be commercialized without the written consent of the author.


