from jb_news import JBNews, NEWS_SOURCE_MQL5

API_KEY = "your_api_key_here"

if __name__ == "__main__":
    jb_news = JBNews()
    if jb_news.calendar(
        API_KEY,
        today=True,
        news_source=NEWS_SOURCE_MQL5,
    ):
        for event in jb_news.calendar_info:
            print(
                f"{event.date} | {event.currency} | {event.name} | Actual: {event.actual} | Forecast: {event.forecast} | Previous: {event.previous}"
            )
    else:
        print("Failed to load news data.")
