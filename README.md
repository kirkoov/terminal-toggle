# Terminal Toggle

A small Bash utility for automatically applying your preferred light and dark colour schemes to GNOME Terminal.

`ttog` follows the system's GNOME appearance preference and applies a separately saved Terminal colour pair:

- `prefer-light` → your saved light colours
- `prefer-dark` → your saved dark colours

The colour pair is chosen by you. `ttog` does not impose a palette.

## Requirements

- Ubuntu / Linux with GNOME Terminal
- Bash
- `gsettings`

## Installation

Install `ttog` as a system command:

```bash
sudo install -m 755 ttog /usr/local/bin/ttog
```

Then verify:

```bash
which ttog
```

For the complete first-time setup procedure, see [INSTALL.md](INSTALL.md).

## Usage

Once configured, simply run:

```bash
ttog
```

`ttog` checks the current GNOME appearance and applies the corresponding saved colours.

To save the colours of the current **default GNOME Terminal profile** as your preferred light or dark appearance:

```bash
ttog setup light
ttog setup dark
```

### Important: the default Terminal profile

`ttog setup` always reads the colours from **the GNOME Terminal profile that is default at the moment setup is performed**.

`ttog` then saves that profile's ID together with the colour pair. Later, running `ttog` operates on that saved profile rather than whichever profile happens to become the GNOME Terminal default afterwards.

Therefore, choose the Terminal profile you want to control **before running `ttog setup light` / `ttog setup dark`**.

See [INSTALL.md](INSTALL.md) for the complete setup scenario.

## Configuration

The user's configuration is stored in:

```text
~/.config/terminal-toggle/config
```

It contains the selected Terminal profile and the saved light/dark colours.

The configuration belongs to the user; installing or updating the system-wide `ttog` command does not replace it.

## Behaviour

- Applies saved colours silently.
- Disables GNOME Terminal's automatic system-theme colours for the managed profile before applying the saved pair.
- Refuses to save identical light and dark colour pairs.
- Leaves other Terminal profiles untouched.
- Reports missing configuration instead of modifying Terminal settings.
- Rejects unsupported GNOME appearance values.

## Uninstallation

Remove the installed command:

```bash
sudo rm /usr/local/bin/ttog
```

The user's configuration remains in:

```text
~/.config/terminal-toggle/
```

Remove it separately if desired.

## Development

The repository contains the test suite:

```bash
./test_ttog.sh
```

Run it after making changes to `ttog`.

## Licence

MIT
