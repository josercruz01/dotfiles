# Jose R Cruz's Dotfiles

Collection of dotfiles and scripts I use for customizing OS X to my liking and setting up the software development tools I use on a day-to-day basis.

They should be cloned to your home directory so that the path is `~/dotfiles/`.

Please do not run this blindly, fork it, review it and remove things you don't need. Remember, dotfiles are meant to help you
quickly setup your environment to YOUR LIKING, and more importantly, you should always be aware of what you are installing in your systems.

The setup script is smart enough to back up your existing dotfiles into a `~/dotfiles_old/` directory if you already have any dotfiles of the same name as the dotfile symlinks being created in your home directory.

So, to recap, the install script will:

- create symlinks to the dotfiles in `~/dotfiles/` in your home directory
- clone the `oh-my-zsh` repository from my GitHub (for use with `zsh`)
- check to see if `zsh` is installed, if it isn't, try to install it
- if zsh is installed, run a `chsh -s` to set it as the default shell

Environments included in these dotfiles:

* neovim
  * With NERDTree, CtrlP, Neomake, Ack/Ag (the silver searcher), etc
* tmux
* node
  * nvm
* brew
* brew cask
* many more

## Installation

```sh
$ git clone https://github.com/josercruz01/dotfiles.git ~/.dotfiles
$ cd ~/dotfiles
$ chmod +x setup.sh
$ ./setup.sh
```

## Remotely install using curl

Alternatively, you can install this into `~/.dotfiles` remotely without Git using curl:

```sh
sh -c "`curl -fsSL https://raw.github.com/josercruz01/dotfiles/master/remote-setup.sh`"
```

Or, using wget:

```sh
sh -c "`wget -O - --no-check-certificate https://raw.githubusercontent.com/josercruz01/dotfiles/master/remote-setup.sh`"
```

## OS X Defaults

OS X configuration by running the [set-defaults](osx/set-defaults.sh) script.

## Thanks

I started by forking [Nick Plekhanov's Dotfiles](https://github.com/josercruz01/dotfiles) and then applied my changes on top of it.

## License

The code is available under the [MIT license](LICENSE).
