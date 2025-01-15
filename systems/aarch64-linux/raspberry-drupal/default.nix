{ lib, pkgs, inputs, ... }:
{
  imports = [
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
    inputs.raspberry-pi-nix.nixosModules.sd-image
  ];
  systemd.network.enable = true;
  systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = null;
      UseDns = true;
    };
  };
  users.users.chicodasilva = {
    name = "chicodasilva";
    
    isNormalUser = true;
    initialPassword = "123456789";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvBXHiSMP3IGyWxR73e8Ygo7rfT5h0zMMGKDoK8JH55FmiwolMIcqcpiLzXs4D+KogUUMtqQecMSz47ELoOn2jPdc8dT2kMtSDm3qod9MiBYg/zO4gJ0fwF2lraXCq7QVIVr9Yyjt3uIA/3vFaMSSqwAHZ5HzrvUapC32RlpUuRFpJcubcMqKal/9KfqbizboM3ppnorGpCMux9Ks+7gtw3ZCm6GM3UBX8UK4XVGeN5bzqi0CLXVM17XafPs7Ap1zPTUxLaNjSg7RRvl8Es38SvZlBnMEuyVU3GR5zLJWcTHlebrvGfj6L3aZ/mUraA5f40OW3AXeNQeX0mEq8+2cv"
    ];
  };
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
  };
  raspberry-pi-nix.board = "bcm2711";
  hardware = {
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            BOOT_UART = {
              value = 1;
              enable = true;
            };
            uart_2ndstage = {
              value = 1;
              enable = true;
            };
          };
          dt-overlays = {
            disable-bt = {
              enable = true;
              params = { };
            };
          };
        };
      };
    };
  };
  system.stateVersion = "24.11";
  services.httpd = {
    enable = true;
  };
}
