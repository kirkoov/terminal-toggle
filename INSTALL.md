# Installing ttog

`ttog` is installed as a system command and invoked automatically when a new interactive Bash shell starts.

This guide walks through a complete first-time or subsequent installation and setup.

## 1. Clone the repository

Clone the repository and enter it:

```bash
git clone https://github.com/kirkoov/terminal-toggle.git
cd terminal-toggle
```

## 2. Install `ttog`

Install the command system-wide after carefully reviewing its contents:

```bash
sudo install -m 755 ttog /usr/local/bin/ttog
```

Verify that it is available:

```bash
which ttog
```

You should see:

```text
/usr/local/bin/ttog
```

## 3. Have `ttog` run automatically

Add `ttog` to your Bash startup file:

```bash
printf '\nttog\n' >> ~/.bashrc
```

Open a new Terminal window to verify that the command is being invoked automatically.

If no configuration exists yet, `ttog` will report:

```text
ttog: no configuration found.
ttog: choose your favourite light/dark pair, running first 'ttog setup light' & then 'ttog setup dark' in the Terminal.
```

This is expected at this stage.

## 4. Choose the Terminal profile to control

**Before running the setup, choose the GNOME Terminal profile you want `ttog` to control and make that profile the default.**

This is important because `ttog setup` reads the colours from the profile that is default **at the moment setup is performed** and saves that profile's ID in its configuration.

Your current default profile may not be the one you want `ttog` to control.

In your current GNOME Terminal, open the Preferences, then:

1. Select the (create a) profile you want `ttog` to control.
2. Make it the default profile.
3. Ensure the **Use colours from system theme** is disabled for this profile.

`ttog` also disables this setting automatically when it later applies a saved colour pair, but disabling it during setup makes it clear that the profile's colours are being managed explicitly.

## 5. Choose and save the light appearance

With the desired profile now set as the default, go to the **Colours** tab and choose the colours you want to use for your controlled profile's light appearance. It's easier to pick up one from the available schemes, like GNOME, Tango, or Solarized. E.g. the 'Tango light' first, then run:

```bash
ttog setup light
```

`ttog` displays the current default profile ID and its current colour values and asks for confirmation. Answer `Y` to save them. You should see:

```text
Light appearance saved and verified.
```

## 6. Choose and save the dark appearance

Similarly, choose your dark colours now. Then run:

```bash
ttog setup dark
```

Confirm with `Y`. You will see:

```text
Dark appearance saved and verified.
```

`The two colour pairs must be different.`

## 7. Verify the installation

Open a **new Terminal window**.

`ttog` is invoked automatically when the new Bash shell starts, so the Terminal should use the colour pair corresponding to your current system appearance:

- **light system appearance** → saved light colours
- **dark system appearance** → saved dark colours

`To cross-check`: set the current system appearance to its opposite **light / dark** one and open a new Terminal window. Confirm that it follows suit.

If it does, the installation and setup are complete.

## Configuration

`ttog` stores its configuration in:

```text
~/.config/terminal-toggle/config
```

The configuration records the managed Terminal profile and its saved light and dark colours.

Changing GNOME Terminal's default profile later does **not** change the profile managed by `ttog`. To have `ttog` control a different profile, make that profile the default and run the setup commands again.

## Uninstall

Remove the installed command:

```bash
sudo rm /usr/local/bin/ttog
```

Then remove the automatic Bash invocation from ~/.bashrc. The line added during installation is: `ttog`. Remove that line from ~/.bashrc.

The `ttog` configuration remains in:

```text
~/.config/terminal-toggle/
```

Remove it separately if you no longer want to keep your saved configuration.
