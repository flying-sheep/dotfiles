update:
  cd nix; NIX_CONFIG="access-tokens = github.com=$(gh auth token)" nix flake update -v --flake .

build:
  sudo darwin-rebuild switch --flake ./nix
