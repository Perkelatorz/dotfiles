# Packages & Bootstrap

Bootstrap turns a **fresh CachyOS install with no desktop selected** into a
complete Hyprland workstation. Everything is repo-only except `class/work.aur`
(xrdp — required for RDP from locked-down Windows clients at work).

## Fresh machine runbook

```sh
# 1. Install CachyOS, choosing "No Desktop". Log into the TTY, then:
sudo pacman -S --needed git yadm

# 2. Clone dotfiles (say yes when it offers to run bootstrap, or run it yourself)
yadm clone https://github.com/perkelatorz/dotfiles

# 3. Tell yadm what this machine is (bootstrap prompts if you skip this)
yadm config local.class desktop   # or: laptop | work

# 4. Bootstrap (full -Syu, all packages, services, shell, defaults)
yadm bootstrap

# 5. Reboot → SDDM → Hyprland. Then authenticate tailscale:
sudo tailscale up
```

### After first login

```sh
# Log into Bitwarden, then in its Settings enable "SSH agent" (one-time,
# app-level toggle). SSH_AUTH_SOCK is already wired session-wide.
# Once the agent serves keys, switch the dotfiles remote to SSH for pushing:
yadm remote set-url origin git@github.com:perkelatorz/dotfiles.git

# Sunshine (desktop class): pair Moonlight clients one time at
#   https://localhost:47990
```

### What to expect on first boot

- **GPU**: chwd + the class list install the right driver (`nvidia-open-dkms`
  on desktop/laptop, `nvidia-580xx-dkms` on work's Pascal Quadros). The GPU
  segment in the bar's performance pill appears once `nvidia-smi` works.
- **Laptop hybrid graphics**: AMD iGPU should be primary. If Hyprland grabs
  the dGPU (wrong outputs / poor battery), uncomment the `AQ_DRM_DEVICES`
  pin in `~/.config/hypr/env-gpu.conf##class.laptop` — check card order
  with `ls -l /dev/dri/by-path/`. Run heavy apps on the dGPU via `prime-run`.
- **Work RDP**: bootstrap writes `~/startwm.sh` (xrdp-sesman's per-user
  hook). From Windows: mstsc → host:3389 → session type "Xorg". Log out of
  the local Hyprland session before RDP-ing as the same user.
- **Bar widgets**: battery/brightness/tailscale pills appear only where the
  hardware/service exists; toggle others in the ⋮ panel → Widgets & settings
  (state is local per machine, not tracked).

## Layout

| File | Applies to | Contents |
|---|---|---|
| `base.pkgs` | all machines | network, shell, core CLI, yadm |
| `hyprland.pkgs` | all machines | SDDM, Hyprland stack, pipewire, portals, fonts, theming, kitty |
| `apps.pkgs` | all machines | firefox, thunar, imv/mpv, vesktop, obsidian, bitwarden |
| `dev.pkgs` | all machines | neovim, go/rust/npm, ripgrep/fd/fzf, gh |
| `class/desktop.pkgs` | class `desktop` | nvidia-open, Sunshine (game-stream host) |
| `class/laptop.pkgs` | class `laptop` | nvidia-open + AMD hybrid (prime-run), power-profiles |
| `class/work.pkgs` | class `work` | nvidia-580xx (Pascal Quadros), Xorg + XFCE for RDP |
| `class/work.aur` | class `work` | xrdp, xorgxrdp — the only AUR packages anywhere |

Format: one package per line; `#` comments and blank lines ignored.
Adding a machine type = add `class/<name>.pkgs` (and optionally `.aur`).

## Machine classes

The class set via `yadm config local.class` drives two things:

1. **Packages** — bootstrap installs all top-level `*.pkgs` plus
   `class/$CLASS.pkgs` / `class/$CLASS.aur`.
2. **Config alternates** — yadm links `file##class.<name>` variants, e.g.
   `~/.config/hypr/env-gpu.conf##class.laptop` becomes `env-gpu.conf` on the
   laptop (GPU env vars differ per machine: NVIDIA-primary on desktop/work,
   AMD-primary with prime-run offload on the laptop).

## GPU driver map

| Machine | GPU | Driver |
|---|---|---|
| desktop | RTX 4080 SUPER (+ Ryzen iGPU) | `nvidia-open-dkms` (current branch) |
| laptop | RTX dGPU + AMD iGPU | `nvidia-open-dkms` + `vulkan-radeon`, offload via `prime-run` |
| work | Quadro P4000 / P2000 (Pascal) | `nvidia-580xx-dkms` (last branch supporting Pascal; in CachyOS repos, not AUR) |

CachyOS's `chwd` may pre-install a driver at install time; the lists use
`--needed` so they simply agree with it.

## Remote access map

- **desktop** — Sunshine host (pair from Moonlight at `https://<host>:47990`).
- **work** — xrdp → XFCE X11 session (Windows mstsc, session type "Xorg").
  Bootstrap writes `~/startwm.sh` (xrdp-sesman's per-user hook via
  `UserWindowManager` in sesman.ini); non-work classes get xrdp disabled.
- **laptop** — none (Tailscale + ssh only).

## Default applications

`~/.config/mimeapps.list` is tracked (browser/files/images/video/archives →
firefox/thunar/imv/mpv/xarchiver). No `xdg-mime` calls at bootstrap — edit the
file, it wins.

## Other bootstrap steps

- Enables NetworkManager, bluetooth, tailscaled now; **sddm on next boot**.
- Sets zsh as login shell.
- Stubs `~/.config/nvim/secrets.lua` (add real API keys after).
- Clones matugen-themes, installs Claude Code CLI (`CLAUDE_CODE_SKIP=1` to skip),
  warms Neovim plugins headlessly (`:Mason` finishes LSP binaries).
- Offers to build Hyprland plugins via hyprpm (interactive; never as root).
