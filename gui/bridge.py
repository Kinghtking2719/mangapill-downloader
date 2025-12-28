"""
Bridge module for PyQt6 ↔ QML communication.
Connects the QML frontend to the existing Python backend.
"""

from pathlib import Path
from typing import Optional
from dataclasses import asdict

from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, pyqtProperty, QThread, QVariant

# Import existing backend modules
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))

from src.config import load_config, save_config, Config
from src.scrapers.manga import scrape_manga, MangaInfo, Chapter
from src.scrapers.chapter import scrape_chapter_images
from src.downloader.manager import DownloadManager, DownloadResult
from src.converters.pdf import convert_to_pdf
from src.converters.cbz import convert_to_cbz


class ScraperWorker(QThread):
    """Worker thread for scraping manga info."""
    finished = pyqtSignal(dict)
    error = pyqtSignal(str)
    
    def __init__(self, url: str):
        super().__init__()
        self.url = url
    
    def run(self):
        try:
            manga = scrape_manga(self.url)
            # Convert to dict for QML
            result = {
                "title": manga.title,
                "url": manga.url,
                "cover_url": manga.cover_url or "",
                "description": manga.description or "",
                "manga_type": manga.manga_type or "",
                "status": manga.status or "",
                "year": manga.year or "",
                "genres": manga.genres,
                "chapters_count": manga.chapters_count,
                "chapters": [
                    {"title": ch.title, "url": ch.url, "number": ch.number or ""}
                    for ch in manga.chapters
                ]
            }
            self.finished.emit(result)
        except Exception as e:
            self.error.emit(str(e))


class DownloadWorker(QThread):
    """Worker thread for downloading chapters."""
    progress = pyqtSignal(int, int, str)  # current, total, status
    chapter_complete = pyqtSignal(str, bool)  # chapter title, success
    finished = pyqtSignal(int, int)  # successful, failed
    error = pyqtSignal(str)
    
    def __init__(self, manga_data: dict, chapter_indices: list, config: Config):
        super().__init__()
        self.manga_data = manga_data
        self.chapter_indices = chapter_indices
        self.config = config
        self._is_cancelled = False
    
    def cancel(self):
        self._is_cancelled = True
    
    def run(self):
        try:
            # Reconstruct MangaInfo from dict
            chapters = [
                Chapter(
                    title=ch["title"],
                    url=ch["url"],
                    number=ch.get("number")
                )
                for ch in self.manga_data["chapters"]
            ]
            
            manga = MangaInfo(
                title=self.manga_data["title"],
                url=self.manga_data["url"],
                cover_url=self.manga_data.get("cover_url"),
                description=self.manga_data.get("description"),
                manga_type=self.manga_data.get("manga_type"),
                status=self.manga_data.get("status"),
                year=self.manga_data.get("year"),
                genres=self.manga_data.get("genres", []),
                chapters=chapters,
            )
            
            # Get selected chapters
            selected_chapters = [chapters[i] for i in self.chapter_indices]
            
            # Create download manager
            manager = DownloadManager(self.config)
            
            successful = 0
            failed = 0
            total = len(selected_chapters)
            
            for i, chapter in enumerate(selected_chapters):
                if self._is_cancelled:
                    break
                
                self.progress.emit(i + 1, total, f"Downloading {chapter.title}")
                
                result = manager.download_chapter_images(
                    chapter=chapter,
                    manga_title=manga.safe_title,
                    progress=None,
                )
                
                if result.success:
                    successful += 1
                    self.chapter_complete.emit(chapter.title, True)
                    
                    # Convert if needed
                    if self.config.output_format == "pdf" and result.path:
                        convert_to_pdf(result.path, keep_images=self.config.keep_images)
                    elif self.config.output_format == "cbz" and result.path:
                        convert_to_cbz(
                            result.path,
                            manga=manga,
                            chapter=chapter,
                            keep_images=self.config.keep_images,
                        )
                else:
                    failed += 1
                    self.chapter_complete.emit(chapter.title, False)
            
            self.finished.emit(successful, failed)
            
        except Exception as e:
            self.error.emit(str(e))


class MangaBridge(QObject):
    """
    Bridge between QML and Python backend.
    Exposes all necessary functions and properties to QML.
    """
    
    # Signals for async operations
    mangaLoaded = pyqtSignal(QVariant)
    mangaError = pyqtSignal(str)
    downloadProgress = pyqtSignal(int, int, str)
    downloadChapterComplete = pyqtSignal(str, bool)
    downloadFinished = pyqtSignal(int, int)
    downloadError = pyqtSignal(str)
    configChanged = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        self._config = load_config()
        self._current_manga = None
        self._scraper_worker = None
        self._download_worker = None
    
    # ==================== Config Properties ====================
    
    @pyqtProperty(str, notify=configChanged)
    def outputDir(self):
        return self._config.output_dir
    
    @outputDir.setter
    def outputDir(self, value: str):
        self._config.output_dir = value
        self.configChanged.emit()
    
    @pyqtProperty(str, notify=configChanged)
    def outputFormat(self):
        return self._config.output_format
    
    @outputFormat.setter
    def outputFormat(self, value: str):
        self._config.output_format = value
        self.configChanged.emit()
    
    @pyqtProperty(bool, notify=configChanged)
    def keepImages(self):
        return self._config.keep_images
    
    @keepImages.setter
    def keepImages(self, value: bool):
        self._config.keep_images = value
        self.configChanged.emit()
    
    @pyqtProperty(int, notify=configChanged)
    def maxChapterWorkers(self):
        return self._config.max_chapter_workers
    
    @maxChapterWorkers.setter
    def maxChapterWorkers(self, value: int):
        self._config.max_chapter_workers = value
        self.configChanged.emit()
    
    @pyqtProperty(int, notify=configChanged)
    def maxImageWorkers(self):
        return self._config.max_image_workers
    
    @maxImageWorkers.setter
    def maxImageWorkers(self, value: int):
        self._config.max_image_workers = value
        self.configChanged.emit()
    
    @pyqtProperty(int, notify=configChanged)
    def retryCount(self):
        return self._config.retry_count
    
    @retryCount.setter
    def retryCount(self, value: int):
        self._config.retry_count = value
        self.configChanged.emit()
    
    @pyqtProperty(float, notify=configChanged)
    def retryDelay(self):
        return self._config.retry_base_delay
    
    @retryDelay.setter
    def retryDelay(self, value: float):
        self._config.retry_base_delay = value
        self.configChanged.emit()
    
    # ==================== Slots (callable from QML) ====================
    
    @pyqtSlot()
    def saveConfig(self):
        """Save current configuration to file."""
        save_config(self._config)
    
    @pyqtSlot()
    def loadConfig(self):
        """Reload configuration from file."""
        self._config = load_config()
        self.configChanged.emit()
    
    @pyqtSlot(str)
    def fetchManga(self, url: str):
        """Fetch manga info from URL (async)."""
        if self._scraper_worker and self._scraper_worker.isRunning():
            return
        
        self._scraper_worker = ScraperWorker(url)
        self._scraper_worker.finished.connect(self._on_manga_loaded)
        self._scraper_worker.error.connect(self._on_manga_error)
        self._scraper_worker.start()
    
    def _on_manga_loaded(self, data: dict):
        """Handle manga loaded."""
        self._current_manga = data
        self.mangaLoaded.emit(data)
    
    def _on_manga_error(self, error: str):
        """Handle manga fetch error."""
        self.mangaError.emit(error)
    
    @pyqtSlot(QVariant, QVariant)
    def startDownload(self, manga_data, chapter_indices):
        """Start downloading selected chapters (async)."""
        if self._download_worker and self._download_worker.isRunning():
            return
        
        # Convert QVariant to Python types
        manga_dict = dict(manga_data.toVariant()) if hasattr(manga_data, 'toVariant') else manga_data
        indices = list(chapter_indices.toVariant()) if hasattr(chapter_indices, 'toVariant') else list(chapter_indices)
        
        self._download_worker = DownloadWorker(manga_dict, indices, self._config)
        self._download_worker.progress.connect(self.downloadProgress.emit)
        self._download_worker.chapter_complete.connect(self.downloadChapterComplete.emit)
        self._download_worker.finished.connect(self.downloadFinished.emit)
        self._download_worker.error.connect(self.downloadError.emit)
        self._download_worker.start()
    
    @pyqtSlot()
    def cancelDownload(self):
        """Cancel ongoing download."""
        if self._download_worker and self._download_worker.isRunning():
            self._download_worker.cancel()
    
    @pyqtSlot(result=str)
    def getOutputDir(self):
        """Get absolute output directory path."""
        return str(Path(self._config.output_dir).absolute())
