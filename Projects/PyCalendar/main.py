import tkinter as tk
from tkinter import ttk
from jb_news.news import CJBNews

API_KEY = "YOUR_API_KEY"
OFFSET = 7  # GMT-3 = 0, GMT = 3, EST = 7, PST = 10
SOURCE = "mql5"  # Options: "mql5", "forex-factory"


def fetch_news() -> list[dict]:
    """Fetches the news from the NewsAPI"""
    if not API_KEY or len(API_KEY) < 30:
        raise ValueError("Please provide a valid API key.")

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


# Currency to emoji mapping
CURRENCY_EMOJIS = {
    "USD": "🇺🇸",
    "EUR": "🇪🇺",
    "GBP": "🇬🇧",
    "JPY": "🇯🇵",
    "CAD": "🇨🇦",
    "AUD": "🇦🇺",
    "CHF": "🇨🇭",
    "NZD": "🇳🇿",
}


if __name__ == "__main__":
    news = fetch_news()

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
