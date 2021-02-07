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

    users.extraUsers.lorne = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAxhIH5vdDwR6fsRYUFb0asa4UlVR0fQnPQ7aRjQabUtH5uWei/O7xU5d4isyKaEFc+LE0g3eAZ+IFWwh6BEZ4KIYZckpMccGWE3dWFQTN9yz9x5fRzhsnhuXBZPx1WK1JbLQLoXP6U9uJNbyVuxL5TIZQBTG0EZefTBS1RDkjPRvwpIe6IqNkEc8l86ohNPfMUClGuLtxc03gHhHQ5aJEqxDrK9mWCyeMvwH0GZ/YlupR1YdBumi5dKSjz8MaQbNLH7AdpBWsZm1k13prZ39OKspsPqM06hzLqQyzFPcxEaDqMX18607Jb9AP2g8CNPePY8d9z3H7O9VD4vNuupC4wQ== lorne@illumination"
      ];
    };
  };
}
