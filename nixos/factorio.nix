{ config, pkgs, lib, options, ... }:

let
  cfg = config.factorio-server;

  basePort = options.services.factorio.port.default;

  versionHashes = {
    "0.16.51" = "0zrnpg2js0ysvx9y50h3gajldk16mv02dvrwnkazh5kzr1d9zc3c";
    "0.17.31" = "16w536i9fx621xb4x07dvfmsp31wjdfm256kj8b3i84pfqlrvwhg";
    "0.17.32" = "1jfjbb0v7yiqpn7nxkr4fcd1rsz59s8k6qcl82d1j320l3y7nl9w";
    "0.17.33" = "0dixy643lxhj1p6pa54f23rg8rngvccvrpfcml3ipkbrg4qw6k8y";
    "0.17.34" = "0lnlbvd6ziwna8cqwj7v1mcv4jrca45x0kws9aydsq77r8adz267";
    "0.17.52" = "03nv0qagv5pmqqbisf0hq6cb5rg2ih37lzkvcxihnnw72r78li94";
    "0.17.69" = "1ar7ldzyyln9sbiilf6zwkkm45x5b54zwnd6hb33aa8zi62svng4";
    "0.17.79" = "1pr39nm23fj83jy272798gbl9003rgi4vgsi33f2iw3dk3x15kls";
    "0.18.18" = "1ni71p60cz1x07gj5syyamyk1k4d4xfsvdmd4p334w556ka9mvaf";
    "1.0.0"   = "0r0lplns8nxna2viv8qyx9mp4cckdvx6k20w2g2fwnj3jjmf3nc1";
    "1.1.19"  = "0w0ir1dzx39vq1w09ikgw956q1ilq6n0cyi50arjhgcqcg44w1ks";
    "1.1.57"  = "sha256-tWHdy+T2mj5WURHfFmALB+vUskat7Wmeaeq67+7lxfg=";
    "1.1.59"  = "1p5wyki6wxnvnp7zqjjw9yggiy0p78rx49wmq3q7kq0mxfz054dg";
  };

  setFactorioVersion = version: drv: drv.overrideAttrs (attrs: {
    name = "factorio-headless-${version}";
    src = pkgs.fetchurl {
       name = "factorio-headless-${version}.tar.xz";
       url = "https://factorio.com/get-download/${version}/headless/linux64";
       sha256 = versionHashes."${version}";
     };
  });

  containers = {
    "factorio-speedrun" = let
      mapConfig = lib.mapAttrs
        (key: value: pkgs.writeText "${key}.json" (builtins.toJSON value))
        (builtins.fromJSON (builtins.readFile ./map.json));
    in rec {
      ordinal = 0;
      version = "1.1.59";
      factorioConfig = {
        game-password = cfg.password;
        saveName = "Speedrun";
      };
      nixosConfig = { config, lib, ... }: let
        cfg = config.services.factorio;
        stateDir = "/var/lib/factorio";
        savePath = "${stateDir}/saves/${factorioConfig.saveName}.zip";
      in {
        systemd.services.factorio.preStart = lib.mkForce ''
          if [ ! -e ${savePath} ]; then
            ${cfg.package}/bin/factorio \
              --config=${cfg.configFile} \
              --create=${savePath} \
              --map-settings=${mapConfig.map_settings} \
              --map-gen-settings=${mapConfig.map_gen_settings}
          fi
        '';
      };
    };
  };


  factorioContainerConfig = name: { ordinal, version, factorioConfig, nixosConfig ? {} }:
    let
      port = basePort + ordinal;
    in
  {
    networking.firewall.allowedUDPPorts = [ port ];

    containers."${name}" = {
      autoStart = true;

      config = { pkgs, ... }: {
        imports = [
          nixosConfig
        ];

        nixpkgs.config.allowUnfree = true;

        services.factorio = ({
          enable = true;
          inherit port;
          game-name = "${name}@aws";
          saveName = name;
          package = setFactorioVersion version pkgs.factorio-headless;
          nonBlockingSaving = true;
          admins = [ "thefloweringash" ];
        } // factorioConfig);
      };
    };
  };
in

with lib;

{
  options = {
    factorio-server = {
      password = mkOption { type = types.str; };
    };
  };

  config = mkMerge (mapAttrsToList factorioContainerConfig containers);
}
