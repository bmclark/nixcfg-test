# agenix secrets configuration.
# Each secret is encrypted with the listed public keys.
# Usage:
#   1. Add your SSH public key below
#   2. Define secrets: "secret-name.age".publicKeys = [keys...]
#   3. Encrypt: cd secrets && agenix -e secret-name.age
#   4. Reference in NixOS config: age.secrets.secret-name.file = ../secrets/secret-name.age;
#
# See: https://github.com/ryantm/agenix#tutorial
let
  # Add your SSH public keys here (from ~/.ssh/id_ed25519.pub or similar)
  # bclark = "ssh-ed25519 AAAA...";
  # maverick = "ssh-ed25519 AAAA..."; # host key from /etc/ssh/ssh_host_ed25519_key.pub
in {
  # Example:
  # "wifi-passwords.age".publicKeys = [bclark maverick];
  # "api-tokens.age".publicKeys = [bclark maverick];
}
