{ ... }:

{
  services.samba = {
    enable = true;
    openFirewall = false;

    nmbd.enable = false;
    winbindd.enable = false;

    settings = {
      global = {
        security = "user";
        "map to guest" = "Never";
        "server min protocol" = "SMB3_00";
        "server smb encrypt" = "required";

        "hosts allow" = "127.0.0.1 ::1 192.168.100.0/24";
        "hosts deny" = "ALL";
      };

      files = {
        path = "/srv/nas/files";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "ardnep";
        "create mask" = "0600";
        "directory mask" = "0700";
      };
    };
  };

  # Modern SMB uses TCP 445; no legacy NetBIOS ports.
  networking.firewall.allowedTCPPorts = [ 445 ];

  # Require the HDD dataset before serving files.
  systemd.services.samba-smbd = {
    bindsTo = [ "srv-nas-files.mount" ];
    after = [ "srv-nas-files.mount" ];
    unitConfig.ConditionPathIsMountPoint = "/srv/nas/files";
  };
}
