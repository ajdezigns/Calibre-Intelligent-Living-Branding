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
