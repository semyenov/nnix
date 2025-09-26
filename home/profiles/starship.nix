{lib, ...}: {
  # Enhanced Starship prompt configuration
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # Optimized format with logical grouping and better organization
      format = lib.concatStrings [
        # System info (top priority)
        "$os"
        "$username"
        "$hostname"
        "$localip"
        "$shlvl"
        "$container"

        # Navigation and context
        "$directory"
        "$nix_shell"
        "$conda"
        "$direnv"
        "$env_var"

        # Version control (most important for development)
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$hg_branch"

        # Development environment
        "$docker_context"
        "$kubernetes"
        "$terraform"
        "$aws"
        "$gcloud"
        "$azure"

        # Programming languages (grouped by popularity)
        "$nodejs"
        "$python"
        "$rust"
        "$golang"
        "$java"
        "$c"
        "$cmake"
        "$lua"
        "$ruby"
        "$php"
        "$dotnet"
        "$dart"
        "$swift"
        "$kotlin"
        "$scala"
        "$haskell"
        "$ocaml"
        "$nim"
        "$zig"
        "$vlang"
        "$crystal"
        "$elixir"
        "$elm"
        "$erlang"
        "$fennel"
        "$gleam"
        "$haxe"
        "$helm"
        "$julia"
        "$gradle"
        "$perl"
        "$pulumi"
        "$purescript"
        "$quarto"
        "$raku"
        "$rlang"
        "$red"
        "$solidity"
        "$typst"
        "$vagrant"
        "$buf"
        "$cobol"
        "$daml"
        "$deno"
        "$guix_shell"
        "$meson"
        "$spack"

        # Package management
        "$package"

        # System monitoring
        "$memory_usage"
        "$battery"

        # Command execution
        "$cmd_duration"
        "$jobs"
        "$sudo"

        # Status and completion
        "$status"
        "$time"
        "$line_break"
        "$character"
      ];

      # Add a blank line at the start of the prompt
      add_newline = true;

      # Performance optimizations
      scan_timeout = 30;
      command_timeout = 500;
      right_format = ""; # Disable right prompt for better performance

      # Palette for consistent colors
      palette = "catppuccin_mocha";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      # Character module - enhanced prompt symbols
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vicmd_symbol = "[❮](bold yellow)";
        format = "$symbol ";
        disabled = false;
      };

      # Username module
      username = {
        style_user = "blue bold";
        style_root = "red bold";
        format = "[$user]($style) ";
        show_always = false;
        disabled = false;
      };

      # Hostname module
      hostname = {
        ssh_only = false;
        ssh_symbol = " ";
        format = "on [$ssh_symbol$hostname](bold green) ";
        trim_at = ".local";
        disabled = false;
      };

      # Directory module with enhanced icons and better functionality
      directory = {
        style = "bold lavender";
        format = "in [$path]($style)[$read_only]($read_only_style) ";
        truncation_length = 3;
        truncate_to_repo = true;
        truncation_symbol = "…/";
        read_only = " 󰌾";
        read_only_style = "red";
        home_symbol = "󰋜 ";
        fish_style_pwd_dir_length = 1;
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = "󰈙 ";
          "Music" = "󰎈 ";
          "Pictures" = "󰈙 ";
          "Developer" = "󰲋 ";
          "Projects" = "󰏗 ";
          ".config" = "󰈙 ";
          "~" = "󰋜 ";
          "nn" = "󰌠 ";
          "home" = "󰋜 ";
          "tmp" = "󰔷 ";
          "var" = "󰀘 ";
          "opt" = "󰏗 ";
          "usr" = "󰗮 ";
          "bin" = "󰘳 ";
          "etc" = "󰙅 ";
          "dev" = "󰋚 ";
          "proc" = "󰌠 ";
          "sys" = "󰒓 ";
        };
      };

      # Git branch module - enhanced with better symbols
      git_branch = {
        symbol = "󰘬 ";
        style = "bold mauve";
        format = "on [$symbol$branch(:$remote_branch)]($style) ";
        truncation_length = 20;
        truncation_symbol = "…";
        always_show_remote = false;
        only_attached = false;
        disabled = false;
      };

      # Git status module with enhanced symbols and better visibility
      git_status = {
        style = "bold red";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        conflicted = "⚔️";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        up_to_date = "";
        untracked = "?";
        stashed = "󰏗";
        modified = "!";
        staged = "+";
        renamed = ">";
        deleted = "✘";
        typechanged = "󰉄";
        disabled = false;
      };

      # Git commit module
      git_commit = {
        style = "bold green";
        format = "[\\($hash$tag\\)]($style) ";
        commit_hash_length = 8;
        tag_symbol = " 󰓹 ";
        only_detached = true;
        disabled = false;
      };

      # Git state module
      git_state = {
        style = "bold yellow";
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
        rebase = "REBASING";
        merge = "MERGING";
        revert = "REVERTING";
        cherry_pick = "CHERRY-PICKING";
        bisect = "BISECTING";
        am = "AM";
        am_or_rebase = "AM/REBASE";
        disabled = false;
      };

      # Git metrics
      git_metrics = {
        disabled = false;
        format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
        added_style = "bold green";
        deleted_style = "bold red";
        only_nonzero_diffs = true;
      };

      # Command duration module - optimized for better UX
      cmd_duration = {
        min_time = 1000; # Show if command took more than 1 second
        style = "bold yellow";
        format = "took [$duration]($style) ";
        show_milliseconds = false;
        disabled = false;
        show_notifications = false;
        min_time_to_notify = 30000; # Reduced notification threshold
      };

      # Package version module
      package = {
        style = "bold 208";
        format = "is [$symbol$version]($style) ";
        symbol = "󰏗 ";
        version_format = "v\${raw}";
        display_private = false;
        disabled = false;
      };

      # Nix shell module - enhanced for better Nix development
      nix_shell = {
        style = "bold blue";
        format = "via [$symbol$state( \\($name\\))]($style) ";
        symbol = "󰍭 ";
        impure_msg = "[impure](bold red)";
        pure_msg = "[pure](bold green)";
        unknown_msg = "[unknown](bold yellow)";
        disabled = false;
        heuristic = true; # Enable heuristic for better detection
      };

      # Docker context
      docker_context = {
        style = "blue bold";
        format = "via [$symbol$context]($style) ";
        symbol = "󰡨 ";
        only_with_files = true;
        detect_extensions = [];
        detect_files = ["docker-compose.yml" "docker-compose.yaml" "Dockerfile"];
        detect_folders = [];
        disabled = false;
      };

      # Jobs module
      jobs = {
        style = "bold blue";
        format = "[$symbol$number]($style) ";
        symbol = "✦";
        number_threshold = 1;
        symbol_threshold = 1;
        disabled = false;
      };

      # Battery module
      battery = {
        format = "[$symbol$percentage]($style) ";
        charging_symbol = "";
        discharging_symbol = "";
        empty_symbol = "";
        full_symbol = "";
        unknown_symbol = "";
        display = [
          {
            threshold = 10;
            style = "bold red";
          }
          {
            threshold = 30;
            style = "bold yellow";
          }
        ];
        disabled = true; # Enable if on laptop
      };

      # Time module
      time = {
        style = "bold bright-white";
        format = "at [$time]($style) ";
        time_format = "%T";
        disabled = true; # Enable if you want time in prompt
        use_12hr = false;
      };

      # Memory usage module - optimized for performance
      memory_usage = {
        style = "bold dimmed white";
        format = "via $symbol[$ram( | $swap)]($style) ";
        symbol = "󰍛 ";
        threshold = 85; # Only show when memory usage is high
        disabled = true; # Disable by default for better performance
      };

      # Shell level module
      shlvl = {
        style = "bold yellow";
        format = "[$symbol$shlvl]($style) ";
        symbol = "↕️ ";
        repeat = false;
        threshold = 3;
        disabled = false;
      };

      # Status module - enhanced error handling
      status = {
        style = "bold red";
        format = "[$symbol$status]($style) ";
        symbol = "✖ ";
        success_symbol = "";
        not_executable_symbol = "🚫";
        not_found_symbol = "🔍";
        sigint_symbol = "🧱";
        signal_symbol = "⚡";
        map_symbol = false;
        disabled = false; # Enable for better error handling
        recognize_signal_code = true;
        pipestatus = true;
      };

      # Programming language modules with Nerd Font icons
      nodejs = {
        style = "bold green";
        format = "via [$symbol($version )]($style)";
        symbol = "󰎙 ";
        detect_extensions = ["js" "mjs" "cjs" "ts" "mts" "cts"];
        detect_files = ["package.json" ".node-version"];
        detect_folders = ["node_modules"];
        disabled = false;
        not_capable_style = "bold red";
      };

      python = {
        style = "yellow bold";
        format = "via [\${symbol}\${pyenv_prefix}(\${version} )(\\($virtualenv\\) )]($style)";
        symbol = "󰌠 ";
        pyenv_version_name = false;
        pyenv_prefix = "pyenv ";
        python_binary = ["python3" "python"];
        detect_extensions = ["py"];
        detect_files = ["requirements.txt" "setup.py" "pyproject.toml"];
        disabled = false;
      };

      rust = {
        style = "bold red";
        format = "via [$symbol($version )]($style)";
        symbol = "󱘗 ";
        detect_extensions = ["rs"];
        detect_files = ["Cargo.toml"];
        disabled = false;
      };

      golang = {
        style = "bold cyan";
        format = "via [$symbol($version )]($style)";
        symbol = "󰟓 ";
        detect_extensions = ["go"];
        detect_files = ["go.mod" "go.sum" "go.work"];
        disabled = false;
      };

      java = {
        style = "bold red";
        format = "via [$symbol($version )]($style)";
        symbol = " ";
        detect_extensions = ["java" "class" "jar" "gradle" "clj" "cljc"];
        detect_files = ["pom.xml" "build.gradle.kts" "build.sbt" ".java-version" ".deps.edn" "project.clj" "build.boot" ".sdkmanrc"];
        detect_folders = [];
        disabled = false;
      };

      ruby = {
        style = "bold red";
        format = "via [$symbol($version )]($style)";
        symbol = "󰴭 ";
        detect_extensions = ["rb"];
        detect_files = ["Gemfile" ".ruby-version"];
        detect_folders = [];
        disabled = false;
      };

      # C/C++ module
      c = {
        style = "149 bold";
        format = "via [$symbol($version(-$name) )]($style)";
        symbol = " ";
        detect_extensions = ["c" "h"];
        detect_files = [];
        detect_folders = [];
        disabled = false;
      };

      cmake = {
        style = "blue bold";
        format = "via [$symbol($version )]($style)";
        symbol = "󰔶 ";
        detect_extensions = [];
        detect_files = ["CMakeLists.txt" "CMakeCache.txt"];
        detect_folders = [];
        disabled = false;
      };

      lua = {
        style = "blue bold";
        format = "via [$symbol($version )]($style)";
        symbol = "󰢱 ";
        detect_extensions = ["lua"];
        detect_files = [".lua-version"];
        detect_folders = ["lua"];
        disabled = false;
      };

      # OS module - enhanced with NixOS detection
      os = {
        style = "bold white";
        format = "[$symbol]($style) ";
        disabled = false; # Enable to show OS icon
        symbols = {
          Alpine = "";
          AlmaLinux = "";
          Android = "";
          Arch = "";
          CentOS = "";
          Debian = "";
          EndeavourOS = "";
          Fedora = "";
          Illumos = "";
          Kali = "";
          Linux = "";
          Macos = "";
          Manjaro = "";
          Mariner = "";
          Mint = "";
          NetBSD = "";
          NixOS = "󰌠 ";
          OpenBSD = "";
          openEuler = "";
          openSUSE = "";
          OracleLinux = "";
          Pop = "";
          Raspbian = "";
          Redhat = "󱄛 ";
          RedHatEnterprise = "󱄛 ";
          RockyLinux = "";
          Redox = "🧪 ";
          Solus = "";
          SUSE = "";
          Ubuntu = "";
          Ultramarine = "";
          Unknown = "";
          Void = "";
          Windows = "";
        };
      };

      # Sudo module
      sudo = {
        style = "bold red";
        format = "[as $symbol]($style)";
        symbol = "󰞀 ";
        disabled = true; # Enable to show when using sudo
      };

      # Local IP
      localip = {
        ssh_only = true;
        format = "[$localipv4](bold yellow) ";
        disabled = false;
      };

      # Kubernetes context
      kubernetes = {
        style = "cyan bold";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
        symbol = "󱃾 ";
        disabled = true; # Enable if using k8s
      };

      # AWS module
      aws = {
        style = "bold orange";
        format = "on [$symbol($profile )(\\($region\\) )(\\[$duration\\] )]($style)";
        symbol = "󰸏 ";
        disabled = true; # Enable if using AWS
      };

      # Google Cloud
      gcloud = {
        style = "bold blue";
        format = "on [$symbol$account(@$domain)(\\($region\\))]($style) ";
        symbol = "󱇶 ";
        disabled = true; # Enable if using GCP
      };

      # Azure module
      azure = {
        style = "blue bold";
        format = "on [$symbol($subscription)]($style) ";
        symbol = "󰠅 ";
        disabled = true; # Enable if using Azure
      };

      # Terraform module
      terraform = {
        style = "105 bold";
        format = "via [$symbol$workspace]($style) ";
        symbol = "󱁢 ";
        detect_extensions = ["tf" "tfplan" "tfstate"];
        detect_files = [];
        detect_folders = [".terraform"];
        disabled = false;
      };

      # Container indicator
      container = {
        style = "bold red dimmed";
        format = "[$symbol \\[$name\\]]($style) ";
        symbol = "󰡨";
        disabled = false;
      };

      # Direnv module - enhanced for better development workflow
      direnv = {
        style = "bold orange";
        format = "[$symbol$loaded/$allowed]($style) ";
        symbol = "󰌪 ";
        disabled = false; # Enable for better development experience
        allowed_msg = "✓";
        not_allowed_msg = "✗";
        denied_msg = "⛔";
        loaded_msg = "●";
        unloaded_msg = "○";
      };

      # Environment variable module
      env_var = {
        style = "bold blue";
        format = "[$env_value]($style) ";
        variable = "STARSHIP_SESSION_KEY";
        default = "";
        symbol = "";
        disabled = false;
      };

      # # Custom module for system info
      # custom = {
      #   command = "echo '󰌠'";
      #   when = "test -f /etc/nixos/configuration.nix";
      #   style = "bold blue";
      #   format = "[$output]($style) ";
      #   disabled = false;
      # };

      # Shell module
      shell = {
        style = "bold cyan";
        format = "[$indicator]($style) ";
        fish_indicator = "󰈺 ";
        bash_indicator = "󰘳 ";
        zsh_indicator = "󰺧 ";
        disabled = false;
      };
    };
  };
}
