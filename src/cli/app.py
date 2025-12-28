"""
Main Typer CLI application for Mangapill Downloader.
Orchestrates the full download workflow with interactive main menu.
"""

from pathlib import Path
from typing import Optional
import typer
from rich.console import Console
from rich.prompt import Prompt

from ..config import load_config, save_config, Config
from ..scrapers.manga import scrape_manga, MangaInfo
from ..downloader.manager import DownloadManager, DownloadResult
from ..converters.pdf import convert_to_pdf
from ..converters.cbz import convert_to_cbz
from .display import (
    show_banner,
    show_manga_info,
    show_chapters_table,
    show_settings,
    show_success,
    show_error,
    show_warning,
    show_info,
    show_download_summary,
)
from .prompts import (
    prompt_manga_url,
    prompt_chapter_selection,
    prompt_output_format,
    prompt_keep_images,
    prompt_settings_menu,
)

console = Console()
app = typer.Typer(
    name="mangapill",
    help="🚀 Beautiful CLI manga downloader for Mangapill.com",
    add_completion=False,
    rich_markup_mode="rich",
    invoke_without_command=True,
)


def show_main_menu() -> str:
    """
    Display main menu and get user choice.
    
    Returns:
        User's choice: '1' for download, '2' for settings, '3' for exit
    """
    console.print()
    console.print("[bold magenta]╭─────────────────────────────────╮[/bold magenta]")
    console.print("[bold magenta]│[/bold magenta]        [bold cyan]📋 Main Menu[/bold cyan]           [bold magenta]│[/bold magenta]")
    console.print("[bold magenta]╰─────────────────────────────────╯[/bold magenta]")
    console.print()
    console.print("  [bold cyan][1][/bold cyan] 📥 Download Manga")
    console.print("  [bold cyan][2][/bold cyan] ⚙️  Settings")
    console.print("  [bold cyan][3][/bold cyan] 🚪 Exit")
    console.print()
    
    return Prompt.ask(
        "[bold cyan]Select option[/bold cyan]",
        choices=["1", "2", "3"],
        default="1",
    )


def download_manga_interactive(config: Config) -> bool:
    """
    Run the interactive manga download flow.
    
    Args:
        config: Current configuration
        
    Returns:
        True if download was successful
    """
    # Get URL
    url = prompt_manga_url()
    
    # Fetch manga info
    console.print()
    show_info("Fetching manga information...")
    
    try:
        manga = scrape_manga(url)
    except Exception as e:
        show_error(f"Failed to fetch manga: {e}")
        return False
    
    # Display manga info
    console.print()
    show_manga_info(manga)
    
    if not manga.chapters:
        show_error("No chapters found!")
        return False
    
    # Show chapters
    console.print()
    show_chapters_table(manga.chapters)
    
    # Select chapters
    selected_chapters = prompt_chapter_selection(manga.chapters)
    
    # Select format
    config.output_format = prompt_output_format()
    
    # Ask about keeping images for PDF/CBZ
    if config.output_format in ["pdf", "cbz"]:
        config.keep_images = prompt_keep_images()
    
    # Start download
    console.print()
    show_info(f"Starting download of {len(selected_chapters)} chapter(s)...")
    console.print()
    
    # Create download manager
    manager = DownloadManager(config)
    
    # Track results
    download_results: list[tuple] = []  # (chapter, result)
    
    def on_complete(chapter, result: DownloadResult):
        if result.success:
            download_results.append((chapter, result))
        else:
            show_warning(f"Failed: {chapter.title} - {result.error}")
    
    # Download chapters
    results = manager.download_chapters(
        manga=manga,
        chapters=selected_chapters,
        on_chapter_complete=on_complete,
    )
    
    # Convert to PDF/CBZ if needed
    successful_conversions = 0
    failed_conversions = 0
    
    if config.output_format in ["pdf", "cbz"] and download_results:
        console.print()
        show_info(f"Converting to {config.output_format.upper()}...")
        
        for chapter, result in download_results:
            if result.path and result.path.exists():
                if config.output_format == "pdf":
                    pdf_path = convert_to_pdf(
                        result.path,
                        keep_images=config.keep_images,
                    )
                    if pdf_path:
                        successful_conversions += 1
                        show_success(f"Created: {pdf_path.name}")
                    else:
                        failed_conversions += 1
                
                elif config.output_format == "cbz":
                    cbz_path = convert_to_cbz(
                        result.path,
                        manga=manga,
                        chapter=chapter,
                        keep_images=config.keep_images,
                    )
                    if cbz_path:
                        successful_conversions += 1
                        show_success(f"Created: {cbz_path.name}")
                    else:
                        failed_conversions += 1
    
    # Show summary
    console.print()
    successful = sum(1 for r in results if r.success)
    failed = sum(1 for r in results if not r.success)
    
    show_download_summary(
        successful=successful,
        failed=failed,
        output_dir=str(Path(config.output_dir).absolute()),
    )
    
    if config.output_format in ["pdf", "cbz"]:
        console.print(f"[cyan]   Converted: {successful_conversions} {config.output_format.upper()}(s)[/cyan]")
    
    return True


@app.callback(invoke_without_command=True)
def main(ctx: typer.Context):
    """
    🚀 Beautiful CLI manga downloader for Mangapill.com
    
    Run without arguments for interactive mode.
    """
    # If a subcommand is being called, don't run the main menu
    if ctx.invoked_subcommand is not None:
        return
    
    # Show banner
    show_banner()
    
    # Load config
    config = load_config()
    
    # Main loop
    while True:
        choice = show_main_menu()
        
        if choice == "1":
            # Download manga
            download_manga_interactive(config)
            
            # Ask to continue or exit
            console.print()
            console.print("  [bold cyan][1][/bold cyan] 📥 Download another manga")
            console.print("  [bold cyan][2][/bold cyan] 🚪 Exit")
            console.print()
            continue_choice = Prompt.ask(
                "[bold cyan]What would you like to do?[/bold cyan]",
                choices=["1", "2"],
                default="1",
            )
            
            if continue_choice == "2":
                console.print()
                console.print("[bold green]👋 Thank you for using Mangapill Downloader![/bold green]")
                break
        
        elif choice == "2":
            # Settings
            console.print()
            show_settings(config)
            
            if typer.confirm("\nModify settings?", default=False):
                config = prompt_settings_menu(config)
        
        elif choice == "3":
            # Exit
            console.print()
            console.print("[bold green]👋 Thank you for using Mangapill Downloader![/bold green]")
            break


@app.command("download")
def download_cmd(
    url: Optional[str] = typer.Argument(
        None,
        help="Mangapill manga URL (interactive if not provided)",
    ),
    chapters: Optional[str] = typer.Option(
        None, "-c", "--chapters",
        help="Chapter selection (e.g., 'all', '1-10', '1,3,5')",
    ),
    format: Optional[str] = typer.Option(
        None, "-f", "--format",
        help="Output format: images, pdf, cbz",
    ),
    output: Optional[str] = typer.Option(
        None, "-o", "--output",
        help="Output directory",
    ),
):
    """
    📥 Download manga chapters from Mangapill (non-interactive).
    """
    # Show banner
    show_banner()
    
    # Load config
    config = load_config()
    
    # Override config with CLI options
    if output:
        config.output_dir = output
    if format:
        config.output_format = format.lower()
    
    # Get URL (interactive if not provided)
    if not url:
        url = prompt_manga_url()
    
    # Fetch manga info
    console.print()
    show_info("Fetching manga information...")
    
    try:
        manga = scrape_manga(url)
    except Exception as e:
        show_error(f"Failed to fetch manga: {e}")
        raise typer.Exit(1)
    
    # Display manga info
    console.print()
    show_manga_info(manga)
    
    if not manga.chapters:
        show_error("No chapters found!")
        raise typer.Exit(1)
    
    # Show chapters
    console.print()
    show_chapters_table(manga.chapters)
    
    # Select chapters
    if chapters:
        # Parse from CLI arg
        if chapters.lower() == "all":
            selected_chapters = manga.chapters
        else:
            from .prompts import parse_chapter_selection
            try:
                indices = parse_chapter_selection(chapters, len(manga.chapters))
                selected_chapters = [manga.chapters[i] for i in indices]
            except ValueError as e:
                show_error(f"Invalid chapter selection: {e}")
                raise typer.Exit(1)
    else:
        # Interactive selection
        selected_chapters = prompt_chapter_selection(manga.chapters)
    
    # Select format (interactive if not set)
    if not format or format.lower() not in ["images", "pdf", "cbz"]:
        config.output_format = prompt_output_format()
    
    # Ask about keeping images for PDF/CBZ
    if config.output_format in ["pdf", "cbz"]:
        config.keep_images = prompt_keep_images()
    
    # Start download
    console.print()
    show_info(f"Starting download of {len(selected_chapters)} chapter(s)...")
    console.print()
    
    # Create download manager
    manager = DownloadManager(config)
    
    # Track results
    download_results: list[tuple] = []
    
    def on_complete(chapter, result: DownloadResult):
        if result.success:
            download_results.append((chapter, result))
        else:
            show_warning(f"Failed: {chapter.title} - {result.error}")
    
    # Download chapters
    results = manager.download_chapters(
        manga=manga,
        chapters=selected_chapters,
        on_chapter_complete=on_complete,
    )
    
    # Convert to PDF/CBZ if needed
    successful_conversions = 0
    
    if config.output_format in ["pdf", "cbz"] and download_results:
        console.print()
        show_info(f"Converting to {config.output_format.upper()}...")
        
        for chapter, result in download_results:
            if result.path and result.path.exists():
                if config.output_format == "pdf":
                    pdf_path = convert_to_pdf(
                        result.path,
                        keep_images=config.keep_images,
                    )
                    if pdf_path:
                        successful_conversions += 1
                        show_success(f"Created: {pdf_path.name}")
                
                elif config.output_format == "cbz":
                    cbz_path = convert_to_cbz(
                        result.path,
                        manga=manga,
                        chapter=chapter,
                        keep_images=config.keep_images,
                    )
                    if cbz_path:
                        successful_conversions += 1
                        show_success(f"Created: {cbz_path.name}")
    
    # Show summary
    console.print()
    successful = sum(1 for r in results if r.success)
    failed = sum(1 for r in results if not r.success)
    
    show_download_summary(
        successful=successful,
        failed=failed,
        output_dir=str(Path(config.output_dir).absolute()),
    )
    
    if config.output_format in ["pdf", "cbz"]:
        console.print(f"[cyan]   Converted: {successful_conversions} {config.output_format.upper()}(s)[/cyan]")


@app.command("settings")
def settings_cmd():
    """
    ⚙️  View and modify settings.
    """
    show_banner()
    
    config = load_config()
    
    console.print()
    show_settings(config)
    
    if typer.confirm("\nModify settings?", default=False):
        config = prompt_settings_menu(config)


@app.command("info")
def info_cmd(
    url: str = typer.Argument(..., help="Mangapill manga URL"),
):
    """
    📖 Display manga information without downloading.
    """
    show_banner()
    
    show_info("Fetching manga information...")
    
    try:
        manga = scrape_manga(url)
    except Exception as e:
        show_error(f"Failed to fetch manga: {e}")
        raise typer.Exit(1)
    
    console.print()
    show_manga_info(manga)
    
    console.print()
    show_chapters_table(manga.chapters)


def run():
    """Run the CLI application."""
    app()


if __name__ == "__main__":
    run()
