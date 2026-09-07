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
| `class/<role>.pkgs` | matching class | role: what every desktop / laptop / work box wants |
| `class/<role>.aur` | matching class | AUR half of the same (work: xrdp, xorgxrdp) |
| `host/<name>.pkgs` | matching hostname | machine: what makes THIS box different (GPU, dock, fingerprint reader) |
| `gaming.pkgs` | opt-in (any class) | CachyOS gaming bundle: Steam/Proton/gamescope/MangoHud/Lutris/Heroic + gamemode |
| `gaming.aur` | opt-in (any class) | commented extras (vkBasalt, game-devices-udev) — off by default |
| `baseline.ignore` | not a list | the ISO's own package set, so `pkgs drift` can ignore it |

Format: one package per line; `#` comments and blank lines ignored (trailing
comments too). Adding a machine type = add `class/<name>.pkgs` (and optionally
`.aur`). Record new packages with `pkgs add` — see
[Keeping the lists current](#keeping-the-lists-current).

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

## Keeping the lists current

Bootstrap installs from these lists, so anything you `pacman -S` by hand is
missing from the next clean install unless it gets recorded. `~/.config/scripts/pkgs`
is what records it — **Super+Z** opens a picker, or from a terminal:

```sh
pkgs status         # counts + both lists below
pkgs drift          # installed by hand, not in any list  <- the one that matters
pkgs missing        # in a list but not installed
pkgs add neovim     # append to a list (asks which; -l dev.pkgs to skip the prompt)
pkgs baseline       # regenerate baseline.ignore after a reinstall
```

It knows about `class/` lists, which the old `add-package.sh` did not, so a
class package can actually be filed in the right place.

### Why `baseline.ignore` exists

A stock CachyOS install marks about **1100 packages** explicit before you ever
log in. Raw `pacman -Qqe` minus the lists is therefore almost entirely
Calamares' doing, and the handful you actually chose is invisible in it — on
this machine the raw number was 161, of which 9 were real.

`baseline.ignore` records that install set once so drift means *"I installed
this"* rather than *"the ISO did"*. It is **not** a package list: bootstrap only
globs `*.pkgs` / `*.aur` and never reads it.

`pkgs baseline` derives it from `/var/log/pacman.log`. The rule is about intent
rather than flags: **every automated command passes `--noconfirm`, because
nothing is there to answer a prompt; a person at a terminal does not.** So the
cut is the first pacman command that installs *named packages* without
`--noconfirm` — which skips the installer's whole run and the bare `-Sy`/`-Su`
syncs, and lands on the first thing typed by hand.

Matching on the installer's *flags* instead does not hold up: Calamares uses
`--sysroot` during the chroot phase but `--cachedir`/`-r /`/`--config`
afterwards, and a bare `pacman -Sy` carries no marker at all — an earlier
flag-based cut landed 6 minutes early and swallowed a third of the ISO set.

### Reading the two lists

`drift` is not always "add this". A package that is installed, deliberate, and
absent from every list can equally mean *it should be uninstalled* — retiring
Hyprland left `hyprland`, `hyprlock`, `xdg-desktop-portal-hyprland`, `uwsm` and
`swaync` on disk with nothing declaring them.

`missing` is expected to be non-empty on any machine: the class lists cover the
other machines too, so `xrdp` (work) and `sunshine` (desktop) will always show
up on a laptop. The list each package came from is printed alongside it for
exactly that reason.

## Profiles: role vs machine

Lists compose in **three layers**, all installed together:

| Layer | File | Selected by | Holds |
|---|---|---|---|
| every machine | `*.pkgs` | always | the shell, the compositor, apps, dev tools |
| **role** | `class/<role>.pkgs` | `yadm config local.class` | what every desktop / laptop / work box wants |
| **machine** | `host/<name>.pkgs` | short hostname | what makes *this* box different |

The two-laptop case is exactly why the host layer exists. An ASUS TUF with a
discrete NVIDIA card and an ultrabook on Intel graphics are both
`class=laptop` — they genuinely share the role (power profiles, lid handling)
and genuinely disagree about drivers. Forking the class into `tuf` and
`ultrabook` would duplicate everything they agree on, and the duplicates would
drift apart. So:

```
class/laptop.pkgs     power-profiles-daemon          # every laptop
host/ironhide.pkgs    nvidia-utils, vulkan-radeon…   # this laptop
host/zenbook.pkgs     intel-media-driver…            # the other one
```

Nothing to configure for the host layer — it keys on `hostname -s`, and your
machines are already named. A machine with no host list simply gets base +
class.

### Adding one

```sh
pkgs lists                                  # every list, and which apply here
pkgs add -l host/$(hostname -s).pkgs foo    # file it against this machine
pkgs add foo                                # or pick from a menu
```

The picker marks which lists apply to the machine you are on, and offers
`host/<thisbox>` even before the file exists — that friction is otherwise
exactly why machine-specific packages end up dumped in a class list. New lists
are created with a header explaining what belongs in them.

### The same two axes apply to config files

yadm materializes `file##class.<name>` and `file##hostname.<name>` variants, so
config splits the same way packages do — `mango/monitors.conf##class.desktop`
becomes `monitors.conf` on the desktop, and a per-machine variant would be
`##hostname.ironhide`. (Copies, not symlinks: `yadm.alt-copy` is set so the
compositor's inotify watch survives a re-alt.)

That means a second laptop needs no new mechanism for either half — name it,
add `host/<name>.pkgs`, and add `##hostname.<name>` config variants if its
displays or GPU env differ.

### GPU drivers are not chosen by class

`resolve_kernel_packages` reads **PCI vendor IDs** via `lspci`, not the class,
so an Intel-only laptop gets no NVIDIA kernel modules even though it is also
`class=laptop`. Class-based GPU logic breaks the moment two machines share a
role and not a GPU — which is the situation the host layer exists for.

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
