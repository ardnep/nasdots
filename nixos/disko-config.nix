{ ... }:

{
  disko.devices.disk.system = {
    type = "disk";
    device =
      "/dev/disk/by-id/nvme-Sandisk_Optimus_GX_7100_500GB_26190C802868";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          priority = 1;
          label = "ESP";
          type = "EF00";
          start = "1M";
          size = "1024M";

          device =
            "/dev/disk/by-id/nvme-Sandisk_Optimus_GX_7100_500GB_26190C802868-part1";

          content = {
            type = "filesystem";
            format = "vfat";
            extraArgs = [ "-F" "32" ];
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };

        root = {
          priority = 2;
          label = "nixos";
          type = "8300";
          start = "1025M";
          size = "100%";

          device =
            "/dev/disk/by-id/nvme-Sandisk_Optimus_GX_7100_500GB_26190C802868-part2";

          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
