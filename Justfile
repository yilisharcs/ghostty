set shell               := ["nu", "-c"]
set script-interpreter  := ["nu"]

default: build stow

# Build ghostty artifacts to ./.pkg/.local
[arg("profile", pattern="release|debug")]
build profile="release":
        zig build -p .pkg/.local -Doptimize=(if "{{profile}}" == "release" { "ReleaseFast" } else if "{{profile}}" == "debug" { "Debug" })

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
