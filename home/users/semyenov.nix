{...}: {
  imports = [
    ../profiles/terminal.nix
    ../profiles/fish.nix
    ../profiles/omf.nix
    ../profiles/nix.nix
    ../profiles/development.nix
    ../profiles/productivity.nix
  ];

  home = {
    username = "semyenov";
    homeDirectory = "/home/semyenov";
    stateVersion = "25.05";

    # Environment variables for Chromium-based browsers to use NixOS SUID sandbox
    sessionVariables = {
      CHROME_DEVEL_SANDBOX = "/run/wrappers/bin/__chromium-suid-sandbox";
    };
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Alexander Semyenov";
    userEmail = "semyenov@hotmail.com";
    extraConfig = {
      init.defaultBranch = "master";
      core.editor = "nvim";
      pull.rebase = false;
      push.autoSetupRemote = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };
  };
}
