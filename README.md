# mango-monitors

A small GTK GUI for arranging your displays under [MangoWM](https://github.com/DreamMaoMao/mango).

Mango configures monitors through `monitorrule=` lines in its config file, which
is fine until you actually want to drag a screen somewhere or change a
resolution without counting pixels in your head. This is a little point-and-click
front end for that: drag the monitors into place, set their resolution / refresh
/ scale / rotation, and apply.

## Features

- Drag-to-arrange canvas with edge snapping
- Per-monitor resolution, refresh rate, scale, rotation and VRR
- Enable / disable individual outputs
- Custom mode entry for resolutions the panel doesn't advertise
- **Apply** to change the layout live, or **Save** to just write it to the config
- A 15-second "keep or revert" prompt after applying, in case a mode leaves you
  staring at a black screen
- Hotplug aware: plug or unplug a monitor and the layout updates on its own
- "Identify" sends a notification to each screen so you know which is which

## Requirements

- [MangoWM](https://github.com/DreamMaoMao/mango) (provides `mango` and `mmsg`)
- Python 3 with PyGObject, GTK 4 and libadwaita
- `wlr-randr` (recommended — used to read the full mode list and live geometry;
  without it the app falls back to `wayland-info` and the current mode only)

On Arch / CachyOS:

```sh
sudo pacman -S python-gobject gtk4 libadwaita wlr-randr
```

On Debian / Ubuntu:

```sh
sudo apt install python3-gi gir1.2-gtk-4.0 gir1.2-adw-1 wlr-randr
```

## Install

It's a single Python script — there's nothing to compile. Either run it straight
from the checkout:

```sh
./mango-monitors
```

or install it for your user (copies the script to `~/.local/bin` and adds a
desktop entry):

```sh
./install.sh
```

To remove it again:

```sh
./install.sh --uninstall
```

## How it works

- **Reading the current setup** — `wlr-randr` gives the live state of each output
  (available modes, position, scale, transform, adaptive sync). Output names come
  from `mmsg -O`.
- **Saving** — the app writes a managed block of `monitorrule=` lines into
  `~/.config/mango/config.conf`, fenced between two marker comments so it can
  rewrite just that block and leave the rest of your config alone. The first time
  it writes, it makes a `config.conf.bak-mango-monitors` backup next to it.
- **Applying** — it calls `mmsg -d reload_config`, which makes mango re-read the
  config and commit the new monitor geometry. Disabled outputs are switched off
  with `mmsg -d disable_monitor,NAME` and kept off across restarts with a small
  `exec-once` line in the managed block.
- **Hotplug** — a 2-second timer watches the output list; connecting or
  disconnecting a monitor updates the canvas while keeping any edits you've made
  to the monitors that are still attached.

The generated lines look like this:

```ini
# >>> mango-monitors (managed) — do not edit by hand >>>
monitorrule=name:^DP-1$,width:1920,height:1080,refresh:60,x:0,y:0,scale:1,rr:0,vrr:0
monitorrule=name:^eDP-1$,width:1920,height:1200,refresh:60,x:1920,y:0,scale:1,rr:0,vrr:0
# <<< mango-monitors (managed) <<<
```

You can edit them by hand too; the app just saves you the arithmetic. See mango's
[monitor documentation](https://github.com/DreamMaoMao/mango/wiki) for the full
list of `monitorrule` fields.

## Notes

- Layouts are normalised so the top-left monitor sits at `(0,0)`. XWayland
  mishandles negative output coordinates, so the app avoids them.
- The accent colours in the script are picked for a light theme. If you run a
  dark one, the handful of `ACCENT` / `CANVAS_BG` constants near the top are easy
  to change.

## License

MIT. See [LICENSE](LICENSE).
