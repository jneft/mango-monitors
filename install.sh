#!/usr/bin/env sh
# Installs mango-monitors into ~/.local for the current user.
# Run ./install.sh to install, ./install.sh --uninstall to remove.

set -e

BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
SRC_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

if [ "$1" = "--uninstall" ] || [ "$1" = "-u" ]; then
    rm -f "$BIN_DIR/mango-monitors" "$APP_DIR/mango-monitors.desktop"
    echo "Removed mango-monitors."
    exit 0
fi

mkdir -p "$BIN_DIR" "$APP_DIR"
install -m 755 "$SRC_DIR/mango-monitors" "$BIN_DIR/mango-monitors"
install -m 644 "$SRC_DIR/mango-monitors.desktop" "$APP_DIR/mango-monitors.desktop"

echo "Installed:"
echo "  $BIN_DIR/mango-monitors"
echo "  $APP_DIR/mango-monitors.desktop"

case ":$PATH:" in
    *":$BIN_DIR:"*) ;;
    *) echo
       echo "Note: $BIN_DIR is not on your PATH. Add it, or launch the app"
       echo "from your application menu instead." ;;
esac
