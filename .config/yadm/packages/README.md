# Packages & Bootstrap

Bootstrap turns a **bare Arch-family install with no desktop selected** into a
complete [mango](https://github.com/DreamMaoMao/mangowc) Wayland workstation.

Works on **CachyOS** (the reference target) and on **plain Arch Linux**. See
[Portability](#portability) for how the two differ — it is a smaller gap than
you would expect: of the ~110 packages a laptop installs, plain Arch is missing
exactly three.

## Fresh machine runbook

```sh
# 1. Install CachyOS ("No Desktop") or Arch. Log into the TTY, then:
sudo pacman -S --needed git yadm

# 2. Clone dotfiles (say yes when it offers to run bootstrap, or run it yourself)
yadm clone https://github.com/perkelatorz/dotfiles

# 3. Tell yadm what this machine is (bootstrap prompts if you skip this)
yadm config local.class desktop   # or: laptop | work

# 4. Bootstrap (full -Syu, all packages, services, shell, defaults)
#    On plain Arch this offers to add the [cachyos] repo — see Portability.
yadm bootstrap

# 5. Reboot → SDDM → Mango. Then authenticate tailscale:
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

**Syncthing** (all machines) needs a one-time pairing per new box — bootstrap
enables the unit but cannot know about your other devices:

```sh
systemctl --user start syncthing        # bootstrap enables it; start it now
xdg-open http://127.0.0.1:8384          # GUI (localhost only by default)
```

In the GUI: **Actions → Show ID**, then on an already-paired machine **Add
Remote Device** and paste it. Use the peer's *Tailscale* IP (`100.x.y.z`) or
MagicDNS name as the address so it works off-LAN — Syncthing's local discovery
won't find a tailnet peer. Then share the `notes` folder (`~/notes`) with it.

The vault ships a `.stignore` that excludes `.git` and Obsidian's
`workspace.json`; see the comments in `~/notes/.stignore` for why.

### What to expect on first boot

- **GPU**: userspace drivers come from the class list; the *kernel module* is
  derived at bootstrap time by `resolve_kernel_packages` (see
  [GPU driver map](#gpu-driver-map)). The GPU segment in the bar's performance
  pill appears once `nvidia-smi` works.
- **Laptop hybrid graphics**: AMD iGPU should be primary. If the compositor
  grabs the dGPU (wrong outputs / poor battery), check card order with
  `ls -l /dev/dri/by-path/` and pin the iGPU in `~/.config/mango/env.conf`.
  Run heavy apps on the dGPU via `prime-run`.
- **Work RDP**: bootstrap writes `~/startwm.sh` (xrdp-sesman's per-user
  hook). From Windows: mstsc → host:3389 → session type "Xorg". Log out of
  the local mango session before RDP-ing as the same user.
- **Bar widgets**: battery/brightness/tailscale pills appear only where the
  hardware/service exists; toggle others in the ⋮ panel → Widgets & settings
  (state is local per machine, not tracked).

## Layout

| File | Applies to | Contents |
|---|---|---|
| `base.pkgs` | all machines | network, shell, core CLI, yadm, syncthing |
| `wayland.pkgs` | all machines | SDDM, pipewire, portals, fonts, theming, kitty, bar runtime deps |
| `mango.pkgs` | all machines | the mango compositor + its screencast portal |
| `apps.pkgs` | all machines | firefox, thunar, imv/mpv, vesktop, obsidian, bitwarden |
| `dev.pkgs` | all machines | neovim, go/rust/npm, ripgrep/fd/fzf, gh |
| `class/desktop.pkgs` | class `desktop` | NVIDIA userspace, Sunshine (game-stream host), gpu-screen-recorder |
| `class/laptop.pkgs` | class `laptop` | NVIDIA + AMD hybrid userspace (prime-run), power-profiles, lib32 drivers |
| `class/work.pkgs` | class `work` | nvidia-580xx (Pascal Quadros), Xorg + XFCE for RDP |
| `class/work.aur` | class `work` | xrdp, xorgxrdp — the only packages with no non-AUR source |
| `gaming.pkgs` | opt-in (any class) | CachyOS gaming bundle: Steam/Proton/gamescope/MangoHud/Lutris/Heroic + gamemode |
| `gaming.aur` | opt-in (any class) | commented extras (vkBasalt, game-devices-udev) — off by default |

Format: one package per line; `#` comments and blank lines ignored (trailing
comments too). Adding a machine type = add `class/<name>.pkgs` (and optionally
`.aur`).

**Not in any list:** kernel headers and NVIDIA kernel modules. They depend on
*which* kernel is installed, so bootstrap derives them — see
[GPU driver map](#gpu-driver-map).

## Gaming (opt-in)

Orthogonal to class — enable it wherever you actually game (desktop or laptop,
not the work box). It's off until you turn it on:

```sh
yadm config local.gaming true    # persist; bootstrap then always installs it
yadm bootstrap                   # (desktop/laptop also prompt once if unset)
# or, one-shot without persisting the choice:
BOOTSTRAP_GAMING=1 yadm bootstrap
```

**Packages** (`gaming.pkgs`) follow the [CachyOS gaming guide](https://wiki.cachyos.org/configuration/gaming/):
`cachyos-gaming-applications` pulls Steam, Lutris, Heroic, gamescope, goverlay,
MangoHud (+lib32), and `cachyos-gaming-meta` (proton-cachyos-slr, umu-launcher,
protontricks, wine-cachyos, winetricks, vulkan-tools + lib32 runtime libs). We
add `gamemode`/`lib32-gamemode` on top (the meta omits them). The 32-bit GPU
drivers live in the class lists (desktop already had `lib32-nvidia-utils`; the
laptop list now adds `lib32-nvidia-utils` + `lib32-vulkan-radeon` for offload).
AUR extras (`gaming.aur`: vkBasalt, game-devices-udev) ship commented-out.

**Compositor tweaks** live in `~/.config/mango/gaming.conf` (sourced last so it
overrides): `allow_tearing = true` + a per-game `immediate` window rule (lower
latency), `misc:vrr = 2` (VRR on fullscreen games only), and `no_blur`/`no_anim`/
`idle_inhibit = fullscreen` on game windows. A starter `~/.config/MangoHud/
MangoHud.conf` is tracked too (toggle overlay with Right Shift + F12).

**Per-game launch options** (Steam → game → Properties → Launch Options):

```
gamemoderun mangohud %command%              # perf governor + FPS/temp HUD
gamescope -f --hdr-enabled -- %command%     # HDR / integer scaling wrapper
__GL_SYNC_TO_VBLANK=0 mangohud %command%    # let the tearing rule work (NVIDIA)
```

**HDR** under mango needs the wl-only build (`mangowm-wlonly-git`, AUR) —
scenefx, which the default build renders through, has no Vulkan renderer. See
the worked notes in `mango/gaming.conf`.

## Machine classes

The class set via `yadm config local.class` drives two things:

1. **Packages** — bootstrap installs all top-level `*.pkgs` plus
   `class/$CLASS.pkgs` / `class/$CLASS.aur`.
2. **Config alternates** — yadm materializes `file##class.<name>` variants,
   e.g. `~/.config/mango/monitors.conf##class.desktop` becomes
   `monitors.conf` on the desktop. (Copies, not symlinks: `yadm.alt-copy` is
   set so the compositor's inotify watch survives a re-alt.)

## GPU driver map

The class lists carry only **userspace** driver packages (`nvidia-utils`,
`vulkan-radeon`, …), which are kernel-independent. The **kernel module** and
**headers** are not in any list — `resolve_kernel_packages` in bootstrap derives
them from the kernels actually installed.

It reads `/usr/lib/modules/*/pkgbase`, the file every Arch kernel package drops
to name its owner, and for each kernel emits:

| Kernel `pkgbase` | Headers | NVIDIA module |
|---|---|---|
| `linux-cachyos` | `linux-cachyos-headers` | `linux-cachyos-nvidia-open` (prebuilt) |
| `linux-cachyos-lts` | `linux-cachyos-lts-headers` | `linux-cachyos-lts-nvidia-open` |
| `linux` | `linux-headers` | `nvidia-open-dkms` (built via DKMS) |

**Why this is not just a list entry.** `nvidia-open-dkms` declares
`Conflicts With: NVIDIA-MODULE`, and every prebuilt `linux-*-nvidia-open`
declares `Provides: NVIDIA-MODULE`. Hardcoding the DKMS package — which the
class lists used to do — meant the list could never install cleanly on a
CachyOS kernel; it surfaced as the "NVIDIA branch swap needs interactive
confirmation" warning at the end of every bootstrap run. Exactly one
NVIDIA-MODULE provider is emitted per machine now.

| Machine | GPU | Userspace |
|---|---|---|
| desktop | RTX 4080 SUPER (+ Ryzen iGPU) | `nvidia-utils`, `lib32-nvidia-utils` |
| laptop | RTX dGPU + AMD iGPU | `nvidia-utils` + `vulkan-radeon`, offload via `prime-run` |
| work | Quadro P4000 / P2000 (Pascal) | `nvidia-580xx-dkms` + `-utils` — the legacy branch has no prebuilt per-kernel variant, so it stays a DKMS package |

CachyOS's `chwd` may pre-install a driver at install time; the lists use
`--needed` so they simply agree with it.

## Portability

Two distros are supported. The difference is narrow and lives entirely in which
*repos* are configured — no package list is conditional on the distro.

**Of the ~110 packages a `laptop` + gaming machine installs, plain Arch's
core/extra/multilib carry all but three:**

| Package | Why it is not in Arch | Source |
|---|---|---|
| `mangowm` | the compositor; never packaged for Arch | `[cachyos]`, or AUR `mangowm` |
| `vesktop` | Discord client | `[cachyos]`, or AUR `vesktop` |
| `cachyos-gaming-applications` | CachyOS's gaming meta | `[cachyos]` **only** — not in the AUR |

Plus, for the `work` class only: `xrdp` and `xorgxrdp`, which are AUR-only
everywhere (already isolated in `class/work.aur`).

### The `[cachyos]` repo

On plain Arch, bootstrap offers to add it. `[cachyos]` is an ordinary,
independent pacman repo — one section behind its own mirrorlist, ~840 packages:

```ini
[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
```

Bootstrap appends it **below** `core`/`extra`, so Arch keeps priority for
anything both carry. You get the missing packages as signed binaries and
nothing else changes.

> **This is deliberately not what upstream's `cachyos-repo.sh` does.** That
> script also inserts `cachyos-core-znver4` / `cachyos-extra-znver4` *above*
> `core`/`extra` and installs a patched `pacman`, which repoints your entire
> base system at CachyOS's optimized rebuilds. That is a much larger commitment
> than "I want mangowm as a binary", so bootstrap does not do it.

Undo at any time:

```sh
sudo sed -i '/^\[cachyos\]$/,+1d' /etc/pacman.conf
sudo pacman -Syu
```

**Decline it** and bootstrap falls back to the AUR (building `paru` from
`paru-bin` first, if needed) for `mangowm` and `vesktop`. The gaming list is
then skipped with a printed Arch-native equivalent, since
`cachyos-gaming-applications` exists in neither Arch nor the AUR.

Non-interactive: `BOOTSTRAP_CACHYOS_REPO=1` (add) or `=0` (skip).

### `[multilib]`

The gaming stack and the `lib32-*` GPU drivers need it. CachyOS enables it out
of the box; on plain Arch bootstrap uncomments the section for you.

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
- Enables the `syncthing` **user** unit (not started — pair it after login, see
  above) and turns on lingering so it keeps replicating `~/notes` after logout.
- Sets zsh as login shell.
- Stubs `~/.config/nvim/secrets.lua` (add real API keys after).
- Clones matugen-themes, installs Claude Code CLI (`CLAUDE_CODE_SKIP=1` to skip),
  warms Neovim plugins headlessly (`:Mason` finishes LSP binaries).
