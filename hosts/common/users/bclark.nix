{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.bclark = {
    isNormalUser = true;
    description = "bclark";
    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "flatpak"
      "audio"
      "video"
      "plugdev"
      "input"
      "kvm"
      "qemu-libvirtd"
    ];
    packages = [inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default];
  };
}
