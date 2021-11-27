# lite-xl_fountain - use lite-xl as a screenwriting app
this plugin allows you to use lite-xl as a (mostly) WYSIWYG editor for [fountain](https://fountain.io/) files

run the command `Script:open` when in a DocView to open the doc in a ScriptView.
The default shortcuts for changing the block type are similar to those in Celtx, and as follows:

---
Block Type | Shortcut
---|---
Heading | `ctrl+1`
Action | `ctrl+2`
Character / Dialogue | `ctrl+3`
Transition | `ctrl+6`
Lyrics | `ctrl+7`
Default (based on content) | `ctrl+0`
---

Of course, these can be remapped as you wish.

I recommend using [afterwriting](https://afterwriting.com/), or [its CLI](https://github.com/ifrost/afterwriting-labs/blob/master/docs/clients.md) for final rendering of your script.
You can also see [Brick & Steel](Brick & Steel.fountain) for an example of the fountain format; it was taken from the fountain spec's docs, and slightly modified by me during testing.

For info on current limitations and stuff, see [todo.md](todo.md)
