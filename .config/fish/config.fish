set fish_greeting ""

set -gx TERM xterm-256color
# fish_vi_key_bindings

# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 3
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always
set -gx EDITOR vim
set -gx TERMINAL qterminal

# aliases
alias ls "ls -p -G"
alias la "ls -A"
alias ll "ls -l"
alias lla "ll -A"
alias g git
alias t "tmux -u"

set -gx PATH bin $PATH
set -gx PATH ~/bin $PATH
set -gx NNN_OPENER '~/.config/nnn/plugins/nuke'
set -gx NNN_PLUG 'b:bulknew;d:diffs;f:fzcd;F:fzopen;l:launch;t:preview-tabbed;n:nuke;p:fzplug'
set -gx NNN_FIFO /tmp/nnn.fifo n
set -gx PATH ~/.local/bin/ $PATH

