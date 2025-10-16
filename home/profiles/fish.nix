{...}: {
  # Fish shell configuration
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Hide direnv log lines, keep user echo output visible
      set -gx DIRENV_LOG_FORMAT ""

      # GnuPG agent environment
      set -gx GPG_TTY (tty)
      set -gx SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent >/dev/null 2>/dev/null
      gpg-connect-agent updatestartuptty /bye >/dev/null 2>/dev/null

      # Initialize zoxide for smarter cd
      if command -v zoxide >/dev/null
        zoxide init fish | source
      end
    '';

    shellAliases = {
      # File operations (f-)
      fl = "lsd -l --color=always";
      fa = "lsd -la --color=always";
      fs = "lsd --color=always";
      f1 = "lsd -1 --color=always";
      ft = "lsd --tree --color=always";
      fc = "bat --style=auto --paging=never";
      fg = "rg --color=always";
      ff = "fd --color=always";
      fsd = "sd";
      fd = "dust --color=always";
      fdf = "duf --color=always";
      fp = "procs --color=always";
      ftop = "btm --color=always";
      fh = "btm --color=always";
      fdig = "dog --color=always";
      fcurl = "httpie";
      fwget = "httpie";
      fman = "tldr";
      fcp = "cp -i";
      fmv = "mv -i";
      frm = "rm -i";
      fmk = "mkdir -p";
      frd = "rmdir";

      # Git operations (g-)
      g = "git";
      gg = "gitu";
      glg = "lazygit";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gb = "git branch";
      gco = "git checkout";
      gcm = "git checkout main";
      gcd = "git checkout develop";
      gst = "git stash";
      gsp = "git stash pop";
      gr = "git rebase";
      gm = "git merge";
      gf = "git fetch";
      gcl = "git clone";
      gsh = "git show";
      glog = "git log --oneline --graph --decorate";
      gclean = "git clean -fd";
      greset = "git reset --hard HEAD";

      # NixOS operations (n-)
      nr = "sudo nixos-rebuild switch --flake .#";
      nrb = "sudo nixos-rebuild boot --flake .#";
      nrt = "sudo nixos-rebuild test --flake .#";
      nu = "nix flake update";
      nul = "nix flake lock --update-input";
      nc = "sudo nix-collect-garbage -d";
      nco = "sudo nix-collect-garbage --delete-old";
      ng = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      ns = "nix search nixpkgs";
      nsh = "nix-shell";
      nd = "nix develop";
      nfc = "nix flake check";
      nfs = "nix flake show";
      nfl = "nix flake lock";

      # System utilities (s-)
      sr = "source ~/.config/fish/config.fish";
      sp = "echo $PATH | tr ' ' '\n'";
      sport = "netstat -tulpn";
      sip = "curl -s ifconfig.me";
      sw = "curl -s wttr.in";
      sqr = "qrencode -t ansiutf8";

      # Development (d-)
      dpy = "python3";
      dpip = "pip3";
      dnode = "nodejs";
      dnpm = "npm";
      dyarn = "yarn";
      dcargo = "cargo";
      dgo = "go";
      drust = "cargo";

      # Navigation (nav-)
      nav1 = "cd ..";
      nav2 = "cd ../..";
      nav3 = "cd ../../..";
      nav4 = "cd ../../../..";

      # Fun aliases (fun-)
      funp = "sudo";
      funf = "sudo";
      funfs = "sudo";
      funfsp = "sudo";
    };

    functions = {
      # File operations (f-)
      fmkcd = "mkdir -p $argv[1] && cd $argv[1]";
      fextract = ''
        if test -f $argv[1]
          switch (string match -r '.*\\.(.*)' $argv[1])
            case '*.tar.bz2'; tar xjf $argv[1]
            case '*.tar.gz'; tar xzf $argv[1]
            case '*.bz2'; bunzip2 $argv[1]
            case '*.rar'; unrar x $argv[1]
            case '*.gz'; gunzip $argv[1]
            case '*.tar'; tar xf $argv[1]
            case '*.tbz2'; tar xjf $argv[1]
            case '*.tgz'; tar xzf $argv[1]
            case '*.zip'; unzip $argv[1]
            case '*.Z'; uncompress $argv[1]
            case '*.7z'; 7z x $argv[1]
            case '*'; echo 'Cannot extract $argv[1]'
          end
        else
          echo 'File $argv[1] not found'
        end
      '';
      fbackup = "cp -r $argv[1] $argv[1].backup.(date +%Y%m%d_%H%M%S)";
      fsize = "du -sh $argv[1]";
      fcount = "find $argv[1] -type f | wc -l";

      # Git operations (g-)
      ggac = "git add . && git commit -m";
      ggacp = "git add . && git commit -m $argv[1] && git push";
      ggundo = "git reset --soft HEAD~1";
      ggsquash = "git rebase -i HEAD~$argv[1]";
      ggfeature = "git checkout -b feature/$argv[1]";
      gghotfix = "git checkout -b hotfix/$argv[1]";
      ggrelease = "git checkout -b release/$argv[1]";
      ggmerge = "git checkout main && git merge $argv[1] && git branch -d $argv[1]";

      # NixOS operations (n-)
      nns = "nix search nixpkgs $argv[1]";
      nni = "nix profile install nixpkgs#$argv[1]";
      nnr = "nix profile remove $argv[1]";
      nnl = "nix profile list";
      nnrb = "sudo nixos-rebuild switch --flake .#$argv[1]";
      nnu = "nix flake update && sudo nixos-rebuild switch --flake .#$argv[1]";
      nnc = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
      nnroll = "sudo nixos-rebuild switch --rollback";

      # System utilities (s-)
      sport = "netstat -tulpn | grep $argv[1]";
      sping = "ping -c 4 8.8.8.8";
      sspeed = "curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -";
      ssi = "echo 'OS: ' (uname -s) && echo 'Kernel: ' (uname -r) && echo 'Arch: ' (uname -m) && echo 'Uptime: ' (uptime)";
      sdisk = "df -h | grep -E '^/dev/'";
      smem = "free -h";
      scpu = "top -bn1 | grep 'Cpu(s)'";

      # Development (d-)
      dnew = "mkdir $argv[1] && cd $argv[1] && git init";
      dshell = "nix develop";
      dupdate = "nix flake update && nix develop";
      dclean = "nix develop --command fish -c 'exit'";

      # Fun utilities (fun-)
      funw = "curl -s wttr.in/$argv[1]";
      funqr = "qrencode -t ansiutf8 '$argv[1]'";
      funpass = "openssl rand -base64 32";
      funuuid = "uuidgen | tr '[:upper:]' '[:lower:]'";
    };
  };

  # Direnv integration
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Session variables (user-specific)
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "brave";
    TERMINAL = "ghostty";
  };
}
