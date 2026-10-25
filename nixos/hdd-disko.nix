{ ... }:

let
  mkHdd = device: {
    type = "disk";
    inherit device;

    content = {
      type = "gpt";

      partitions.zfs = {
        size = "100%";
        type = "BF01";

        content = {
          type = "zfs";
          pool = "tank";
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      hdd1 = mkHdd
        "/dev/disk/by-id/ata-ST8000VN004-3CP101_WWZBB0P9";

      hdd2 = mkHdd
        "/dev/disk/by-id/ata-ST8000VN004-3CP101_WWZBAFYF";
    };

    zpool.tank = {
      type = "zpool";
      mode = "mirror";

      options.ashift = "12";

      rootFsOptions = {
        mountpoint = "none";
        canmount = "off";
        compression = "lz4";
        atime = "off";

        encryption = "aes-256-gcm";
        keyformat = "raw";
        keylocation = "file:///var/lib/zfs/keys/tank-files.key";
      };

      datasets.files = {
        type = "zfs_fs";
        mountpoint = "/srv/nas/files";

        options = {
          mountpoint = "legacy";
          acltype = "posixacl";
          xattr = "sa";
        };
      };
    };
  };
}
