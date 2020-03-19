# t6mp-scripts
A collection of T6 Plutonium Trickshotting Scripts.

## What's included

### _clientids.gsc
`This is the main mod with all the verification scripts and player damage monitoring.
(verification scripts will require work as I've removed all things related to iw4madmin)`

### _tacticalinsertion.gsc
`This is the mod to disable tactical inserts being damaged from both client entities and other means.`

### _empgrenade.gsc
`This is the mod to disable emp stun effects from disturbing clients`

---

## How does this work

1. Place the folders in your GSC Studio directory (C:\<username>\Documents\Black Ops 2 - GSC Studio)

2. Open GSC studio and export each project to a compiled script making sure you select PC as the target. 
you will need to name the exported file exactly how the folder is called otherwise the script wont load.
For example;
```ini
_clientids.gsc
_tacticalinsertion.gsc
_empgrenade.gsc
```

3. Place the exported gsc to the specified folders inside plutoniums root.
```ini
_clientids.gsc: t6r\data\maps\mp\gametypes
_tacticalinsertion.gsc: t6r\data\maps\mp
_empgrenade.gsc: t6r\data\maps\mp
```

## License

This project is covered by the MIT license.
Basically, you can do whatever you want as long as you include the original copyright and license notice in any copy of the software/source.  There are many variations of this license in use.

You can find the license [here](LICENSE).