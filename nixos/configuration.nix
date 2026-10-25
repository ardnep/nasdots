{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store?priority=10"
  ];

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
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ardnas";
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

  system.stateVersion = "26.05";
}
