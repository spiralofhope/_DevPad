# I have left the game

I have left the game and this AddOn is no longer maintained; feel free to fork it.  I'm leaving things as they are so you can chat with one another via the issue ticketing system.



# _DevPad

An 
[addon](http://blog.spiralofhope.com/?p=17845)
for 
[World of Warcraft](http://blog.spiralofhope.com/?p=2987), 
a notepad for Lua scripts and mini-addons.

NOTE:  This addon requires [_DevPad.GUI](https://github.com/spiralofhope/_DevPad.GUI)

----

[source code](https://github.com/spiralofhope/_DevPad)
 · [home page](http://blog.spiralofhope.com/?p=17397)
 · [releases](https://github.com/spiralofhope/_DevPad/releases)
 · [latest beta](https://github.com/spiralofhope/_DevPad/archive/master.zip)



# Notes

- This is A fork of 
[saiket's _DevPad](https://github.com/Saiket/wow-saiket/tree/master/_DevPad).
  -  DevPad was inspired by the AddOn [Hack](https://www.wowinterface.com/downloads/info11101-Hack.html), by *Mud*.
- I am a documentation guy, not a programmer.  It is unlikely I can make any large changes.
  -  If you are a developer, I am happy to:
     -  Accept GitHub pull requests.
     -  Add you as a contributor on GitHub.
     -  Hand this project over!




# Installation

See [_DevPad.GUI](https://github.com/spiralofhope/_DevPad.GUI)



# Configuration / Usage

See [_DevPad.GUI](https://github.com/spiralofhope/_DevPad.GUI)

When you first install _DevPad, it includes an instruction manual script with a quick reference to using the AddOn.


## List Window

- Reorganize scripts and folders by dragging and dropping.
- Rename any folder or script by double clicking.
- Set scripts to auto-run by clicking the arrow buttons next to their names in the list.
  -  They will then run right after _DevPad's `ADDON_LOADED` event in the listed order.
- Search script contents using Lua patterns in the search bar below the list.


## Editor Window

- Adjust font and font size, toggle Lua mode per-script, and access other editing tools with buttons at the editor's top-right.
- Scripts in Lua mode appear syntax-highlighted
  -  Courtesy of [ForAllIndentsAndPurposes](https://www.wowinterface.com/downloads/info4895-ForAllIndentsAndPurposes.html), by *krka*.
  -  .. and reveal [UI Escape Sequences](https://wow.gamepedia.com/UI_escape_sequences) for editing directly.
- Without Lua mode, chat links in scripts become clickable, and text coloring tools appear at the editor's top-right.
- Use line numbers to navigate code.  Click a line number to select that line.
- There is no save button; script text is saved as you type.
- Undo and redo changes with the left and right arrow buttons at the top-right of the editor.
- Use familiar keyboard shortcuts to manipulate text:
  -  `control-z` / `control-shift-z` - Undo and redo.
  -  `control-g`                     - Go to line number dialog.
  -  `control-f`                     - Focus the list's search edit box.
  -  `F3` / `shift-F3`               - Jump to next/previous search result.


## Usage

There are two ways to open the list window: by keybind, or with the `/devpad` or `/pad` slash commands.

There are also two ways to run scripts as Lua code.

- With a script open, click the `play` button at the top-left of the editor window.
- Run them by name if you include a Lua pattern with the slash command, like so: `/devpad Example Script`.
  -  You can use the slash command in a macro to bind keys to _DevPad scripts.


## Sending and Receiving

You can send scripts, even entire folders, to others with the `trumpet` icon at the top of the list window.  When you receive something, you'll hear a sound and see a chat message prompting you to open your _DevPad.  Once opened, you can choose to keep or discard the new item.  Remember to always inspect what you receive from others before you run it!


## Notes

- For help writing scripts, see the default "Instruction Manual" and "Example Script" pages.
- Some _DevPad modules can be disabled.  See the bottom of `_DevPad/_DevPad.toc` and `_DevPad.GUI/_DevPad.GUI.toc`.
  -  `_DevPad.GUI/Libs/ForAllIndentsAndPurposes`: Syntax highlighting.
- By default, _DevPad comes with an "Importers" folder containing scripts to import pages from other notepad mods.
  -  WowLua, Hack, and TinyPad are currently supported; see the comments at the tops of these scripts for specific usage instructions.



# Problems and suggestions

([issues list](https://github.com/spiralofhope/_DevPad/issues))


### Problems

- If you seen an error, disable all addons but this one and re-test before creating an issue.
  -  If you have multiple addons installed, errors you think are for one addon may actually be for another.  No really, disable everything else.
- Search through [the issues list](https://github.com/spiralofhope/_DevPad/issues) before creating an issue.
- Always quote errors.
  -  There are several helpful addons to catch errors.  Try something like TekErr ([github](https://github.com/TekNoLogic/tekErr) &middot;  [wowinterface](http://www.wowinterface.com/downloads/info6681) &middot; [curse](https://mods.curse.com/project/103101) &middot; [curseforge](https://www.curseforge.com/projects/103101/))
- Do your best to give the exact steps you took to reproduce your problem.
  -  If this is only an occasional or unpredictable problem, then you'll need to do your best to give your opinion.


### Suggestions

- I am a documentation guy, not a programmer.  It is unlikely I can make any large changes.
- Describe your suggestion _really_ well.
- Explain why you want your suggestion.
  -  Do you _really really_ want it?
  -  Do you _need_ it?
  -  Are you currently doing something unusual or annoying which the feature would help simplify or make easier?
- Explain why other users would agree with your suggestion.
