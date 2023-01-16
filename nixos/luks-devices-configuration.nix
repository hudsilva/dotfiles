{
  boot.initrd.luks.devices = {
    cryptkey = {
      device = "/dev/nvme0n1p3";
    };

    # cryptroot = {
    #   device = "/dev/nvme0n1p5";
    #   keyFile = "/dev/mapper/cryptkey";
    # };

    cryptswap = {
      device = "/dev/nvme0n1p4";
      keyFile = "/dev/mapper/cryptkey";
    };
  };
}
