"""Constants for Login Theme."""

DOMAIN = "login_theme"

LOGIN_PATH = "/auth/authorize"

# Keys the frontend integration uses in hass.data (see frontend/helpers.py).
DATA_THEMES = "frontend_themes"
DATA_DEFAULT_THEME = "frontend_default_theme"
DATA_DEFAULT_DARK_THEME = "frontend_default_dark_theme"

# Calibre brand colours (from the Calibre sidebar branding plugin).
BRAND_GOLD = "#C5A059"
BRAND_NAVY = "#0B1526"
BRAND_CREAM = "#EAE4D9"
BRAND_SLATE = "#5B6577"

FONTS_URL = (
    "https://fonts.googleapis.com/css2?family=Cinzel:wght@700"
    "&family=Montserrat:wght@500&display=swap"
)
