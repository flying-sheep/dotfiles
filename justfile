update:
  cd nix; nix flake update -v --flake .

build:
  sudo darwin-rebuild switch --flake ./nix
