{ lib, pkgs, inputs, modulesPath, system, ... }:
{
  imports = [
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];
  nixpkgs.config.allowUnsupportedSystem = true;
  
  # Configurar o network manager
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
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
    extraGroups = ["wheel" "networkmanager"];
    isNormalUser = true;
    initialPassword = "123456789";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvBXHiSMP3IGyWxR73e8Ygo7rfT5h0zMMGKDoK8JH55FmiwolMIcqcpiLzXs4D+KogUUMtqQecMSz47ELoOn2jPdc8dT2kMtSDm3qod9MiBYg/zO4gJ0fwF2lraXCq7QVIVr9Yyjt3uIA/3vFaMSSqwAHZ5HzrvUapC32RlpUuRFpJcubcMqKal/9KfqbizboM3ppnorGpCMux9Ks+7gtw3ZCm6GM3UBX8UK4XVGeN5bzqi0CLXVM17XafPs7Ap1zPTUxLaNjSg7RRvl8Es38SvZlBnMEuyVU3GR5zLJWcTHlebrvGfj6L3aZ/mUraA5f40OW3AXeNQeX0mEq8+2cv"
    ];
  };
  users.users.tiago = {
    extraGroups = ["wheel" "networkmanager"];
    isNormalUser = true;
    initialPassword = "123456789";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIyHhxL9uKySCBDtq2U5GlDogoZfJu28vaGb2mE8/sxP"
    ];
    shell = pkgs.nushell;
  };
  environment.shells = [ pkgs.nushell ];
  users.mutableUsers = false;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 22 ];
  };
  system.stateVersion = "24.11";
  # boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  environment.systemPackages = [ pkgs.networkmanager ];
    home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = ".bkp";
  };
  programs.git.enable = true;
  services.phpfpm = {
    phpPackage = pkgs.php84;
  };
  services.httpd = {
    enable = true;
    enablePHP = true;
    virtualHosts = {
      localhost = {
        documentRoot = "${inputs.drupal-website.packages.${system}.default}/share/php/my-drupal-site/web/";
        
        listen = [
          {
            ip = "*";
            port = 80;
          }
        ];
      };
    };
    extraConfig = ''
      SetEnv DATABASE_URL postgres://postgres@127.0.0.1/drupal-site
    '';
  };
  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "tiagodinis33@proton.me";
  #   certs."cloud.pictonio.com" = {
  #     dnsProvider = "inwx";
  #     # Supplying password files like this will make your credentials world-readable
  #     # in the Nix store. This is for demonstration purpose only, do not use this in production.
  #     environmentFile = "${pkgs.writeText "inwx-creds" ''
  #       INWX_USERNAME=xxxxxxxxxx
  #       INWX_PASSWORD=yyyyyyyyyy
  #     ''}";
  #   };
  # };
  

  systemd.services.httpd.serviceConfig.User = lib.mkForce "root";

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "drupal-site" ];
    enableTCPIP = true;
    port = 5432;
    
    authentication = pkgs.lib.mkOverride 10 ''
      #...
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     127.0.0.1/32   trust
      # ipv6
      host all       all     ::1/128        trust
    '';
  };

}
