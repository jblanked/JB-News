import time
import datetime
import requests

NEWS_SOURCE_MQL5 = "mql5"
NEWS_SOURCE_FOREX_FACTORY = "forex-factory"
NEWS_SOURCE_FXSTREET = "fxstreet"


class CalendarInfo:
    """Struct for calendar information"""

    __slots__ = (
        "name",
        "currency",
        "event_id",
        "category",
        "date",
        "actual",
        "forecast",
        "previous",
        "outcome",
        "strength",
        "quality",
        "projection",
    )

    def __init__(
        self,
        name: str,
        currency: str,
        event_id: int,
        category: str,
        date: datetime,
        actual: float,
        forecast: float,
        previous: float,
        outcome: str,
        strength: str,
        quality: str,
        projection: str,
    ) -> None:
        self.name = name
        self.currency = currency
        self.event_id = event_id
        self.category = category
        self.date = date
        self.actual = actual
        self.forecast = forecast
        self.previous = previous
        self.outcome = outcome
        self.strength = strength
        self.quality = quality
        self.projection = projection


class EventInfo:
    """Struct for event information"""

    __slots__ = (
        "name",
        "currency",
        "event_id",
        "category",
        "impact",
        "history",
        "machine_learning",
        "smart_analysis",
        "patterns",
    )

    def __init__(
        self,
        name: str,
        currency: str,
        event_id: int,
        category: str,
        impact: str,
        history: list,
        machine_learning: dict,
        smart_analysis: dict,
    ) -> None:
        self.name: str = name
        self.currency: str = currency
        self.event_id: int = event_id
        self.category: str = category
        self.impact: str = impact
        self.history: list = history
        self.machine_learning: dict = machine_learning
        self.smart_analysis: dict = smart_analysis

        self.patterns = [
            "Actual > Forecast > Previous",
            "Actual > Forecast Forecast < Previous",
            "Actual > Forecast Actual < Previous",
            "Actual > Forecast Forecast = Previous",
            "Actual > Forecast Actual = Previous",
            "Actual < Forecast < Previous",
            "Actual < Forecast Forecast > Previous",
            "Actual < Forecast Actual > Previous",
            "Actual < Forecast = Previous",
            "Actual = Forecast = Previous",
            "Actual = Forecast > Previous",
            "Actual = Forecast < Previous",
            "Actual < Forecast Actual = Previous",
        ]

    def __division(self, a: float, b: float):
        """Division function"""
        return 0 if b == 0 else a / b

    def trend_smart_analysis(self, outcome: str) -> str:
        """Returns the trend based on the smart analysis data"""
        for pat in self.patterns:
            for value in self.smart_analysis:
                if str(value) == str(pat) and str(value) == str(outcome):
                    if str(self.smart_analysis[value]) == "Bullish":
                        return "Bullish"
                    if str(self.smart_analysis[value]) == "Bearish":
                        return "Bearish"
                    return "Neutral"

    def trend_machine_learning(self, outcome: str) -> str:
        """Returns the trend based on the machine learning data"""
        for pat in self.patterns:
            val = self.machine_learning["Outcomes"]
            for item in val:
                if pat == outcome:
                    if item == pat:
                        acc = (
                            float(self.machine_learning["1 Hour Accuracy"])
                            + float(self.machine_learning["30 Minute Accuracy"])
                            + float(self.machine_learning["1 Minute Accuracy"])
                        ) * 100

                        bullish = self.__division(
                            (
                                float(val[pat]["1 Minute"]["Bullish"])
                                + float(val[pat]["30 Minute"]["Bullish"])
                                + float(val[pat]["1 Hour"]["Bullish"])
                            ),
                            3,
                        )
                        bearish = self.__division(
                            (
                                float(val[pat]["1 Minute"]["Bearish"])
                                + float(val[pat]["30 Minute"]["Bearish"])
                                + float(val[pat]["1 Hour"]["Bearish"])
                            ),
                            3,
                        )
                        accuracy = self.__division(acc, 3)

                        if accuracy > 0.5:
                            if bullish > bearish:
                                return "Bullish"
                            if bearish > bullish:
                                return "Bearish"

                        return "Neutral"

    def is_event_time(self, iteration: int, current_time: datetime) -> bool:
        """Checks if the event time is the same as the current time"""
        event_time = self.history[iteration]["Date"]
        event_time = datetime.datetime.strptime(event_time, "%Y-%m-%d %H:%M:%S")
        return event_time != 0 and event_time == current_time

    def outcome(self, iteration: int) -> str:
        """Returns the outcome of the event"""
        actual = self.history[iteration]["Actual"]
        forecast = self.history[iteration]["Forecast"]
        previous = self.history[iteration]["Previous"]

        if actual > forecast > previous:
            return self.patterns[0]
        if forecast < previous < actual:
            return self.patterns[1]
        if forecast < actual < previous:
            return self.patterns[2]
        if actual > forecast and forecast == previous:
            return self.patterns[3]
        if actual > forecast and actual == previous:
            return self.patterns[4]
        if actual < forecast < previous:
            return self.patterns[5]
        if actual < forecast and forecast > previous:
            return self.patterns[6]
        if forecast > actual > previous:
            return self.patterns[7]
        if actual < forecast and forecast == previous:
            return self.patterns[8]
        if actual < forecast and actual == previous:
            return self.patterns[9]
        if actual == forecast and actual == previous:
            return self.patterns[10]
        if actual == forecast and forecast > previous:
            return self.patterns[11]
        if actual == forecast and forecast < previous:
            return self.patterns[12]

        return "Data Not Loaded"


class JBNews:
    """Class for handling news data from JBlanked News API"""

    def __init__(self):
        self.full_list = {}
        self.event_names = []
        self.event_ids = []
        self.list: list[dict] = []
        self.info: EventInfo = None
        self.calendar_info: list[CalendarInfo] = []
        self.offset = 0

    def __event_list(self):
        """Sets the event list"""
        usd_events = list(self.full_list["USD"]["Events"])
        eur_events = list(self.full_list["EUR"]["Events"])
        gbp_events = list(self.full_list["GBP"]["Events"])
        aud_events = list(self.full_list["AUD"]["Events"])
        cad_events = list(self.full_list["CAD"]["Events"])
        chf_events = list(self.full_list["CHF"]["Events"])
        jpy_events = list(self.full_list["JPY"]["Events"])
        nzd_events = list(self.full_list["NZD"]["Events"])
        self.__set_list(usd_events)
        self.__set_list(eur_events)
        self.__set_list(gbp_events)
        self.__set_list(aud_events)
        self.__set_list(cad_events)
        self.__set_list(chf_events)
        self.__set_list(jpy_events)
        self.__set_list(nzd_events)
        self.__set_basic_list(usd_events, "USD")
        self.__set_basic_list(eur_events, "EUR")
        self.__set_basic_list(gbp_events, "GBP")
        self.__set_basic_list(aud_events, "AUD")
        self.__set_basic_list(cad_events, "CAD")
        self.__set_basic_list(chf_events, "CHF")
        self.__set_basic_list(jpy_events, "JPY")
        self.__set_basic_list(nzd_events, "NZD")

    def __search(self, currency: str, event_id: int) -> bool:
        """Searches for the event"""
        event: dict
        for event in self.list:
            if str(event["Event_ID"]) == str(event_id):
                self.info.name = event["Name"]
                self.info.currency = currency
                self.info.event_id = event["Event_ID"]
                self.info.category = event.get("Category", "N/A")
                self.info.impact = event.get("Impact", "None")
                self.info.history = event.get("History", [])
                self.info.machine_learning = event.get("MachineLearning", {})
                self.info.smart_analysis = event.get("SmartAnalysis", {})
                return True

        return False

    def __set_list(self, events: list):
        """Sets the list"""
        for event in events:
            self.event_names.append(event["Name"])
            self.event_ids.append(event["Event_ID"])

    def __set_basic_list(self, events: list, currency: str) -> None:
        """Sets the basic list"""
        event: dict
        for event in events:
            history = event.get("History", [])

            if self.offset != 0 and history:
                for item in history:
                    item["Date"] = datetime.datetime.strptime(
                        item["Date"], "%Y.%m.%d %H:%M:%S"
                    ) - datetime.timedelta(hours=self.offset)

            self.list.append(
                {
                    "Name": event["Name"],
                    "Currency": currency,
                    "Event_ID": event["Event_ID"],
                    "Category": event.get("Category", "N/A"),
                    "Impact": event.get("Impact", "None"),
                    "History": history,
                    "MachineLearning": event.get("MachineLearning", {}),
                    "SmartAnalysis": event.get("SmartAnalysis", {}),
                }
            )

    def __set_calendar_list(self, json_data: dict):
        """Sets the calendar list"""
        self.calendar_info = []
        data: dict
        for data in json_data:
            if self.offset == 0:
                date = data["Date"]
            else:
                date = datetime.datetime.strptime(
                    data["Date"], "%Y.%m.%d %H:%M:%S"
                ) - datetime.timedelta(hours=self.offset)

            self.calendar_info.append(
                CalendarInfo(
                    name=data["Name"],
                    currency=data["Currency"],
                    event_id=data.get("Event_ID", "N/A"),
                    category=data.get("Category", "N/A"),
                    date=date,
                    actual=data["Actual"],
                    forecast=data["Forecast"],
                    previous=data["Previous"],
                    outcome=data.get("Outcome", "N/A"),
                    strength=data.get("Strength", "N/A"),
                    quality=data.get("Quality", "N/A"),
                    projection=data.get("Projection", "N/A"),
                )
            )

    def calendar(
        self,
        api_key: str,
        today=False,
        this_week=False,
        news_source: str = NEWS_SOURCE_MQL5,
    ) -> bool:
        """Gets the calendar data"""
        url = f"https://www.jblanked.com/news/api/{news_source}/calendar"
        if today or not this_week:
            url += "/today/"
        else:
            url += "/week/"

        if len(api_key) < 30:
            print("Error: Invalid API Key")
            return False
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Api-Key {api_key}",
        }
        response = requests.get(url, headers=headers, timeout=10)

        if response.status_code == 200:
            data = response.json()
            self.__set_calendar_list(data)
            return True
        print(f"Error: {response.status_code}")
        print(response.json())
        return False

    def get(self, api_key: str, news_source: str = NEWS_SOURCE_MQL5) -> bool:
        """Gets the news data"""
        url = f"https://www.jblanked.com/news/api/{news_source}/full-list/"
        if len(api_key) < 30:
            print("Error: Invalid API Key")
            return False
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Api-Key {api_key}",
        }
        response = requests.get(url, headers=headers, timeout=10)

        if response.status_code == 200:
            data = response.json()
            self.full_list = data
            self.__event_list()
            return True

        print(f"Error: {response.status_code}")
        print(response.json())
        return False

    def gpt(self, api_key: str, message: str, delay: int = 1) -> str:
        """Sends and receives data to the NewsGPT API"""
        url = "https://www.jblanked.com/news/api/gpt/"
        if len(api_key) < 30:
            print("Error: Invalid API Key")
            return "Error: Invalid API Key"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Api-Key {api_key}",
        }
        data = {"content": message}
        response = requests.post(url, headers=headers, json=data, timeout=10)

        if response.status_code == 200:
            task_id = response.json()["task_id"]
            print("Task started..")
            # Check if task is complete every 2 seconds
            while True:
                new_response = requests.get(
                    f"{url}status/{task_id}/", headers=headers, timeout=10
                )
                json_data = new_response.json()  # Should return a dictionary
                if json_data.get("status") == "completed":
                    return json_data.get("message")
                print("Task processing...")
                time.sleep(delay)
        else:
            json_data = response.json()
            print(json_data)
            return json_data

    def load(self, event_id: int) -> bool:
        """Loads the event from an event ID"""
        for currency in self.full_list:
            if self.__search(currency, event_id):
                return True

        return False
