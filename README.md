# 🚀 NVPM - Neovim Profile Manager

NVPM (Neovim Profile Manager) is a tool designed to manage multiple Neovim configurations (profiles) seamlessly. It allows users to switch between different Neovim setups without hassle, making it easier to manage various configurations for different projects or workflows.

## ✨ Features

- 🎨 Create, list, and remove Neovim profiles.
- 🌍 Set a global profile that applies system-wide.
- ⚡ Execute Neovim with the specified profile.
- 🔄 Revert to the default system profile if a profile is missing.

## 📦 Installation

1. Run the installer:

    ```sh
    git clone https://github.com/steven-mosley/nvpm.git
    ```

2. Navigate to the project directory:

    ```sh
    cd nvpm
    ```

3. Run the installation script:

    ```sh
    ./install.sh
    ```

## 🛠️ Usage

### Commands

- `create <name>`: Create a new Neovim profile.
- `list`: List all available profiles.
- `global <name>`: Set a system-wide global profile.
- `remove <name>`: Remove a profile.
- `current`: Show the current active profile.
- `exec <program>`: Execute the given program with the NVIM_APPNAME set.
- `version`: Show NVPM version.
- `help`: Show help message.

### Examples

#### Create a New Profile

```sh
nvpm create my-config
```

#### List All Profiles

```sh
nvpm list
```

#### Set a Global Profile

```sh
nvpm global my-config
```

#### Remove a Profile

```sh
nvpm remove my-config
```

#### Show Current Active Profile

```sh
nvpm current
```

#### Execute Neovim with NVPM

```sh
nvpm exec nvim
```

### Handling Missing Profiles

If the wrapper script for a profile is missing, NVPM will prompt you to revert to the `system` profile:

```sh
ERROR: Wrapper script does not exist for profile: <profile_name>
Wrapper script <profile_name> not found. Would you like to revert to system? (y/n)
```

If you choose `y`, the global profile will be set to `system`, and `nvim` will launch normally.

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

Thanks to all contributors and the Neovim community for their support and inspiration.

---

For more information, visit the [NVPM GitHub repository](https://github.com/steven-mosley/nvpm).

<div align="center">
    <img src="https://img.shields.io/github/stars/steven-mosley/nvpm?style=social" alt="GitHub stars">
    <img src="https://img.shields.io/github/forks/steven-mosley/nvpm?style=social" alt="GitHub forks">
</div>
