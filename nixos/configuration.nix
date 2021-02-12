{ config, pkgs, lib, options, ... }:

{
  imports = [
    ./factorio.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;

    services.openssh.passwordAuthentication = false;
    services.openssh.challengeResponseAuthentication = false;

    security.sudo.wheelNeedsPassword = false;

    environment.systemPackages = with pkgs; [ vim rsync ];

    programs.zsh.enable = true;

    users.extraUsers.stephen = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDskyOUsaGaSAzQUtIqWfbrJVhR83JmLkQoNvkzBe+6U stephen@umber.local"
      ];
    };
  };
}
