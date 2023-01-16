# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in
{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/dell/xps/15-9500>
      #<nixos-hardware/common/gpu/nvidia/prime.nix> 
      ./hardware-configuration.nix
      ./luks-devices-configuration.nix
      ./starship.nix
      #./emacs.nix
    ];

  # nix flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # try using overlays
  #nixpkgs.overlays = [ (import ./packages) ];

  # emacs
  services.emacs.package = pkgs.emacsUnstable;
  nixpkgs.overlays = [
    (import ./packages)
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  services.emacs.enable = false;
  services.emacs.install = true;

  # allow unfree/broken software
  nixpkgs.config.allowBroken = true;
  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    device = "nodev";
  };

  # plymouth config
  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
    themePackages = [ pkgs.adi1090x-plymouth ];
    theme = "hud_3";
  };

  # disable some logs on boot
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  
  # kernel params
   boot.kernelParams = [
     "loglevel=3" "quiet" "nouveau.modeset=0" "ibt=off" "vt.global_cursor_default=0"
  ];

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  hardware.cpu.intel.updateMicrocode = true;
  # Enable sound with pipewire. 
  sound.enable = true; 
  hardware.pulseaudio.enable = false; 
  security.rtkit.enable = true; 
  services.pipewire = { 
    enable = true; 
    alsa.enable = true; 
    alsa.support32Bit = true; 
    pulse.enable = true; 
    # If you want to use JACK applications, uncomment this 
    #jack.enable = true; 
 
    # use the example session manager (no others are packaged yet so this is enabled by default, 
    # no need to redefine it in your config for now) 
    #media-session.enable = true; 
  }; 

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  # nvidia setup
  boot.blacklistedKernelModules = [ "nouveau" "nvidiafb" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    video.hidpi.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.latest;
      nvidiaSettings = true;
      modesetting.enable = true;
      nvidiaPersistenced = true;

      prime = {
        offload.enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };

      powerManagement = {
        enable = true;
        finegrained = true;
      };
    };
  };

  # batery life
  powerManagement.powertop.enable = true;

  # host
  networking.hostName = "Niflheim";

  console = {
    keyMap = "us-acentos";
  };
  
  # time zone
  time.timeZone = "America/Sao_Paulo";

  # network
  networking.networkmanager.enable = true;

  # enable some programs
  # programs.nm-applet.enable = true;
  programs.zsh = {
    enable = true;
    # shellAliases = { ll = "ls -l"; };
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "aliases"
        "sudo"
        "direnv"
        "emacs"
        "emoji"
        "encode64"
        "jsontools"
        "systemd"
        "dirhistory"
        "colored-man-pages"
        "command-not-found"
        "extract"
        "nix"
        "ruby"
        "docker"
        "rust"
        "rails"
        "fzf"
        "tmuxinator"
        "postgres"
      ];
      customPkgs = with pkgs; [ nix-zsh-completions ];
    };
  };

  # tmux
  programs.tmux = {
    enable = true;
    clock24 = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      dracula
    ];
    extraConfig = ''
      # extra configs to tmux
      # dracula config
      set -g @dracula-show-fahrenheit false
      set -g @dracula-show-weather false
      set -g @dracula-show-battery false
      set -g @dracula-show-powerline true
      set -g @dracula-plugins "network time"
      set -g @dracula-show-timezone true
      set -g @dracula-show-left-icon 

      # window title 
      set -g set-titles on
      setw -g set-titles-string '#{b:pane_current_path}'
      
      # Binds
      # unbind C-b
      # set -g prefix M-e
      # bind -n M-a send-prefix
      bind-key -n M-x kill-pane
      bind-key -n M-n new-window 
      bind-key -n M-c new-window -c '#{pane_current_path}' 
      bind -n M-Right next-window
      bind -n M-Left previous-window
      bind-key -n M-h split-window -h -c '#{pane_current_path}'
      bind-key -n M-v split-window -v -c '#{pane_current_path}'
      bind-key -n M-o select-pane -t :.+
      bind-key M-a last-window
      bind-key -n M-f resize-pane -Z
      # bind-key -n F10 resize-pane -Z
      bind-key m set-option -g mouse on \; display 'Mouse: ON'
      bind-key M set-option -g mouse off \; display 'Mouse: OFF'
      bind-key -n S-Left select-pane -L
      bind-key -n S-Right select-pane -R
      bind-key -n S-Up select-pane -U
      bind-key -n S-Down select-pane -D
      bind-key -n C-S-Left resize-pane -L
      bind-key -n C-S-Right resize-pane -R
      bind-key -n C-S-Up resize-pane -U
      bind-key -n C-S-Down resize-pane -D
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -selection c"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "xclip -in -selection clipboard  > /dev/null"


      # create session
      bind C-c new-session
      
      # find session
      bind C-f command-prompt -p find-session 'switch-client -t %%'

      # last window
      # bind C-Tab last-window 

      set -s escape-time 0
      # set-option -g allow-rename off
      set-option -g mouse on
      set -g history-limit 10000
      setw -g mode-keys vi

      set-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'

      setw -g automatic-rename on   # rename window to reflect current program
      set -g renumber-windows on    # renumber windows when a window is closed

      set -g monitor-activity on
      set -g visual-activity off


    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.hudson = {
      isNormalUser = true;
      description = "Hudson Couto";
      createHome = true;
      home = "/home/hudson";
      shell = pkgs.zsh;
      extraGroups = ["wheel" "networkmanager" "adbusers" "audio" "video" "storage" "docker"];
      uid = 1000;
    };
  };

  # xserver/gnome config
  services.xserver = {
    enable = true;
    dpi = 110;

    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true;

    displayManager = {
      gdm.enable = true;
      gdm.wayland = false;
      gdm.autoSuspend = false;
    };
    desktopManager.gnome.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    unzip
    unrar
    gitAndTools.gitFull
    glxinfo
    nvtop-nvidia
    nvidia-offload
    vlc
    zsh
    nix-zsh-completions
    fasd
    fd
    fzf
    tldr
    ripgrep
    lolcat
    screenfetch
    tdesktop
    alacritty
    neofetch
    gimp
    inkscape
    blender
    scour
    peek
    bat
    bc
    bind
    binutils
    cached-nix-shell
    cachix
    coreutils
    direnv
    obs-studio
    clang
    curl
    dmidecode
    exa
    gcc
    gnumake
    git
    gitAndTools.gh
    speedtest-cli
    jq
    ngrok
    file
    htop
    libsecret
    libgcc
    libgccjit
    i7z
    iw
    jq
    lm_sensors
    netcat
    nix-index
    nix-tree
    openssl
    pciutils
    patchelf
    stdenv.cc.cc.lib
    tree
    vim
    wget
    zlib
    neovim
    todoist-electron
    transmission
    transmission-gtk
    starship
    tmux
    wakatime
    zoom-us
    aspellDicts.pt_BR
    aspellDicts.en
    aspell
    sd
    silver-searcher
    xsel
    xclip
    # spotify
    spotify
    evince
    xournalpp
    _1password-gui
    lua
    imagemagick
    sqlite
    glibc
    
    # elixir
    elixir
    erlang
    rebar3

    # postgres
    # postgresql_15

    # rust
    llvm
    rustup
    rust-analyzer
    sccache

    # jdk
    jdk

    # docker
    docker
    docker-compose

    # javascript
    nodejs
    nodePackages.yalc
    nodePackages.typescript-language-server
    nodePackages.javascript-typescript-langserver
    nodePackages.jsonlint
    nodePackages.yarn
    nodePackages_latest.typescript

    # libre office
    libreoffice

    # cc
    clang
    gcc
    bear
    gdb
    cmake
    llvmPackages.libcxx

    # clojure
    clojure
    joker
    leiningen

    # asdf
    asdf-vm

    # boot splash
    plymouth

    # gnome extensions
    gnomeExtensions.appindicator
    gnomeExtensions.resource-monitor
    gnomeExtensions.mpris-label
    gnomeExtensions.no-activities-button

    # steam
    steam
  ];

  # fonts
  fonts = {
    fonts = with pkgs; [
      emacs-all-the-icons-fonts
      hack-font
      roboto
      roboto-mono
      material-design-icons
      ibm-plex
      nerdfonts
      dejavu_fonts
      liberation_ttf
      roboto
      fira-code
      fira-code-symbols
      jetbrains-mono
      siji
      font-awesome
      cascadia-code
    ];
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
 
  # TODO: fprintd
  # services.fprintd.enable = true;

  # postgres
  # services.postgresql = {
  #   enable = true;
  #   authentication = pkgs.lib.mkForce "host all all 127.0.0.1/32 trust";
  #   ensureUsers = [
  #     {  name = "hudson";
  #        ensurePermissions = { "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES"; };
  #     }
  #   ];
  # };

  # docker
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    enableOnBoot = false;
  };

  # steam service config
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  # Steam Proton Config
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

