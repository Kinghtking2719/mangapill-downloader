"""
Mangapill Downloader - GUI Entry Point
Beautiful PyQt6 + QML interface for manga downloading.

Usage:
    python gui/main_gui.py          # Software rendering (default, works everywhere)
    python gui/main_gui.py --gpu    # Hardware GPU rendering (faster, may not work on all systems)
"""

import sys
import os
from pathlib import Path

# Check for --gpu flag BEFORE importing Qt
USE_GPU = "--gpu" in sys.argv
if "--gpu" in sys.argv:
    sys.argv.remove("--gpu")  # Remove so Qt doesn't see it

# Force Basic style to avoid Windows DLL issues
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

if not USE_GPU:
    # Default: Software rendering (works on all systems)
    # Fixes "COM error 0x887a0005: Device removed" on problematic GPUs
    os.environ["QT_QUICK_BACKEND"] = "software"
    os.environ["QT_OPENGL"] = "software"
    os.environ["QSG_RENDER_LOOP"] = "basic"
else:
    # GPU mode: Use hardware acceleration (faster but may crash on some systems)
    print("🎮 GPU mode enabled - using hardware acceleration")

from PyQt6.QtWidgets import QApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QUrl
from PyQt6.QtGui import QIcon

# Add src to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from gui.bridge import MangaBridge


def main():
    """Launch the GUI application."""
    # Set application attributes
    app = QApplication(sys.argv)
    app.setApplicationName("Mangapill Downloader")
    app.setOrganizationName("Yui007")
    app.setApplicationVersion("1.0.0")
    
    # Create QML engine
    engine = QQmlApplicationEngine()
    
    # Create and register the bridge
    bridge = MangaBridge()
    engine.rootContext().setContextProperty("bridge", bridge)
    
    # Load the main QML file
    qml_file = Path(__file__).parent / "qml" / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    # Check if QML loaded successfully
    if not engine.rootObjects():
        print("Error: Failed to load QML")
        sys.exit(-1)
    
    # Run the application
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
