{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./hdd-disko.nix
    ./samba.nix
    ./ugreen-leds
  ];

  # Use an alternative mirror in China
  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store?priority=10"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
  ];
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Asia/Singapore";

  environment.systemPackages = with pkgs; [
    vim
    git
    gh
    yazi
    neovim
    curl
    tree-sitter
    ripgrep
    fd
    unzip
    lazygit
    zoxide
    gcc
    eza
    tmux
    direnv
    wget
    smartmontools
    lm_sensors
    i2c-tools
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.kernelModules = [ "zfs" "i2c-dev"];
  boot.zfs.requestEncryptionCredentials = [ "tank" ];

  networking.hostName = "ardnas";
  networking.hostId = "62370f7e";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      theme = "bira";
      plugins = [ "git" "vi-mode" ];

      # Change cursor based on the vim mode you're currently in
      preLoaded = ''
        VI_MODE_SET_CURSOR=true
     '';
    };
  };

  users.users.ardnep = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM34h67NEChFTnjwn4YvPNzG6MI7PGu/sVIZFXnDz454"
    ];
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "d /srv/nas/files 0700 ardnep users - -"
  ];

  system.stateVersion = "26.05";
}
