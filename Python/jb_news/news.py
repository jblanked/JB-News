from dataclasses import dataclass
import requests


class CJBNews:
    def __init__(self):
        self.full_list = {}
        self.event_names = []
        self.event_ids = []
        self.basic_list = []
        self.info = self._EventInfo

    @dataclass
    class _EventInfo:
        name: str
        currency: str
        eventID: int
        history: list
        machine_learning: dict
        smart_analysis: dict

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
        for event in self.full_list[currency]["Events"]:
            if event["Event_ID"] == eventID:
                self.info.name = event["Name"]
                self.info.currency = currency
                self.info.eventID = event["Event_ID"]
                self.info.history = event["History"]
                self.info.machine_learning = event["MachineLearning"]
                self.info.smart_analysis = event["SmartAnalysis"]
                return True

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
            self.basic_list.append(
                {
                    "Name": event["Name"],
                    "Currency": currency,
                    "Event_ID": event["Event_ID"],
                    "History": event["History"],
                    "MachineLearning": event["MachineLearning"],
                    "SmartAnalysis": event["SmartAnalysis"],
                }
            )
