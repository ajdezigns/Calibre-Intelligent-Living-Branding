# Calibre Intelligent Living — Sidebar Branding

Replaces the default "Home Assistant" sidebar title with the Calibre
wordmark, and the hamburger menu icon with the Calibre shield mark. Fully
self-contained (no separate image files) and automatically matches whichever
theme mode (Light/Dark/Auto) is active — no per-mode configuration needed.

Requires the [Calibre Intelligent Living theme](https://github.com/nadim-cil/Calibre-Intelligent-Living)
to be installed for the color-matching to look correct, though the script
will run without it.

## Installation via HACS

1. HACS → the three-dot menu (top right) → **Custom repositories**
2. Repository: `https://github.com/nadim-cil/Calibre-Intelligent-Living-Branding`
   Category: **Dashboard** (this is HACS's current label for what used to be called "Plugin")
3. Find it in HACS and click **Download**
4. **One manual step HACS can't do for you:** open `configuration.yaml` and
   add the file under `frontend.extra_module_url`:

   ```yaml
   frontend:
     themes: !include_dir_merge_named themes
     extra_module_url:
       - /hacsfiles/Calibre-Intelligent-Living-Branding/calibre-sidebar-branding.js
   ```

5. **Developer Tools → YAML → Check Configuration**, then **restart Home Assistant**
   (this specific setting only loads at startup — a reload won't pick it up)

Why the manual step: HACS auto-registers plugins as Lovelace *dashboard*
resources, but the sidebar isn't part of any dashboard — it's a persistent
piece of app chrome — so it needs the `extra_module_url` config instead,
which HACS has no way to edit on your behalf.

## Login page theming (custom integration)

The Home Assistant login page (`/auth/authorize`) loads before anyone signs
in, so themes and frontend plugins never reach it. The
**Calibre Intelligent Living Login** integration in
[`custom_components/login_theme`](custom_components/login_theme) themes it
from inside Home Assistant, so it applies to local connections, remote access
(Cloudflare Tunnel, Nabu Casa) and the companion apps alike:

- Applies your default theme's colours to the login page, in both light and
  dark mode, read live from Home Assistant (a theme reload is picked up on the
  next page load)
- Fills in Home Assistant's newer control colours (Log in button, checkbox,
  input fields) from the theme, so nothing is left HA blue
- Replaces the Home Assistant logo with the Calibre shield and wordmark
- Ships its own icon and logo for the Settings → Devices & Services page
  (shown on recent Home Assistant releases that support custom integration brand images)

If anything goes wrong while building the page, the stock login page is
served instead, so it can never lock you out. Removing the integration
restores the stock page immediately.

### Installation

HACS installs one category per repository, and this one is registered as
**Dashboard**, so the integration is installed manually:

1. Copy `custom_components/login_theme` into your Home Assistant
   `/config/custom_components/` folder (File editor, Studio Code Server or the
   Samba share), so you end up with
   `/config/custom_components/login_theme/__init__.py`
2. Restart Home Assistant
3. **Settings → Devices & Services → Add Integration**, search for
   **Calibre Intelligent Living Login** and click **Submit**
4. Sign out (or open a private window) to see the themed login page