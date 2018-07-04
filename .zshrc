########################################
# 環境変数

export LANG=ja_JP.UTF-8
export PATH=/usr/local/bin:$PATH

#エディタをvimに設定
export EDITORP=vim

#######################################
# 外部プラグイン
# zplug
source ~/.zplug/init.zsh

# 構文のハイライト(https://github.com/zsh-users/zsh-syntax-highlighting)
zplug "zsh-users/zsh-syntax-highlighting", defer:2
# タイプ補完
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions", use:'src/_*', lazy:true
zplug "chrissicool/zsh-256color"

# simple trash tool that works on CLI, written in Go(https://github.com/b4b4r07/gomi)
zplug 'b4b4r07/gomi', as:command, from:gh-r

# 略語を展開する
zplug "momo-lab/zsh-abbrev-alias"

# dockerコマンドの補完
zplug "felixr/docker-zsh-completion"

# Tracks your most used directories, based on 'frecency'.
zplug "rupa/z", use:"*.sh"

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
  autoload -Uz vcs_info
  autoload -Uz add-zsh-hook

  zstyle ':vcs_info:*' formats '%F{green}[%b]%f'
  zstyle ':vcs_info:*' actionformats '%F{red}[%b|%a]%f'

  local left=$'%{\e[38;5;083m%}%n@%m%{\e[0m%} %{\e[$[32+$RANDOM % 5]m%}[%{\e[0m%} %{\e[38;5;051m%}%~%{\e[0m%} ]'
  local right="${vcs_info_msg_0_} "

  LANG=en_US.UTF-8 vcs_info

  # スペースの長さを計算
  # テキストを装飾する場合、エスケープシーケンスをカウントしないようにします
  local invisible='%([BSUbfksu]|([FK]|){*})'
  local leftwidth=${#${(S%%)left//$~invisible/}}
  local rightwidth=${#${(S%%)right//$~invisible/}}
  local padwidth=$(($COLUMNS - ($leftwidth + $rightwidth) % $COLUMNS))
  print -P $left${(r:$padwidth:: :)}$right
}

PROMPT=$'%{\e[$[32+$RANDOM % 5]m%}>%{\e[0m%}%{\e[$[32+$RANDOM % 5]m%}>%{\e[0m%}%{\e[$[32+$RANDOM % 5]m%}>%{\e[0m%} '
RPROMPT=$'%{\e[30;48;5;237m%}%{\e[38;5;249m%} %D %* %{\e[0m%}'

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
eval "`dircolors -b ~/.dircolorsrc`"
export LSCOLORS=gxfxcxdxbxegedabagacad
export LS_OPTIONS='--color=auto'
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
if [[ -x /usr/bin/dircolors ]] || [[ -x dircolors ]]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

alias ls='ls --color=auto'

########################################
# tmuxの設定
# 自動ロギング

########################################
# 自作関数の設定

########################################
# その他
