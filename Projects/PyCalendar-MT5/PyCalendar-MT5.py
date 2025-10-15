# Copyright 2024-2025,JBlanked LLC
# https://www.jblanked.com/trading-tools/

import subprocess
import sys
import tkinter as tk
from tkinter import ttk
import MetaTrader5 as mt5

API_KEY: str = "YOUR_API_KEY"
OFFSET: int = 7  # GMT-3 = 0, GMT = 3, EST = 7, PST = 10
SOURCE: str = "mql5"  # Options: "mql5", "forex-factory"


def install_package(package_name: str) -> bool:
    """Installs a Python package using pip."""
    try:
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", package_name, "--upgrade"]
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error installing {package_name}: {e}")
        return False


def fetch_news() -> list[dict]:
    """Fetches the news from the NewsAPI"""
    try:
        # Now try to import the module by name
        from jb_news.news import CJBNews

        if not API_KEY or len(API_KEY) < 30:
            raise ValueError("Please provide a valid API key.")
            quit()

        news_data = []

        jb = CJBNews()
        jb.offset = OFFSET

        if jb.calendar(API_KEY, this_week=True, news_source=SOURCE):
            for data in jb.calendar_info:
                news_data.append(
                    {
                        "name": data.name,
                        "currency": data.currency,
                        "event_id": data.event_id,
                        "date": data.date,
                        "actual": data.actual,
                        "forecast": data.forecast,
                        "previous": data.previous,
                    }
                )

        return news_data
    except Exception as e:
        print(f"Failed to fetch calendar data: {e}")
        return []


def display() -> None:
    """Show the tkinter"""
    news: list = fetch_news()
    if not news:
        quit()

    root = tk.Tk()
    root.title("Economic News Calendar 📅")
    root.geometry("1200x600")

    # Create Treeview
    tree = ttk.Treeview(
        root,
        columns=("Date", "Currency", "Event", "Actual", "Forecast", "Previous"),
        show="headings",
        height=20,
    )

    # Define headings
    tree.heading("Date", text="Date 📅")
    tree.heading("Currency", text="Currency 💰")
    tree.heading("Event", text="Event 📊")
    tree.heading("Actual", text="Actual ✅")
    tree.heading("Forecast", text="Forecast 🔮")
    tree.heading("Previous", text="Previous 📈")

    # Define column widths
    tree.column("Date", width=150, anchor="center")
    tree.column("Currency", width=100, anchor="center")
    tree.column("Event", width=300, anchor="w")
    tree.column("Actual", width=100, anchor="center")
    tree.column("Forecast", width=100, anchor="center")
    tree.column("Previous", width=100, anchor="center")

    # Add scrollbar
    scrollbar = ttk.Scrollbar(root, orient=tk.VERTICAL, command=tree.yview)
    tree.configure(yscroll=scrollbar.set)

    # Pack widgets
    tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
    scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

    # Sort news by date
    news_sorted = sorted(news, key=lambda x: x["date"])

    # Currency to emoji mapping
    CURRENCY_EMOJIS: dict = {
        "USD": "🇺🇸",
        "EUR": "🇪🇺",
        "GBP": "🇬🇧",
        "JPY": "🇯🇵",
        "CAD": "🇨🇦",
        "AUD": "🇦🇺",
        "CHF": "🇨🇭",
        "NZD": "🇳🇿",
    }

    # Insert data
    for event in news_sorted:
        currency_emoji = CURRENCY_EMOJIS.get(event["currency"], event["currency"])
        tree.insert(
            "",
            tk.END,
            values=(
                event["date"],
                f"{currency_emoji} {event['currency']}",
                event["name"],
                event["actual"] if event["actual"] else "N/A",
                event["forecast"] if event["forecast"] else "N/A",
                event["previous"] if event["previous"] else "N/A",
            ),
        )

    root.mainloop()


def main() -> None:
    """Run the main function"""

    # open MT5
    mt5.initialize()

    # install JB-News Library if not installed already
    if not "jb-news" in sys.modules:
        if not install_package("jb-news"):
            quit()

    # install tkinter Library if not installed already
    if not "tkinter" in sys.modules:
        if not install_package("tkinter"):
            quit()

    # display data
    display()

    # shut down connection to the MetaTrader 5 terminal
    mt5.shutdown()


# Run the script
if __name__ == "__main__":
    main()
