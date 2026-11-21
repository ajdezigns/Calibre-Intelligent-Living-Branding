"""Config flow for Login Theme."""

from __future__ import annotations

from typing import Any

from homeassistant.config_entries import ConfigFlow, ConfigFlowResult

from .const import DOMAIN


class LoginThemeConfigFlow(ConfigFlow, domain=DOMAIN):
    """Single-step flow: nothing to configure, the active theme is used."""

    VERSION = 1

    async def async_step_user(
        self, user_input: dict[str, Any] | None = None
    ) -> ConfigFlowResult:
        """Create the entry once the user confirms."""
        if user_input is not None:
            return self.async_create_entry(title="Calibre Intelligent Living Login", data={})
        return self.async_show_form(step_id="user")
