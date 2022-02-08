#!/bin/bash
while getopts 'erszvoh' o
do
    case $o in
        e)install_essentials;;
        r)install_rust_packages;;
        s)download_st;;
        z)installzsh;;
        v)install_vundle;;
        o)install_omz;;
        h)printhelp;exit 1;;
        *)printhelp;exit 1;;
    esac
done
printhelp(){
    echo 'Usage: bootstrap.sh [-erszvh]'
    echo '-e install essential packages'
    echo '-r install rust packages'
    echo '-z install zsh'
    echo '-o install oh-my-zsh'
    echo '-v install vundle'
    echo '-s download st'
}
install_essentials(){
    pacman -Syu git
    pacman -Syu rust
}
install_rust_packages(){
    cargo install rage
    cargo install ripgrep
    cargo install fd
    cargo install sd
    cargo install bat
    cargo install exa
    cargo install mdcat
    cargo install hexyl
    cargo install hyperfine
    cargo install xsv
    cargo install tokei
    cargo install onefetch
    cargo install btm
    cargo install dust
    cargo install broot
}
download_st(){
    if [ ! -d "~/codebase" ]; then
        mkdir -p "~/codebase"
    fi
    curl "https://dl.suckless.org/st/st-0.8.5.tar.gz" | tar -xz -C ~/codebase

}

installzsh(){
    pacman -S zsh
    pacman -S zsh-completions
}
#setup oh-my-zsh
install_omz(){
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    yay -S --noconfirm zsh-theme-powerlevel10k-git
    echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
    source ~/.zshrc && \
        p10k configure
}
install_vundle(){
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
}

install_fzf(){
    pacman -S fzf
    curl https://raw.githubusercontent.com/samsepiol-e/dotfiles/main/fzf_setup >> ~/.zshrc
}
