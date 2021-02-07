{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
    ./nixos/configuration.nix
  ];

  factorio-server.password = "test-password";
}
