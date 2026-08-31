# ttog

Short for a Terminal toggle, it's a small Bash utility for automatically applying your preferred light and dark colour scheme pair -organic to the system (e.g. GNOME, Tango, and Solarized)- to your Terminal which follows your current system appearance (light or dark) once you open a new Terminal window.

The colour pair is initially chosen by you via `ttog setup`, the `Use colours from system theme` is unticked and no palette is imposed.

## Features

- Applies saved colours silently
- Disables GNOME Terminal's automatic system-theme colours for the managed profile before applying the saved pair
- Refuses to save identical light and dark colour pairs
- Leaves other Terminal profiles untouched
- Reports missing configuration instead of modifying Terminal settings
- Rejects unsupported GNOME appearance values.
- Development includes a test suite to quickly confirm refactoring.

### Important: the default Terminal profile

`ttog setup` always reads the colours from **the GNOME Terminal profile that is default at the moment setup is performed**.

`ttog` then saves that profile's ID together with the colour pair to a

```text
~/.config/terminal-toggle/config
```

Later, running `ttog` operates on that saved profile rather than whichever profile happens to become the GNOME Terminal default afterwards.

Therefore, choose the Terminal profile and its light/dark appearance you want to control **BEFORE running `ttog setup light` / `ttog setup dark`**.

See [INSTALL.md](INSTALL.md)/OR ELSEWHERE for the complete setup scenario.

## Requirements

- Ubuntu 22(???) / Linux with GNOME Terminal
- Bash
- `gsettings`

## Installation

<!-- Install `ttog` as a system command:

```bash
sudo install -m 755 ttog /usr/local/bin/ttog
```

Then verify:

```bash
which ttog
```

For the complete first-time setup procedure, see [INSTALL.md](INSTALL.md). -->

### Maybe it's wiser to include the entire installation right here vs creating a separate INSTALL.md or is the latter gonna be huge for this? We'll see tho

## Usage

**_Once installed and configured_** as detailed above, simply open a new Terminal window and **it should be light or dark as your current system appearance**.

In case you need to resave another colour pair for your current **default GNOME Terminal profile** or you need `ttog` operating under another default profile, re-do the setup steps from above.

## Uninstall

Remove the installed command:

```bash
sudo rm /usr/local/bin/ttog
```

The user's configuration remains in:

```text
~/.config/terminal-toggle/
```

Remove it separately if desired.

## Licence

MIT as per the [LICENCE](LICENCE) file.
