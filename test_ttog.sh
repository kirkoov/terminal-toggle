#!/usr/bin/env bash

GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'
ORIGINAL_APPEARANCE=$(gsettings get org.gnome.desktop.interface color-scheme)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TTog="$SCRIPT_DIR/ttog"
CONFIG_FILE="$HOME/.config/terminal-toggle/config"
PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
CONFIGURED_PROFILE=$(grep '^PROFILE=' "$CONFIG_FILE" | tail -1 | cut -d= -f2- | tr -d "'")
gsettings set org.gnome.Terminal.ProfilesList default "'$CONFIGURED_PROFILE'"

cleanup() {
	gsettings set org.gnome.Terminal.ProfilesList default "'$PROFILE'"
	gsettings set org.gnome.desktop.interface color-scheme "$ORIGINAL_APPEARANCE"
}

# Restore the system appearance when the test suite exits.
trap cleanup EXIT

pass() {
	printf '%s: %b✓ PASS%b\n' "$1" "$GREEN" "$RESET"
}

fail() {
	printf '%s: %b✗ FAILED%b\n' "$1" "$RED" "$RESET"
	shift
	printf '  %s\n' "$@"
	exit 1
}

# get_terminal_colours() {
# 	background=$(gsettings get "$PROFILE_PATH" background-color)
# 	foreground=$(gsettings get "$PROFILE_PATH" foreground-color)
# }

get_terminal_colours() {
	PROFILE=$(grep '^PROFILE=' "$CONFIG_FILE" | tail -1 | cut -d= -f2- | tr -d "'")
	PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
	background=$(gsettings get "$PROFILE_PATH" background-color)
	foreground=$(gsettings get "$PROFILE_PATH" foreground-color)
}

pref_dark() {
	gsettings set org.gnome.desktop.interface color-scheme prefer-dark
}

pref_light() {
	gsettings set org.gnome.desktop.interface color-scheme prefer-light
}

test_appearance() {
	local test_name="$1"
	local appearance="$2"
	local expected_bg="$3"
	local expected_fg="$4"

	gsettings set org.gnome.desktop.interface color-scheme "$appearance"

	output=$("$TTog" 2>&1)
	status=$?

	get_terminal_colours

	if [[ "$status" -eq 0 &&
		-z "$output" &&
		"$background" == "$expected_bg" &&
		"$foreground" == "$expected_fg" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output" \
			"background: $background" \
			"foreground: $foreground"
	fi
}

test_invalid_arguments() {
	local test_name="invalid arguments"

	output=$("$TTog" nonsense 2>&1)
	status=$?

	if [[ "$status" -eq 1 &&
		"$output" == "Usage: ttog [setup light|dark]" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output"
	fi
}

test_prefer_dark() {
	test_appearance \
		"prefer-dark applies saved colours silently" \
		prefer-dark \
		"'rgb(46,52,54)'" \
		"'rgb(211,215,207)'"
}

test_prefer_light() {
	test_appearance \
		"prefer-light applies saved colours silently" \
		prefer-light \
		"'rgb(238,238,236)'" \
		"'rgb(46,52,54)'"
}

test_missing_dark_configuration() {
	local test_name="missing dark configuration is reported"

	CONFIG_BACKUP="$CONFIG_FILE.test-backup"
	cp "$CONFIG_FILE" "$CONFIG_BACKUP"
	cat >"$CONFIG_FILE" <<'EOF'
PROFILE='0037f5a2-e87b-44ee-b64b-0a93c9450ac8'
LIGHT_BG='rgb(238,238,236)'
LIGHT_FG='rgb(46,52,54)'
EOF
	pref_dark
	output=$("$TTog" 2>&1)
	status=$?
	mv "$CONFIG_BACKUP" "$CONFIG_FILE"
	if [[ "$status" -eq 0 &&
		"$output" == $'ttog: dark appearance is not configured.\nttog: run \'ttog setup dark\' first.' ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output"
	fi
}

test_missing_light_configuration() {
	local test_name="missing light configuration is reported"
	local config_backup="$CONFIG_FILE.test-backup"

	mv "$CONFIG_FILE" "$config_backup"

	cat >"$CONFIG_FILE" <<'EOF'
PROFILE='0037f5a2-e87b-44ee-b64b-0a93c9450ac8'
DARK_BG='rgb(46,52,54)'
DARK_FG='rgb(211,215,207)'
EOF

	pref_light

	output=$("$TTog" 2>&1)
	status=$?

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 0 &&
		"$output" == $'ttog: light appearance is not configured.\nttog: run \'ttog setup light\' first.' ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output"
	fi
}

test_missing_configuration() {
	local test_name="missing configuration is reported"
	local config_backup="$CONFIG_FILE.test-backup"

	mv "$CONFIG_FILE" "$config_backup"

	output=$("$TTog" 2>&1)
	status=$?

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 0 &&
		"$output" == $'ttog: no configuration found.\nttog: choose your favourite light/dark pair, running first \'ttog setup light\' & then \'ttog setup dark\' in the Terminal.' ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output"
	fi
}

test_setup_light() {
	local test_name="setup light saves current colours"
	local config_backup="$CONFIG_FILE.test-backup"
	local expected_bg="'rgb(238,238,236)'"
	local expected_fg="'rgb(46,52,54)'"

	cp "$CONFIG_FILE" "$config_backup"

	gsettings set "$PROFILE_PATH" use-theme-colors false
	gsettings set "$PROFILE_PATH" background-color "$expected_bg"
	gsettings set "$PROFILE_PATH" foreground-color "$expected_fg"

	output=$(printf 'Y\n' | "$TTog" setup light 2>&1)
	status=$?

	light_bg=$(grep '^LIGHT_BG=' "$CONFIG_FILE" | cut -d= -f2-)
	light_fg=$(grep '^LIGHT_FG=' "$CONFIG_FILE" | cut -d= -f2-)

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 0 &&
		"$light_bg" == "$expected_bg" &&
		"$light_fg" == "$expected_fg" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output" \
			"saved background: $light_bg" \
			"saved foreground: $light_fg"
	fi
}

test_setup_dark() {
	local test_name="setup dark saves current colours"
	local config_backup="$CONFIG_FILE.test-backup"
	local expected_bg="'rgb(46,52,54)'"
	local expected_fg="'rgb(211,215,207)'"

	cp "$CONFIG_FILE" "$config_backup"

	gsettings set "$PROFILE_PATH" use-theme-colors false
	gsettings set "$PROFILE_PATH" background-color "$expected_bg"
	gsettings set "$PROFILE_PATH" foreground-color "$expected_fg"

	output=$(printf 'Y\n' | "$TTog" setup dark 2>&1)
	status=$?

	dark_bg=$(grep '^DARK_BG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
	dark_fg=$(grep '^DARK_FG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 0 &&
		"$dark_bg" == "$expected_bg" &&
		"$dark_fg" == "$expected_fg" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output" \
			"saved background: $dark_bg" \
			"saved foreground: $dark_fg"
	fi
}

test_setup_light_rejects_dark_colours() {
	local test_name="setup light rejects colours identical to dark"
	local config_backup="$CONFIG_FILE.test-backup"
	local expected_bg="'rgb(46,52,54)'"
	local expected_fg="'rgb(211,215,207)'"

	cp "$CONFIG_FILE" "$config_backup"

	gsettings set "$PROFILE_PATH" use-theme-colors false
	gsettings set "$PROFILE_PATH" background-color "$expected_bg"
	gsettings set "$PROFILE_PATH" foreground-color "$expected_fg"

	output=$(printf 'Y\n' | "$TTog" setup light 2>&1)
	status=$?

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 1 &&
		"$output" == *"ERROR: light appearance is identical to the saved dark appearance."* ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output"
	fi
}

test_setup_dark_rejects_light_colours() {
	local test_name="setup dark rejects colours identical to light"
	local config_backup="$CONFIG_FILE.test-backup"
	local expected_bg="'rgb(238,238,236)'"
	local expected_fg="'rgb(46,52,54)'"

	cp "$CONFIG_FILE" "$config_backup"

	gsettings set "$PROFILE_PATH" use-theme-colors false
	gsettings set "$PROFILE_PATH" background-color "$expected_bg"
	gsettings set "$PROFILE_PATH" foreground-color "$expected_fg"

	output=$(printf 'Y\n' | "$TTog" setup dark 2>&1)
	status=$?

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 1 &&
		"$output" == *"ERROR: dark appearance is identical to the saved light appearance."* ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output"
	fi
}

test_setup_declined() {
	local appearance="$1"
	local test_name="setup $appearance declined leaves configuration unchanged"
	local config_backup="$CONFIG_FILE.test-backup"
	local config_before
	local config_after

	cp "$CONFIG_FILE" "$config_backup"
	config_before=$(cat "$CONFIG_FILE")

	output=$(printf 'N\n' | "$TTog" setup "$appearance" 2>&1)
	status=$?

	config_after=$(cat "$CONFIG_FILE")

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 0 &&
		"$output" == *"Nothing saved."* &&
		"$config_after" == "$config_before" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output" \
			"configuration changed: $([[ "$config_after" != "$config_before" ]] && echo yes || echo no)"
	fi
}

test_unsupported_appearance() {
	local test_name="unsupported system appearance is rejected"

	gsettings set org.gnome.desktop.interface color-scheme default

	output=$("$TTog" 2>&1)
	status=$?

	if [[ "$status" -eq 1 &&
		"$output" == "System appearance is not explicitly light or dark." ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output"
	fi
}

test_disables_theme_colours() {
	local test_name="ttog disables system theme colours before applying setup"

	pref_dark
	gsettings set "$PROFILE_PATH" use-theme-colors true

	output=$("$TTog" 2>&1)
	status=$?

	theme_colours=$(gsettings get "$PROFILE_PATH" use-theme-colors)

	if [[ "$status" -eq 0 &&
		-z "$output" &&
		"$theme_colours" == "false" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output" \
			"use-theme-colors: $theme_colours"
	fi
}

test_setup_preserves_other_appearance() {
	local appearance="$1"
	local test_name="setup $appearance preserves the other appearance"
	local config_backup="$CONFIG_FILE.test-backup"
	local other_bg
	local other_fg
	local expected_bg
	local expected_fg

	cp "$CONFIG_FILE" "$config_backup"

	if [[ "$appearance" == "light" ]]; then
		other_bg=$(grep '^DARK_BG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
		other_fg=$(grep '^DARK_FG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
		expected_bg="'rgb(255,255,255)'"
		expected_fg="'rgb(0,0,0)'"
	else
		other_bg=$(grep '^LIGHT_BG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
		other_fg=$(grep '^LIGHT_FG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
		expected_bg="'rgb(30,30,30)'"
		expected_fg="'rgb(240,240,240)'"
	fi

	gsettings set "$PROFILE_PATH" use-theme-colors false
	gsettings set "$PROFILE_PATH" background-color "$expected_bg"
	gsettings set "$PROFILE_PATH" foreground-color "$expected_fg"

	output=$(printf 'Y\n' | "$TTog" setup "$appearance" 2>&1)
	status=$?

	if [[ "$appearance" == "light" ]]; then
		saved_bg=$(grep '^DARK_BG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
		saved_fg=$(grep '^DARK_FG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
	else
		saved_bg=$(grep '^LIGHT_BG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
		saved_fg=$(grep '^LIGHT_FG=' "$CONFIG_FILE" | tail -1 | cut -d= -f2-)
	fi

	mv "$config_backup" "$CONFIG_FILE"

	if [[ "$status" -eq 0 &&
		"$saved_bg" == "$other_bg" &&
		"$saved_fg" == "$other_fg" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output" \
			"original background: $other_bg" \
			"saved background: $saved_bg" \
			"original foreground: $other_fg" \
			"saved foreground: $saved_fg"
	fi
}

test_different_default_profile_is_untouched() {
	local test_name="different default profile is left untouched"
	local old_profile='b1dcc9dd-5262-4d8d-a863-c897e6d979b9'
	local old_profile_path="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$old_profile/"
	local expected_bg="'rgb(238,238,236)'"
	local expected_fg="'rgb(46,52,54)'"

	gsettings set "$old_profile_path" use-theme-colors false
	gsettings set "$old_profile_path" background-color "$expected_bg"
	gsettings set "$old_profile_path" foreground-color "$expected_fg"

	gsettings set org.gnome.Terminal.ProfilesList default "'$old_profile'"
	pref_dark

	output=$("$TTog" 2>&1)
	status=$?

	background=$(gsettings get "$old_profile_path" background-color)
	foreground=$(gsettings get "$old_profile_path" foreground-color)

	gsettings set org.gnome.Terminal.ProfilesList default "'$CONFIGURED_PROFILE'"

	if [[ "$status" -eq 0 &&
		-z "$output" &&
		"$background" == "$expected_bg" &&
		"$foreground" == "$expected_fg" ]]; then
		pass "$test_name"
	else
		fail "$test_name" \
			"exit status: $status" \
			"output: $output" \
			"background: $background" \
			"foreground: $foreground"
	fi
}

main() {
	test_invalid_arguments
	test_prefer_dark
	test_prefer_light
	test_missing_dark_configuration
	test_missing_light_configuration
	test_missing_configuration
	test_setup_light
	test_setup_dark
	test_setup_light_rejects_dark_colours
	test_setup_dark_rejects_light_colours
	test_setup_declined light
	test_setup_declined dark
	test_unsupported_appearance
	test_disables_theme_colours
	test_setup_preserves_other_appearance light
	test_setup_preserves_other_appearance dark
	test_different_default_profile_is_untouched
}

main
