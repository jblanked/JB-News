from dataclasses import dataclass
import requests
import datetime


class CJBNews:
    def __init__(self):
        self.full_list = {}
        self.event_names = []
        self.event_ids = []
        self.list = []
        self.info = self._EventInfo
        self._machine_learning = {}
        self._smart_analysis = {}

    def _division(self, a: float, b: float):
        if b == 0:
            return 0
        else:
            return a / b

    @dataclass
    class _EventInfo:
        name: str
        currency: str
        eventID: int
        history: list
        machine_learning: dict
        smart_analysis: dict

        def _division(self, a: float, b: float):
            if b == 0:
                return 0
            else:
                return a / b

        def trendSA(self, outcome) -> str:
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
            for pat in patterns:
                for value in self.smart_analysis:
                    if str(value) == str(pat) and str(value) == str(outcome):
                        if str(self.smart_analysis[value]) == "Bullish":
                            return "Bullish"
                        elif str(self.smart_analysis[value]) == "Bearish":
                            return "Bearish"
                        else:
                            return "Neutral"

        def trendML(self, outcome) -> str:
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
            for pat in patterns:
                val = self.machine_learning["Outcomes"]
                for item in val:
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
                            elif bearish > bullish:
                                return "Bearish"
                            else:
                                return "Neutral"
                        else:
                            return "Neutral"

        def isEventTime(self, eventTime, currentTime):
            if (
                datetime.datetime.strptime(eventTime, "%Y-%m-%dT%H:%M:%SZ")
                == currentTime
            ):
                return True
            else:
                return False

        def outcome(self, actual: float, forecast: float, previous: float):
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
            if actual > forecast and forecast > previous:
                return patterns[0]
            elif actual > forecast and forecast < previous and actual > previous:
                return patterns[1]
            elif actual > forecast and actual < previous:
                return patterns[2]
            elif actual > forecast and forecast == previous:
                return patterns[3]
            elif actual > forecast and actual == previous:
                return patterns[4]
            elif actual < forecast and forecast < previous:
                return patterns[5]
            elif actual < forecast and forecast > previous and actual < previous:
                return patterns[6]
            elif actual < forecast and actual > previous:
                return patterns[7]
            elif actual < forecast and forecast == previous:
                return patterns[8]
            elif actual < forecast and actual == previous:
                return patterns[9]
            elif actual == forecast and actual == previous:
                return patterns[10]
            elif actual == forecast and forecast > previous:
                return patterns[11]
            elif actual == forecast and forecast < previous:
                return patterns[12]
            else:
                return "Data Not Loaded"

    def start(self, api_key) -> bool:
        url = "https://www.jblanked.com/news/api/full-list/"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Api-Key {api_key}",
        }
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            data = response.json()
            self.full_list = data
            self._eventList()
            return True
        else:
            print(f"Error: {response.status_code}")
            return False

    def load(self, eventID) -> bool:
        for currency in self.full_list:
            if self.__search(currency, eventID):
                return True

        return False

    def __search(self, currency, eventID):
        for event in self.list:
            if str(event["Event_ID"]) == str(eventID):
                self.info.name = event["Name"]
                self.info.currency = currency
                self.info.eventID = event["Event_ID"]
                self.info.history = event["History"]
                self.info.machine_learning = event["MachineLearning"]
                self.info.smart_analysis = event["SmartAnalysis"]
                self.machine_learning = event["MachineLearning"]
                self.smart_analysis = event["SmartAnalysis"]
                return True

        return False

    def _eventList(self):
        usd_events = [name for name in self.full_list["USD"]["Events"]]
        eur_events = [name for name in self.full_list["EUR"]["Events"]]
        gbp_events = [name for name in self.full_list["GBP"]["Events"]]
        aud_events = [name for name in self.full_list["AUD"]["Events"]]
        cad_events = [name for name in self.full_list["CAD"]["Events"]]
        chf_events = [name for name in self.full_list["CHF"]["Events"]]
        jpy_events = [name for name in self.full_list["JPY"]["Events"]]
        nzd_events = [name for name in self.full_list["NZD"]["Events"]]
        self._setList(usd_events)
        self._setList(eur_events)
        self._setList(gbp_events)
        self._setList(aud_events)
        self._setList(cad_events)
        self._setList(chf_events)
        self._setList(jpy_events)
        self._setList(nzd_events)
        self._setBasicList(usd_events, "USD")
        self._setBasicList(eur_events, "EUR")
        self._setBasicList(gbp_events, "GBP")
        self._setBasicList(aud_events, "AUD")
        self._setBasicList(cad_events, "CAD")
        self._setBasicList(chf_events, "CHF")
        self._setBasicList(jpy_events, "JPY")
        self._setBasicList(nzd_events, "NZD")

    def _setList(self, events):
        for event in events:
            self.event_names.append(event["Name"])
            self.event_ids.append(event["Event_ID"])

    def _setBasicList(self, events, currency):
        for event in events:
            self.list.append(
                {
                    "Name": event["Name"],
                    "Currency": currency,
                    "Event_ID": event["Event_ID"],
                    "History": event["History"],
                    "MachineLearning": event["MachineLearning"],
                    "SmartAnalysis": event["SmartAnalysis"],
                }
            )
