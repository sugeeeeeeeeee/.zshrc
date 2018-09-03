########################################
# 環境変数

export LANG=ja_JP.UTF-8
export GOPATH=$HOME/dev
export MANPATH=/usr/local/opt/inetutils/libexec/gnuman:$MANPATH
export PATH=/usr/local/bin:/usr/local/opt/inetutils/libexec/gnubin:$GOPATH/bin:$PATH

#エディタをvimに設定
export EDITORP=vim

#######################################
# 外部プラグイン
# zplug
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting", defer:2, as:plugin
# タイプ補完
zplug "zsh-users/zsh-autosuggestions", as:plugin
zplug "zsh-users/zsh-completions", use:'src/_*', lazy:true, as:plugin
zplug "chrissicool/zsh-256color", as:plugin

# simple trash tool that works on CLI, written in Go(https://github.com/b4b4r07/gomi)
zplug "b4b4r07/gomi", as:command, from:gh-r, as:plugin

# 略語を展開する
zplug "momo-lab/zsh-abbrev-alias", as:plugin

# dockerコマンドの補完
zplug "felixr/docker-zsh-completion", as:plugin

# Tracks your most used directories, based on 'frecency'.
zplug "rupa/z", use:"*.sh", as:plugin

# Install plugins if there are plugins that have not been installed
zplug load

#######################################
# プロンプトなどの設定
# 色を使用出来るようにする
autoload -Uz colors
colors

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# プロンプト

# エスケープシーケンスを通すオプション
setopt prompt_subst

# 改行のない出力をプロンプトで上書きするのを防ぐ
unsetopt promptcr

# 頑張って両方にprmptを表示させるヤツ https://qiita.com/zaapainfoz/items/355cd4d884ce03656285
precmd() {

  #JUNOSチックに1行空ける
  print
  autoload -Uz vcs_info
  autoload -Uz add-zsh-hook

  if [ "$(uname)" = 'Darwin' ]; then
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
    zstyle ':vcs_info:git:*' unstagedstr "%F{magenta}+"
    zstyle ':vcs_info:*' formats '%F{green}%c%u[✔ %b]%f'
    zstyle ':vcs_info:*' actionformats '%F{red}%c%u[✑ %b|%a]%f'
  else
    zstyle ':vcs_info:*' formats '%F{green}[%b]%f'
    zstyle ':vcs_info:*' actionformats '%F{red}[%b|%a]%f'
  fi

  if [ "$(uname)" = 'Darwin' ]; then
    local left=$'%{\e[$[32+$RANDOM % 5]m%}%n%{\e[0m%}@%{\e[$[32+$RANDOM % 5]m%}%m%{\e[0m%} %{\e[$[32+$RANDOM % 5]m%}⥬%{\e[0m%} %{\e[38;5;051m%}%d%{\e[0m%}'
  else
    local left=$'%{\e[$[32+$RANDOM % 5]m%}%n%{\e[0m%}@%{\e[$[32+$RANDOM % 5]m%}%m%{\e[0m%} %{\e[$[32+$RANDOM % 5]m%}=>%{\e[0m%} %{\e[38;5;051m%}%d%{\e[0m%}'
  fi
  local right=$'${vcs_info_msg_0_}'

  LANG=en_US.UTF-8 vcs_info

  # スペースの長さを計算
  # テキストを装飾する場合、エスケープシーケンスをカウントしないようにします
  local invisible='%([BSUbfksu]|([FK]|){*})'
  local leftwidth=${#${(S%%)left//$~invisible/}}
  local rightwidth=${#${(S%%)right//$~invisible/}}
  local padwidth=$(($COLUMNS - ($leftwidth + $rightwidth) % $COLUMNS))
  print -P $left${(r:$padwidth:: :)}$right
}

if [ "$(uname)" = 'Darwin' ]; then
  PROMPT=$'%(?.😀 .😱 )%{\e[$[32+$RANDOM % 5]m%}❯%{\e[0m%}%{\e[$[32+$RANDOM % 5]m%}❯%{\e[0m%}%{\e[$[32+$RANDOM % 5]m%}❯%{\e[0m%} '
else
  PROMPT=$'%{\e[$[32+$RANDOM % 5]m%}>%{\e[0m%}%{\e[$[32+$RANDOM % 5]m%}>%{\e[0m%}%{\e[$[32+$RANDOM % 5]m%}>%{\e[0m%} '
fi

if [ "$(uname)" = 'Darwin' ]; then
  RPROMPT=$'%{\e[38;5;001m%}%(?..✘☝)%{\e[0m%} %{\e[30;48;5;237m%}%{\e[38;5;249m%} %D %* %{\e[0m%}'
else
  RPROMPT=$'%{\e[30;48;5;237m%}%{\e[38;5;249m%} %D %* %{\e[0m%}'
fi

# プロンプト自動更新設定
autoload -U is-at-least
# $EPOCHSECONDS, strftime等を利用可能に
zmodload zsh/datetime

reset_tmout() {
  TMOUT=$[1-EPOCHSECONDS%1]
}

precmd_functions=($precmd_functions reset_tmout reset_lastcomp)

reset_lastcomp() {
  _lastcomp=()
}

if is-at-least 5.1; then
  # avoid menuselect to be cleared by reset-prompt
  redraw_tmout() {
    [ "$WIDGET" = "expand-or-complete" ] && [[ "$_lastcomp[insert]" =~ "^automenu$|^menu:" ]] || zle reset-prompt
    reset_tmout
  }
else
  # evaluating $WIDGET in TMOUT may crash :(
  redraw_tmout() {
    zle reset-prompt; reset_tmout
  }
fi

TRAPALRM() {
  redraw_tmout
}

# 単語の区切り文字を指定する
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

## 補完候補の色づけ
#eval `dircolors`
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_COLORS='di=36:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' verbose yes
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

########################################
# 補完
# 補完機能を有効にする
autoload -Uz compinit
compinit

# 補完数が多い場合に表示されるメッセージの表示を1000にする。
LISTMAX=1000

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ../ の後は今いるディレクトリを補完しない
zstyle ':completion:*' ignore-parents parent pwd ..

# ps コマンドのプロセス名補完
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# awscli コマンドの補完機能有効化
# source /usr/local/bin/aws_zsh_completer.sh

# 選択中の候補を塗りつぶす
zstyle ':completion:*:default' menu select=2

########################################
# オプション
# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# beep を無効にする
setopt no_beep

# フローコントロールを無効にする
setopt no_flow_control

# Ctrl+Dでzshを終了しない
#setopt ignore_eof

# '#' 以降をコメントとして扱う
setopt interactive_comments

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd

# 重複したディレクトリを追加しない
setopt pushd_ignore_dups

## zsh の開始, 終了時刻をヒストリファイルに書き込む
#setopt extended_history

# シェルの終了を待たずにファイルにコマンド履歴を保存
setopt inc_append_history

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# 高機能なワイルドカード展開を使用する
setopt extended_glob

# コマンド訂正
setopt correct

# 補完候補を詰めて表示する
setopt list_packed

# カーソル位置は保持したままファイル名一覧を順次その場で表示
setopt always_last_prompt

# カッコの対応などを自動的に補完
setopt auto_param_keys

# 語の途中でもカーソル位置で補完
setopt complete_in_word

# フロー制御をやめる
setopt no_flow_control

# バックグラウンドジョブが終了したらすぐに知らせる
setopt notify

# remove file mark
unsetopt list_types

########################################
# キーバインド
# Windows風のキーバインド
# Deleteキー
bindkey "^[[3~" delete-char

# Homeキー
bindkey "^[[1~" beginning-of-line

# Endキー
bindkey "^[[4~" end-of-line

# ヒストリー検索をpecoで。
peco-select-history() {
    BUFFER=$(history 1 | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\*?\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$LBUFFER")
    CURSOR=${#BUFFER}
    zle reset-prompt
}
zle -N peco-select-history
bindkey '^R' peco-select-history

# zをpecoで。
peco-z-search() {
    which peco z > /dev/null
    if [ $? -ne 0 ]; then
            echo "Please install peco and z"
            return 1
      fi
      local res=$(z | sort -rn | cut -c 12- | peco)
      if [ -n "$res" ]; then
          BUFFER+="cd $res"
            zle accept-line
    else
        return 1
    fi
}
zle -N peco-z-search
bindkey '^F' peco-z-search

# リポジトリの移動をpecoで
function peco-src () {
    local selected_dir=$(ghq list -p | peco --prompt "REPOSITORY >" --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
            zle accept-line
      fi
      zle clear-screen
}
zle -N peco-src
bindkey '^]' peco-src

# cd up
function cd-up() {
    zle push-line && LBUFFER='builtin cd ..' && zle accept-line
}
zle -N cd-up
bindkey "^P" cd-up

# clear command
bindkey "^S" clear-screen

# word forward
bindkey "^N" forward-word
bindkey "^B" backward-word

# kill line
bindkey "^Q" kill-whole-line

########################################
# エイリアス
case ${OSTYPE} in
    darwin*)
        if type gdircolors > /dev/null 2>&1; then
            abbrev-alias ls='ls -G'
            abbrev-alias dir='dir --color=auto'
            abbrev-alias vdir='vdir --color=auto'
            abbrev-alias grep='grep --color=auto'
            abbrev-alias fgrep='fgrep --color=auto'
            abbrev-alias egrep='egrep --color=auto'
        fi
        abbrev-alias dockerc='docker-compose'
        ;;
    linux*)
        if type dircolors > /dev/null 2>&1; then
            abbrev-alias ls='ls --color=auto'
            abbrev-alias dir='dir --color=auto'
            abbrev-alias vdir='vdir --color=auto'
            abbrev-alias grep='grep --color=auto'
            abbrev-alias fgrep='fgrep --color=auto'
            abbrev-alias egrep='egrep --color=auto'
        fi
        ;;
esac

# ls
abbrev-alias l='ls -CF'
abbrev-alias la='ls -la'
abbrev-alias ll='ls -l'

# rm
abbrev-alias rm='rm -i'

# cp
abbrev-alias cp='cp -i'

# mv
abbrev-alias mv='mv -i'

# mkdri
abbrev-alias mkdir='mkdir -p'

# tmux
abbrev-alias t='tmux new -s "$(date +%Y-%m-%d_%H-%M-%S)"'
abbrev-alias tl='tmux ls'

# git
abbrev-alias ga='git add'
abbrev-alias gc='git commit -m'
abbrev-alias gp='git push'

# go command
case ${OSTYPE} in
  darwin*)
    ;;
  linux*)
    abbrev-alias gor='go run'
    ;;
esac

########################################
# tmuxの設定
# 自動ロギング
if [[ $TERM = screen ]] || [[ $TERM = screen-256color ]] ; then
    LOGDIR=$HOME/Documents/term_logs
    LOGFILE=$(hostname)_$(date +%Y-%m-%d_%H%M%S_%N.log)
    [ ! -d $LOGDIR ] && mkdir -p $LOGDIR
    tmux  set-option default-terminal "screen" \; \
        pipe-pane        "cat >> $LOGDIR/$LOGFILE" \; \
        display-message  "Started logging to $LOGDIR/$LOGFILE"
fi

########################################
# 自作関数の設定

########################################
# その他
case ${OSTYPE} in
    darwin*)
      # powerlevel9
      ZSH_THEME="powerlevel9k/powerlevel9k"
      POWERLEVEL9K_MODE='nerdfont-complete'
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(time dir vcs)
      POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()
      POWERLEVEL9K_DISABLE_RPROMPT=true
      POWERLEVEL9K_TIME_FORMAT="%D{%m\/%d %H:%M}"
      POWERLEVEL9K_TIME_FOREGROUND='white'
      POWERLEVEL9K_TIME_BACKGROUND='background'
      POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
      POWERLEVEL9K_PROMPT_ON_NEWLINE=true
      POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
      POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
      POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="\u25B8 "
      POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
      POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
      ;;
    linux*)
      # terraform
      abbrev-alias tf='terraform'
      # anyenv
      if [[ -d $HOME/.anyenv ]]; then
        export PATH="$HOME/.anyenv/bin:$PATH"
        eval "$(anyenv init - zsh)"
      fi
      # gcloud
      if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then source "$HOME/google-cloud-sdk/path.zsh.inc"; fi
      if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then source "$HOME/google-cloud-sdk/completion.zsh.inc"; fi
      ;;
esac
