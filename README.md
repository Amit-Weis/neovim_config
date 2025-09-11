## Introduction
Please note that almost nothing in this guide works anymore, follow with some grains of salt ... 
Hello! 
My name is Amit Weis and I have recently gotten really into neovim. here is the culmination of all my efforts these past few weeks. 

Huge thanks to all the wonderful developers that made all of the plugins I make use of, and all of the developers that contribute to open source. Special thanks in particular to @Ben-Edwards44 for making PyBonsai, which I use a varation of in my splash screen.

Please enjoy!

## General Windows Tweaks (On a New Computer)

Run the following command in PowerShell:
```powershell
iwr -useb https://christitus.com/win | iex
```

Look through all tweaks and use your critical thinking skills to choose which ones you like.
## Terminal Configuration (windows 10 only)

if on windows 10 Install the new terminal from [Microsoft Store](https://apps.microsoft.com/detail/9n0dx20hk701?rtc=1&hl=en-ca&gl=CA). 
Search for "terminal settings" and set the newly installed terminal as the default.

## Install WSL Ubuntu

Run the following command in PowerShell:
```powershell
wsl --install
```
Restart your machine.
Finish WSL setup.
Use username: `taust` for consistency.

## Installation
#### Update all packages
run the following commands:
```bash
sudo apt update
sudo apt list --upgradeable
sudo apt upgrade -y
```
#### Install Neovim
run the following commands:
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux64/bin"' >> ~/.bashrc
```

#### Install all dependencies 
run the following commands: 
```bash
npm install -g neovim
sudo apt install -y fd-find git rustfmt python3-venv luarocks clang pip ripgrep nodejs unzip pip3 install
pip3 install pynvim
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-8.0
sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-8.0
sudo apt-get install -y dotnet-runtime-8.0
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```
#### Install PyBonsai
run the following commands (You will need to access this later, download it somewhere you remember!):
```bash
git clone https://github.com/Ben-Edwards44/PyBonsai.git
cd PyBonsai
sudo bash install.sh
```
#### Installing a Nerd Font
download a Nerd Font from [Nerd Fonts](https://www.nerdfonts.com/font-downloads). 
- I use `FiraMono Nerd Font`
- Download and unzip the Nerd Font. 
- Highlight all `.otf` files, right-click, and choose `Install`.
#### Installing Oh-My-Posh
run the following commands:
```bash
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh sudo chmod +x /usr/local/bin/oh-my-posh 
echo 'bash eval "$(oh-my-posh init bash)"' >> ~/.bashrc
set $TERM=xterm-256color
mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip
```

## Configuration
#### Terminal settings: 
Open up terminal settings with `Ctrl+,`
Go to `Settings -> Appearance`
- Enable `Use acrylic material in the tab row`
- Save the changes.

Go to `Settings -> Defaults -> Appearance -> Font face`. 
- Change Font face to "FiraMono Nerd Font Propo".
- Save the changes.

Go to `Settings -> Startup -> Default profile`. 
- Change it to "Ubuntu". 
- Save the changes. 

Go to the bottom right of the settings menu, and click "Open JSON file".
paste the following into the bottom of the "schemes" section (use search to find it):
```json
    "schemes":
    [
	    // rest of themes here ...
		{
		  "name": "CGA",
		  "black": "#000000",
		  "red": "#aa0000",
		  "green": "#00aa00",
		  "yellow": "#aa5500",
		  "blue": "#0000aa",
		  "purple": "#aa00aa",
		  "cyan": "#00aaaa",
		  "white": "#aaaaaa",
		  "brightBlack": "#555555",
		  "brightRed": "#ff5555",
		  "brightGreen": "#55ff55",
		  "brightYellow": "#ffff55",
		  "brightBlue": "#5555ff",
		  "brightPurple": "#ff55ff",
		  "brightCyan": "#55ffff",
		  "brightWhite": "#ffffff",
		  "background": "#000000",
		  "foreground": "#aaaaaa",
		  "selectionBackground": "#c1deff",
		  "cursorColor": "#b8b8b8"
		}
	]
```

Go to `Settings -> Color schemes`.
- Click the top color scheme.
- Set it as default.
- Save the changes. 

#### configure Oh-My-Posh
run the following command:
```bash
echo "eval "$(oh-my-posh init bash --config ~/.poshthemes/kushal.omp.json)"" >> ~/.bashrc
```
If you wish to use a different Oh-My-Posh theme, go to [here](https://ohmyposh.dev/docs/themes) , find a theme you like, and replace the `kushal.omp.json` with the name of the one you like (IE: `1_shell.omp.json`)

#### configure PyBonsai
return to where you downloaded PyBonsai

Find `main.py` and edit the Options class to have the following default paramaters:
```python
    # default values
    NUM_LAYERS = 10
    INITIAL_LEN = 20
    ANGLE_MEAN = 40

    LEAF_LEN = 4

    INSTANT = True
    WAIT_TIME = 0

    BRANCH_CHARS = "~;:="
    LEAF_CHARS = "&*%#@"

    WINDOW_WIDTH = 150
    WINDOW_HEIGHT = 45

    OPTION_DESCS = f"""
```
furthermore change the `get_defualt_windows(self):` function to the following:
```python
    def get_default_window(self):
        # ensure the default values fit the current terminal size
        width, height = Options.WINDOW_WIDTH, Options.WINDOW_HEIGHT
        return width, height

```
find `tree.py` and change the `get_initial_params(self):` function to the following:
```python
    def get_initial_params(self):
        initial_width = (self.options.initial_len // 6) + 1
        initial_angle = random.normalvariate(0, RecursiveTree.ANGLE_STD_DEV)

        # ensure the width is in a suitable range
        initial_width = max(0, initial_width)
        initial_width = min(RecursiveTree.MAX_INITIAL_WIDTH, initial_width)

        return initial_width, initial_angle
```
## Neovim config setup
Run the following commands:
```bash
mkdir -p ~/.config
cd ~/.config
```

Clone the config files to your machine using the following commands:
```bash
git clone https://github.com/Amit-Weis/neovim_config
mv neovim_config nvim
```
## Troubleshooting

First uninstall every single plugin and reinstall. if the error persists looks below
#### Treesitter is acting up
If writing `:echo nvim_get_runtime_file('parser', v:true)`  Shows 2 dirs:  
```lua
['/Users/taust/.local/share/nvim/lazy/nvim-treesitter/parser', '/usr/local/Cellar/neovim/0.8.2/lib/nvim/parser']
```
find and delete the second parser folder, then uninstall and reinstall every single plugin
#### Mason is throwing errors
Check `:MasonLog` to see if there are packages that you do not have installed that are required for certain LSP's

If you do not understand the log, simply copy paste the error code, and google it. Use your critical thinking skills.
