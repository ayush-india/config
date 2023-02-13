 Hello it is all of the config files which i use on my Lubuntu system 

NOTE: remove all fish.tmp. files form the fish dir to remove all the temporaye enviroment variables
 required : Goneovim https://github.com/akiyosi/goneovim
 required Prgrame to install

nnn a freaking nice file manger
sccahe (a cacheing system for rust)
tmux comme u need it
so (its in yout /usr/bin) a tui for stackvoerflwo
GIMP image editor
 nvim (latest version)
 discord
 google-chrome
 awesome(windnd-manager)
 btop(proc-manager)
 compton(picom if availabe)
 fish (terminal-emulator) with starship promit coz its the new goat and kitty terminal 
 lynx (the best web browser in the world)
 jetbarins mono nerd font
 nitrogen
 rofi(app-launcher)
 vlc

 
NVIM config 
i have my own config (inspired from nvchad's config)
at https://github.com/ayush-india/.nvim
GOat 
fish key bindings

CRTL - C ALT - e
bind \co '__fzf_find_file'
bind \cr '__fzf_reverse_isearch'
bind \ec '__fzf_cd'
bind \eC '__fzf_cd --hidden'
bind \eO '__fzf_open'
bind \eo '__fzf_open --editor'

bind -M insert \co '__fzf_find_file'
bind -M insert \cr '__fzf_reverse_isearch'
bind -M insert \ec '__fzf_cd'
bind -M insert \eC '__fzf_cd --hidden'
bind -M insert \eO '__fzf_open'
bind -M insert \eo '__fzf_open --editor'
