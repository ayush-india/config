function fish_greeting
     pokemon-colorscripts -r
		echo " make short note of at nigga ,leran beldner, there is a fast way to compute prime no its p*p <= n  make calcutor terminal"
end
set -gx TERM xterm-256color
set  fish_vi_key_bindings
set fzf_fd_opts --no-ignore


# theme
set -g theme_color_scheme terminal-dark
set -g fish_prompt_pwd_dir_length 3
set -g theme_display_user yes
set -g theme_hide_hostname no
set -gx GIT_EDITOR vim
set -g theme_hostname always
set -gx EDITOR nvim
# set -gx RUSTC_WRAPPER "/usr/bin/sccache" use only for old pc
set -gx TERMINAL st

# aliases
alias 1 'arttime --nolearn -a colorowl2 -b colorowl3 -g "7m;60m;loop4"'
alias 2 'arttime --nolearn -a unix -g "60m;loop10"'
alias l "eza --icons=always --git"
alias la "eza -all --icons=always --git"
alias nvim "~/nvim-linux64/bin/nvim"
alias bat "bat -p"
# alias pdf "MESA_GL_VERSION_OVERRIDE=2.1 MESA_GLSL_VERSION_OVERRIDE=330 sioyek"
alias pdf "sioyek"
alias ll "eza -l --icons=always --git"
alias gpu "__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia"
alias lla "ll -A"
alias nv "nvim"
alias c "clear"
alias g git
alias lz lazygit
alias t "tmux -u"
function n
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
set -gx PATH bin $PATH
set -gx PATH /usr/local/go/bin $PATH
set -gx PATH $HOME/go/bin $PATH
set -gx PATH ~/bin $PATH
set -gx NNN_OPENER '~/.config/nnn/plugins/nuke'
set -gx NNN_PLUG 'b:bulknew;d:diffs;f:fzcd;F:fzopen;l:launch;t:preview-tui;n:nuke;p:fzplug'
set -gx NNN_FIFO /tmp/nnn.fifo n
set -gx PATH ~/.local/bin/ $PATH
zoxide init fish --hook pwd | source
