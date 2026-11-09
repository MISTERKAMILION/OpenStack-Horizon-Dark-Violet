# OpenStack-Horizon-Dark-Violet

A modern dark violet theme for the OpenStack Horizon dashboard, installed on Kolla-Ansible deployments with a single script.

Dark Violet replaces Horizon's default look with a dark, gradient-accented interface: pill-shaped navigation, rounded cards and forms, donut usage charts, and a custom logo and favicon. It ships in two color variants and is fully reversible.

<p align="center">
  <img src="docs/screenshots/overview.png" alt="Dark Violet theme - Compute overview" width="100%">
</p>

<p align="center">
  <img src="docs/screenshots/instances.png" alt="Dark Violet theme - Instances" width="100%">
</p>

---

## Features

- **Two variants**: `black` (black + violet, default) and `navy` (navy + violet).
- **Official Kolla-Ansible method**: the theme is registered through `horizon_custom_themes` and deployed with `kolla-ansible reconfigure -t horizon`, so it survives upgrades and redeploys.
- **Complete restyle**: navbar, sidebar, panels, tables, forms, buttons, modals, dropdowns, pagination, breadcrumbs, progress bars and the login page.
- **Donut charts**: the Limit Summary pie charts on the Overview page are restyled as donuts.
- **Custom branding**: SVG logo, login-page logo and favicon.
- **Safe and reversible**: one command removes the theme and restores your configuration.
- **Idempotent**: re-running the installer cleanly replaces the previous install.

## Requirements

| Requirement | Notes |
|---|---|
| OpenStack deployed with **Kolla-Ansible** | A release that supports `horizon_custom_themes` in `globals.yml` |
| Root / sudo on the deployment host | The script re-launches itself with sudo if needed |
| Docker | Used by the live-install fallback |
| `kolla-ansible` and your inventory | Auto-detected, or pass `INVENTORY=` |
| ImageMagick (optional) | Only needed to generate the favicon; skipped if missing |

## Quick start

```bash
git clone https://github.com/<your-username>/openstack-horizon-dark-violet.git
cd openstack-horizon-dark-violet
sudo bash install-dark-violet.sh
```

Wait about 30 seconds for Horizon to restart, then hard-refresh your browser (`Ctrl+Shift+R`).

## Usage

| Goal | Command |
|---|---|
| Install (black + violet) | `sudo bash install-dark-violet.sh` |
| Install the navy + violet variant | `sudo VARIANT=navy bash install-dark-violet.sh` |
| Use a specific inventory file | `sudo INVENTORY=/path/to/inventory bash install-dark-violet.sh` |
| Target a specific Horizon container | `sudo HORIZON_CONTAINER=horizon bash install-dark-violet.sh` |
| Remove the theme | `sudo bash install-dark-violet.sh --revert` |

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `VARIANT` | `black` | Color palette: `black` or `navy` |
| `INVENTORY` | auto-detected | Path to your Kolla-Ansible inventory (`all-in-one`, `multinode`, ...) |
| `HORIZON_CONTAINER` | `horizon` | Horizon container name, used only by the live-install fallback |

## How it works

1. **Generates the theme** (SCSS variables, styles, logo, favicon) in `/etc/kolla/config/horizon/themes/dark-violet`.
2. **Registers it with Kolla**:
   - appends a marked block to `/etc/kolla/globals.yml` defining `horizon_custom_themes`;
   - appends a marked block to `/etc/kolla/config/horizon/_9999-custom-settings.py` that sets `SELECTABLE_THEMES` and `DEFAULT_THEME`.
3. **Deploys** with `kolla-ansible reconfigure -t horizon`.

All edits are wrapped in `# >>> DARKVIOLET` / `# <<< DARKVIOLET` markers, which is how `--revert` finds and removes them. A backup of your custom settings file is saved as `_9999-custom-settings.py.darkviolet.bak` the first time the script runs.

### Fallback: live install

If `kolla-ansible` or an inventory cannot be found, the script installs the theme directly into the running Horizon container, then runs `collectstatic` and `compress` and restarts it. This works immediately, but **the change is lost on the next `reconfigure` or upgrade**. Re-run the script afterwards, or set `INVENTORY=` to use the permanent method.

## Customization

The color palette is defined at the top of `install-dark-violet.sh` (the `PAL=` lines). Edit the hex values to create your own variant, then re-run the installer. Component styling lives in the `_styles.scss` block of the same script.

## Troubleshooting

**The theme does not appear after install.**
Wait about 30 seconds, then hard-refresh (`Ctrl+Shift+R`). Check that the Horizon container restarted: `docker ps | grep horizon`.

**"horizon_custom_themes" already exists in globals.yml.**
The script will not overwrite an existing entry. Add this under it manually, then re-run:

```yaml
  - name: dark-violet
    label: Dark Violet
```

**"No horizon container found".**
Set `INVENTORY=` for the permanent method, or `HORIZON_CONTAINER=<name>` for the live install.

**Favicon is missing.**
Install ImageMagick (`apt install imagemagick`) and re-run the script.

**Theme disappeared after an upgrade.**
This only happens with the live-install fallback. Re-run the script with `INVENTORY=` set.

## Uninstall

```bash
sudo bash install-dark-violet.sh --revert
```

This removes the Dark Violet blocks from `globals.yml` and the custom settings file, deletes the theme directory, and reconfigures Horizon.

## Repository layout

```
openstack-horizon-dark-violet/
├── install-dark-violet.sh     # installer / reverter
├── docs/
│   └── screenshots/
│       ├── overview.png
│       └── instances.png
├── LICENSE
└── README.md
```

## Contributing

Issues and pull requests are welcome. When reporting a bug, please include your Kolla-Ansible and OpenStack release, the variant you used, and a screenshot of the affected page.

## License

Released under the MIT License. See [LICENSE](LICENSE).

## Disclaimer

This is an independent community project. It is not affiliated with or endorsed by the OpenInfra Foundation, the OpenStack project, or the Kolla project. OpenStack is a trademark of the OpenInfra Foundation.
