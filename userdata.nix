{ config, pkgs, lib, options, ... }:

let
  versionHashes = {
    "0.16.51" = "0zrnpg2js0ysvx9y50h3gajldk16mv02dvrwnkazh5kzr1d9zc3c";
    "0.17.31" = "16w536i9fx621xb4x07dvfmsp31wjdfm256kj8b3i84pfqlrvwhg";
    "0.17.32" = "1jfjbb0v7yiqpn7nxkr4fcd1rsz59s8k6qcl82d1j320l3y7nl9w";
    "0.17.33" = "0dixy643lxhj1p6pa54f23rg8rngvccvrpfcml3ipkbrg4qw6k8y";
  };

  factorioVersionOverlay = version: self: super: {
    factorio-headless = super.factorio-headless.overrideAttrs (attrs: {
      name = "factorio-headless-${version}";
      src = pkgs.fetchurl {
         name = "factorio-headless-${version}.tar.xz";
         url = "https://factorio.com/get-download/${version}/headless/linux64";
         sha256 = versionHashes."${version}";
       };
    });
  };

  containers = {
    factorio = {
      ordinal = 0;
      version = "0.16.51";
      factorioConfig = {
        game-password = "REDACTED";
        saveName = "MultiplayerWithLuke";
      };
    };

    factorio-stephen = {
      ordinal = 1;
      version = "0.17.32";
      factorioConfig = {
        game-password = "REDACTED";
        saveName = "Stephen";
      };
    };
  };
in

with lib;

let

  factorioConfigs = (flip mapAttrsToList containers (name: { ordinal, version, factorioConfig }:
    let
      port = options.services.factorio.port.default + ordinal;
    in
  {
    networking.firewall.allowedUDPPorts = [ port ];

    containers."${name}" = {
      autoStart = true;

      config = {
        nixpkgs.config.allowUnfree = true;

        nixpkgs.overlays = [
          (factorioVersionOverlay version)
        ];

        services.factorio = ({
          enable = true;
          inherit port;
          game-name = "${name}@aws";
          game-password = "REDACTED";
          saveName = name;
        } // factorioConfig);
      };
    };
  }));

in

{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
  ];

  config = mkMerge (factorioConfigs ++ [{
    services.openssh.passwordAuthentication = false;

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
  }]);
}
