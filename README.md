# dotfiles

## TODO
- [ ] Use home-manager
- [ ] Use Flakes
- [ ] Xmonad Setup
- [ ] Postgres setup

## Tips

### Steam
- Add this on `~/.bashrc` or `~/.zshrc`

`export XDG_DATA_HOME="$HOME/.local/share"`

- Execute this steps to run `Steam` with Nvidia GPU
`mkdir -p ~/.local/share/applications`
`sed 's/^Exec=/&nvidia-offload /' /run/current-system/sw/share/applications/steam.desktop > ~/.local/share/applications/steam.desktop`


