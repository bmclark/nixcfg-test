{ pkgs, ... }: {
  users.users.bclark = {
    name = "bclark";
    home = "/Users/bclark";
    shell = pkgs.zsh;
  };
}
