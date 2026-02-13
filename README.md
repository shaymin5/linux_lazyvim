# 💤 LazyVim

# 介绍
请注意以下命令我没试过运行，运行前请先看清楚。

# Step

1. 安装最新unstable版neovim以及相关依赖
```bash
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt update
sudo apt install neovim git ripgrep build-essential
```
2. 克隆lazyvim仓库
```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
```
3. 清除.git
```bash
rm -rf ~/.config/nvim/.git
```
4. 启动nvim
```bash
nvim
```
5. 克隆本仓库到本地并覆盖原配置
```bash
clone https://github.com/shaymin5/linux_lazyvim.git ~/tmp/lazyvim_tmp/
rsync -av ~/tmp/lazyvim_tmp/ ~/.config/nvim/
rm -rf ~/tmp/lazyvim_tmp/
```
6. 再次启动nvim，让lazyvim自动安装相关内容
```bash
nvim
```
