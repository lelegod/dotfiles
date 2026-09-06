{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    typescript-language-server
    jq        # json on the command line
    lazygit
    neovim
    tree-sitter   # parser compiler; nvim-treesitter's main branch shells out to it
    visidata      # spreadsheet TUI; opens .xlsx directly, no conversion step
    poppler-utils # pdftotext, for pulling a PDF's words into a buffer
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept

      # Ctrl-P pastes the system clipboard at the cursor, like a normal terminal
      paste-clipboard() { LBUFFER+="$(pbpaste)" }
      zle -N paste-clipboard
      bindkey '^P' paste-clipboard

      # conda — keep first so later PATH entries win over base env
      if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
      fi

      export PATH="$HOME/.local/bin:$PATH"   # native-installed CLIs (e.g. claude) live here

      export NVM_DIR="$HOME/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
      [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

      # pyenv binary is currently missing; guarded so this is a no-op until reinstalled
      export PYENV_ROOT="$HOME/.pyenv"
      [ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
      command -v pyenv >/dev/null && eval "$(pyenv init - zsh)"

      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
}
