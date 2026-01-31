set shell               := ["nu", "-c"]
set script-interpreter  := ["nu"]

default: build stow

# Build ghostty artifacts to ./.pkg/.local
[arg("profile", pattern="release|debug")]
build profile="release":
        zig build -p .pkg/.local -Doptimize=(if "{{profile}}" == "release" { "ReleaseFast" } else if "{{profile}}" == "debug" { "Debug" })
        # The build process generates the executable path from the provided prefix, which causes the
        # desktop launcher to refuse to launch. We keep them hardcoded to the bin name found in PATH.
        git restore .pkg/.local/share/applications/com.mitchellh.ghostty.desktop
        git restore .pkg/.local/share/systemd/user/app-com.mitchellh.ghostty.service
        # These ones straight up don't work and I've no clue why. Get rid of them to be safe.
        try { rm .pkg/.local/share/applications/com.mitchellh.ghostty-debug.desktop }
        try { rm .pkg/.local/share/systemd/user/app-com.mitchellh.ghostty-debug.service }

# Symlink ghostty artifacts to $HOME/.local
[script]
[arg("arg", pattern="|adopt|delete")]
stow arg="":
        if "{{arg}}" == "delete" {
                stow -D --dir=. --target=($env.HOME) .pkg
        } else if "{{arg}}" == "adopt" {
                stow -R --no-folding --dir=. --target=($env.HOME) --adopt .pkg
        } else if "{{arg}}" == "" {
                stow -R --no-folding --dir=. --target=($env.HOME) .pkg
        }

        print $"(ansi green_bold)Stow \"(pwd)\" complete.(ansi reset)"
