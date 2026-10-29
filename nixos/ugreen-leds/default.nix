{ config, pkgs, ... }:

let
driver = config.boot.kernelPackages.callPackage ./package.nix { };
activityMonitor = pkgs.callPackage ./activity-package.nix { };
in
{
  boot.extraModulePackages = [ driver ];
  boot.kernelModules = [ "led-ugreen" "ledtrig-netdev" "ledtrig-oneshot"];

  systemd.services.ugreen-leds-probe = {
    description = "Register UGREEN front-panel LED controller";
    wantedBy = [ "multi-user.target" ];

    requires = [ "systemd-modules-load.service" ];
    after = [ "systemd-modules-load.service" ];

    startLimitIntervalSec = 60;
    startLimitBurst = 5;

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = "5s";
    };

    script = ''
      set -eu

      adapter=""
      count=0

      for candidate in /sys/bus/i2c/devices/i2c-*; do
        [ -r "$candidate/name" ] || continue
          read -r name < "$candidate/name"

    case "$name" in
            "SMBus I801 adapter"*)
              adapter="$candidate"
              count=$((count + 1))
              ;;
            esac
              done

              if [ "$count" -ne 1 ]; then
                echo "Expected one I801 adapter; found $count" >&2
                  exit 1
                  fi

                  bus_name="''${adapter##*/}"
                  bus_number="''${bus_name#i2c-}"
                  controller="/sys/bus/i2c/devices/$bus_number-003a"

                  if [ -e "$controller" ]; then
                    read -r device_name < "$controller/name"

                      if [ "$device_name" != "led-ugreen" ]; then
                        echo "Address 0x3a is claimed by $device_name; refusing to continue" >&2
                          exit 1
                          fi
                      else
                        echo "Registering LED controller on $bus_name"
                          printf 'led-ugreen 0x3a\n' > "$adapter/new_device"
                          fi

                          if [ ! -d /sys/class/leds/power ]; then
                            echo "UGREEN power LED was not exposed; inspect kernel logs" >&2
                              exit 1
                              fi
                              '';
  };

  systemd.services.ugreen-leds-power = {
    description = "Set UGREEN power LED";
    wantedBy = [ "multi-user.target" ];

    requires = [ "ugreen-leds-probe.service" ];
    after = [ "ugreen-leds-probe.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      echo none > /sys/class/leds/power/trigger
      echo "255 255 255" > /sys/class/leds/power/color
      echo 64 > /sys/class/leds/power/brightness
      echo none > /sys/class/leds/power/blink_type
      '';
  };

  systemd.services.ugreen-leds-network = {
    description = "Configure UGREEN network activity LED";
    wantedBy = [ "multi-user.target" ];

    requires = [ "ugreen-leds-probe.service" ];
    bindsTo = [ "sys-subsystem-net-devices-enp3s0.device" ];
    after = [
      "ugreen-leds-probe.service"
        "sys-subsystem-net-devices-enp3s0.device"
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      set -eu

      led=/sys/class/leds/netdev

      echo none > "$led/trigger"
      echo "255 255 255" > "$led/color"
      echo 64 > "$led/brightness"
      echo none > "$led/blink_type"

      echo netdev > "$led/trigger"
      echo enp3s0 > "$led/device_name"
      echo 1 > "$led/link"
      echo 1 > "$led/tx"
      echo 1 > "$led/rx"
      echo 100 > "$led/interval"
      '';
  };

  systemd.services.ugreen-leds-disks = {
    description = "Monitor UGREEN HDD activity LEDs";
    wantedBy = [ "multi-user.target" ];

    requires = [ "ugreen-leds-probe.service" ];
    after = [ "ugreen-leds-probe.service" ];

    path = [ pkgs.coreutils ];

    startLimitIntervalSec = 60;
    startLimitBurst = 5;

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    script = ''
      set -eu

      disk1_path="$(readlink -e \
      /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZBB0P9)"
      disk2_path="$(readlink -e \
      /dev/disk/by-id/ata-ST8000VN004-3CP101_WWZBAFYF)"

      disk1="$(basename "$disk1_path")"
      disk2="$(basename "$disk2_path")"

      test -r "/sys/block/$disk1/stat"
      test -r "/sys/block/$disk2/stat"

      for name in disk1 disk2; do
        led="/sys/class/leds/$name"

          echo none > "$led/trigger"
          echo none > "$led/blink_type"

          echo oneshot > "$led/trigger"
          echo 1 > "$led/invert"
          echo 100 > "$led/delay_on"
          echo 100 > "$led/delay_off"
          echo "255 255 255" > "$led/color"
          echo 64 > "$led/brightness"
          done

          for name in disk3 disk4; do
            echo none > "/sys/class/leds/$name/trigger"
              echo 0 > "/sys/class/leds/$name/brightness"
              done

              echo "Monitoring $disk1 as disk1 and $disk2 as disk2"

              exec ${activityMonitor}/bin/ugreen-blink-disk \
              0.1 "$disk1" disk1 "$disk2" disk2
              '';
  };
}
