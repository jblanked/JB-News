from dataclasses import dataclass
import requests
import datetime
import time


class CJBNews:
    def __init__(self):
        self.full_list = {}
        self.event_names = []
        self.event_ids = []
        self.list = []
        self.info = self._EventInfo
        self.calendar_info = []
        self.offset = 0

    def _division(self, a: float, b: float):
        """Division function"""
        return 0 if b == 0 else a / b

    @dataclass
    class _CalendarInfo:
        name: str
        currency: str
        event_id: int
        category: str
        date: datetime
        actual: float
        forecast: float
        previous: float
        outcome: str
        strength: str
        quality: str
        projection: str

    @dataclass
    class _EventInfo:
        name: str
        currency: str
        event_id: int
        category: str
        history: list
        machine_learning: dict
        smart_analysis: dict
        patterns = [
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

        def _division(self, a: float, b: float):
            """Division function"""
            return 0 if b == 0 else a / b

        def trend_smart_analysis(self, outcome: str) -> str:
            """Returns the trend based on the smart analysis data"""
            for pat in self.patterns:
                for value in self.smart_analysis:
                    if str(value) == str(pat) and str(value) == str(outcome):
                        if str(self.smart_analysis[value]) == "Bullish":
                            return "Bullish"
                        elif str(self.smart_analysis[value]) == "Bearish":
                            return "Bearish"
                        else:
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

                            bullish = self._division(
                                (
                                    float(val[pat]["1 Minute"]["Bullish"])
                                    + float(val[pat]["30 Minute"]["Bullish"])
                                    + float(val[pat]["1 Hour"]["Bullish"])
                                ),
                                3,
                            )
                            bearish = self._division(
                                (
                                    float(val[pat]["1 Minute"]["Bearish"])
                                    + float(val[pat]["30 Minute"]["Bearish"])
                                    + float(val[pat]["1 Hour"]["Bearish"])
                                ),
                                3,
                            )
                            accuracy = self._division(acc, 3)

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
            if event_time != 0 and event_time == current_time:
                return True

            return False

        def outcome(self, iteration: int) -> str:
            """Returns the outcome of the event"""
            actual = self.history[iteration]["Actual"]
            forecast = self.history[iteration]["Forecast"]
            previous = self.history[iteration]["Previous"]

            if actual > forecast and forecast > previous:
                return self.patterns[0]
            if actual > forecast and forecast < previous and actual > previous:
                return self.patterns[1]
            if actual > forecast and actual < previous:
                return self.patterns[2]
            if actual > forecast and forecast == previous:
                return self.patterns[3]
            if actual > forecast and actual == previous:
                return self.patterns[4]
            if actual < forecast and forecast < previous:
                return self.patterns[5]
            if actual < forecast and forecast > previous and actual < previous:
                return self.patterns[6]
            if actual < forecast and actual > previous:
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

    def calendar(
        self, api_key: str, today=False, this_week=False, news_source: str = "mql5"
    ) -> bool:
        """Gets the calendar data"""
        if today and not this_week:
            url = f"https://www.jblanked.com/news/api/{news_source}/calendar/today/"
        elif this_week and not today:
            url = f"https://www.jblanked.com/news/api/{news_source}/calendar/week/"
        else:
            url = f"https://www.jblanked.com/news/api/{news_source}/calendar/"

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
            self._set_calendar_list(data)
            return True
        print(f"Error: {response.status_code}")
        print(response.json())
        return False

    def get(self, api_key: str, news_source: str = "mql5") -> bool:
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
            self._event_list()
            return True

        print(f"Error: {response.status_code}")
        print(response.json())
        return False

    def load(self, event_id: int) -> bool:
        """Loads the event from an event ID"""
        for currency in self.full_list:
            if self.__search(currency, event_id):
                return True

        return False

    def __search(self, currency: str, event_id: int) -> bool:
        """Searches for the event"""
        for event in self.list:
            if str(event["Event_ID"]) == str(event_id):
                try:
                    category = event["Category"]
                except KeyError:
                    category = "N/A"
                try:
                    history = event["History"]
                except KeyError:
                    history = []
                try:
                    machineLearning = event["MachineLearning"]
                except KeyError:
                    machineLearning = {}
                try:
                    smartAnalysis = event["SmartAnalysis"]
                except KeyError:
                    smartAnalysis = {}

                self.info.name = event["Name"]
                self.info.currency = currency
                self.info.event_id = event["Event_ID"]
                self.info.category = category
                self.info.history = history
                self.info.machine_learning = machineLearning
                self.info.smart_analysis = smartAnalysis
                return True

        return False

    def _event_list(self):
        """Sets the event list"""
        usd_events = [name for name in self.full_list["USD"]["Events"]]
        eur_events = [name for name in self.full_list["EUR"]["Events"]]
        gbp_events = [name for name in self.full_list["GBP"]["Events"]]
        aud_events = [name for name in self.full_list["AUD"]["Events"]]
        cad_events = [name for name in self.full_list["CAD"]["Events"]]
        chf_events = [name for name in self.full_list["CHF"]["Events"]]
        jpy_events = [name for name in self.full_list["JPY"]["Events"]]
        nzd_events = [name for name in self.full_list["NZD"]["Events"]]
        self._set_list(usd_events)
        self._set_list(eur_events)
        self._set_list(gbp_events)
        self._set_list(aud_events)
        self._set_list(cad_events)
        self._set_list(chf_events)
        self._set_list(jpy_events)
        self._set_list(nzd_events)
        self._set_basic_list(usd_events, "USD")
        self._set_basic_list(eur_events, "EUR")
        self._set_basic_list(gbp_events, "GBP")
        self._set_basic_list(aud_events, "AUD")
        self._set_basic_list(cad_events, "CAD")
        self._set_basic_list(chf_events, "CHF")
        self._set_basic_list(jpy_events, "JPY")
        self._set_basic_list(nzd_events, "NZD")

    def _set_list(self, events: list):
        """Sets the list"""
        for event in events:
            self.event_names.append(event["Name"])
            self.event_ids.append(event["Event_ID"])

    def _set_basic_list(self, events: list, currency: str):
        """Sets the basic list"""
        for event in events:
            try:
                category = event["Category"]
            except KeyError:
                category = "N/A"
            try:
                history = event["History"]

                if self.offset != 0:
                    for item in history:
                        item["Date"] = datetime.datetime.strptime(
                            item["Date"], "%Y.%m.%d %H:%M:%S"
                        ) - datetime.timedelta(hours=self.offset)

            except KeyError:
                history = []
            try:
                machine_learning = event["MachineLearning"]
            except KeyError:
                machine_learning = {}
            try:
                smart_analysis = event["SmartAnalysis"]
            except KeyError:
                smart_analysis = {}

            self.list.append(
                {
                    "Name": event["Name"],
                    "Currency": currency,
                    "Event_ID": event["Event_ID"],
                    "Category": category,
                    "History": history,
                    "MachineLearning": machine_learning,
                    "SmartAnalysis": smart_analysis,
                }
            )

    def _set_calendar_list(self, json_data: dict):
        """Sets the calendar list"""
        self.calendar_info = []
        for data in json_data:
            try:
                category = data["Category"]
            except KeyError:
                category = "N/A"
            try:
                outcome = data["Outcome"]
            except KeyError:
                outcome = "N/A"
            try:
                strength = data["Strength"]
            except KeyError:
                strength = "N/A"
            try:
                quality = data["Quality"]
            except KeyError:
                quality = "N/A"
            try:
                projection = data["Projection"]
            except KeyError:
                projection = "N/A"

            if self.offset == 0:
                date = data["Date"]
            else:
                date = datetime.datetime.strptime(
                    data["Date"], "%Y.%m.%d %H:%M:%S"
                ) - datetime.timedelta(hours=self.offset)

            self.calendar_info.append(
                self._CalendarInfo(
                    name=data["Name"],
                    currency=data["Currency"],
                    event_id=data["Event_ID"],
                    category=category,
                    date=date,
                    actual=data["Actual"],
                    forecast=data["Forecast"],
                    previous=data["Previous"],
                    outcome=outcome,
                    strength=strength,
                    quality=quality,
                    projection=projection,
                )
            )

    def GPT(self, api_key: str, message: str, delay: int = 1) -> str:
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
