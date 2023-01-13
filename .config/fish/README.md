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
