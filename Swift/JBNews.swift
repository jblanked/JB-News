import Dispatch
import Foundation

/*
    JBNews is a Swift package that provides an easy-to-use interface for fetching economic news data from the JBlanked API. It provides the following features:
    - Fetching economic news data for today or the current week
    - Fetching economic news data for a specific currency
    - Fetching detailed information about a specific news event

    .get() - Fetches the full list of economic news data
    .calendar(today: Bool, thisWeek: Bool) - Fetches economic news data for today or the current week
    .loadEventData(eventID: Int) - Fetches detailed information about a specific news event (after calling .get()
*/

public class JBNews {

  var apiKey: String = ""
  var history: [HistoryData] = []
  var basicInfo: [NewsInfoBasic] = []
  var data: NewsData = NewsData()
  var newsEvents: [NewsEvent] = []

  public init(_ apiKey: String) {
    self.apiKey = apiKey
  }

  public func get() async -> NewsData {

    if !self.correctKey() {
      print("Incorrect API Key")
      return NewsData()
    }

    // set url
    if let url = URL(string: "https://www.jblanked.com/news/api/mql5/full-list/") {

      // create a request
      var request = URLRequest(url: url)
      request.addValue("Api-Key \(self.apiKey)", forHTTPHeaderField: "Authorization")
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")

      // 3. Send request

      do {
        let (dataReturned, _) = try await URLSession.shared.data(for: request)

        // 4. Parse the JSON
        let decoder = JSONDecoder()
        var newsList = try decoder.decode(NewsData2.self, from: dataReturned)

        updateCurrencies(&newsList)

        let updatedList = updateNewsData(newsData2: newsList)
        self.data = updatedList

        return updatedList

      } catch {
        print("Error has occurred: \(error)")
        return NewsData()
      }

    }

    return NewsData()

  }

  public func calendar(today: Bool = false, thisWeek: Bool = false) async -> [HistoryData] {

    if !self.correctKey() {
      print("Incorrect API Key")
      return [HistoryData()]
    }
    // set url
    var urlStr: String =
      thisWeek && !today
      ? "https://www.jblanked.com/news/api/mql5/calendar/week/"
      : "https://www.jblanked.com/news/api/mql5/calendar/today/"
    if let url = URL(string: urlStr) {
      // create a request
      var request = URLRequest(url: url)
      request.addValue("Api-Key \(self.apiKey)", forHTTPHeaderField: "Authorization")
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")

      // 3. Send request
      do {
        let (dataReturned, _) = try await URLSession.shared.data(for: request)

        // 4. Parse the JSON
        let decoder = JSONDecoder()
        let newsList = try decoder.decode([HistoryData].self, from: dataReturned)
        self.history = newsList

        return newsList

      } catch {
        print("Error has occurred: \(error)")
      }

    }

    return [HistoryData()]
  }

  public func loadEventData(eventID: Int) -> NewsEvent {
    if self.newsEvents.count == 0 {

      Task {
        await self.get()
      }

      if self.newsEvents.count == 0 {
        return NewsEvent(
          id: UUID(), Name: "", Currency: "", Event_ID: 0, SmartAnalysis: AnalysisData(),
          History: [HistoryData()], MachineLearning: MachinLearnData())
      }

    }

    for item in self.newsEvents {
      if item.Event_ID == eventID {
        return item
      }
    }

    return NewsEvent(
      id: UUID(), Name: "", Currency: "", Event_ID: 0, SmartAnalysis: AnalysisData(),
      History: [HistoryData()], MachineLearning: MachinLearnData())
  }
  
  public func gpt_post(message: String) async -> String
  {
    let baseURL: String = "https://www.jblanked.com/news/api/gpt/mobile/"
    var components = URLComponents(string: baseURL)
    components?.queryItems = [
      URLQueryItem(name: "message", value: message)
    ]
    if let url = components?.url {
      var request = URLRequest(url: url)
      request.addValue("Api-Key \(API_KEY)", forHTTPHeaderField: "Authorization")
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")

      do {
        let (dataReturned, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let response = try decoder.decode(GPTResponsePost.self, from: dataReturned)
        
        return response.task_id
      } catch {
        print("Error has occurred: \(error)")
      }
    }
    return ""
  }
  public func gpt_get(taskID: String) async -> String
  {
    if taskID == "" {
    print("Task ID is empty")
      return ""
    }

    if let url = URL(string: "https://www.jblanked.com/news/api/gpt/status/\(taskID)") {
      var request = URLRequest(url: url)
      request.addValue("Api-Key \(API_KEY)", forHTTPHeaderField: "Authorization")
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")

      do {
        let (dataReturned, responsee) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let response = try decoder.decode(GPTResponse.self, from: dataReturned)

        return response.message
      } catch {
        print("Error has occurred: \(error)")
      }

    
    }
    
    return ""

  }
  
  private struct GPTResponsePost: Decodable {
    var task_id: String
    var message: String
  } 

  private struct GPTResponse: Decodable {
    var status: String
    var message: String
  } 
  

  private func correctKey() -> Bool {
    return self.apiKey.count > 28
  }

  private func processCurrencyEvents(events: inout [NewsEvent2], currency: String) {
    for i in 0..<events.count {
      var item = events[i]  // Create a mutable copy of each item

      // Append the history data to a global mutable array `history` defined elsewhere in the class
      for hist in item.History {
        self.history.append(hist)

      }

      item.Currency = currency  // Update the currency
      events[i] = item  // Assign the modified copy back to the array

      self.basicInfo.append(
        NewsInfoBasic(Name: item.Name, Currency: currency, Event_ID: item.Event_ID))
      self.newsEvents.append(
        NewsEvent(
          id: UUID(), Name: item.Name, Currency: currency, Event_ID: item.Event_ID,
          SmartAnalysis: item.SmartAnalysis, History: item.History,
          MachineLearning: item.MachineLearning))
    }

    // order self.history by date
    self.history.sort { $0.Date < $1.Date }

    // order self.basicInfo by Name
    self.basicInfo.sort { $0.Name < $1.Name }

    // order self.newsEvents by Name
    self.newsEvents.sort { $0.Name < $1.Name }
  }

  private func updateCurrencies(_ newsData: inout NewsData2) {
    processCurrencyEvents(events: &newsData.AUD.Events, currency: "AUD")
    processCurrencyEvents(events: &newsData.USD.Events, currency: "USD")
    processCurrencyEvents(events: &newsData.EUR.Events, currency: "EUR")
    processCurrencyEvents(events: &newsData.GBP.Events, currency: "GBP")
    processCurrencyEvents(events: &newsData.JPY.Events, currency: "JPY")
    processCurrencyEvents(events: &newsData.CAD.Events, currency: "CAD")
    processCurrencyEvents(events: &newsData.CHF.Events, currency: "CHF")
    processCurrencyEvents(events: &newsData.NZD.Events, currency: "NZD")
  }

  // Conversion from NewsEvent2 to NewsEvent
  private func convertEvent(event2: NewsEvent2) -> NewsEvent {
    return NewsEvent(
      id: event2.id,
      Name: event2.Name,
      Currency: event2.Currency ?? "",  // Default to empty string if nil
      Event_ID: event2.Event_ID,
      SmartAnalysis: event2.SmartAnalysis,  // Change from SmartshypeAnalysis to SmartAnalysis
      History: event2.History,
      MachineLearning: event2.MachineLearning
    )
  }

  // Conversion from NewsEventSet2 to NewsEventSet
  private func convertEventSet(eventSet2: NewsEventSet2) -> NewsEventSet {
    return NewsEventSet(
      id: eventSet2.id,
      Events: eventSet2.Events.map { convertEvent(event2: $0) },
      Total: eventSet2.Total
    )
  }

  // Update function that processes NewsData2 and converts to NewsData
  private func updateNewsData(newsData2: NewsData2) -> NewsData {
    // Update each currency's events and convert
    return NewsData(
      USD: convertEventSet(eventSet2: newsData2.USD),
      EUR: convertEventSet(eventSet2: newsData2.EUR),
      GBP: convertEventSet(eventSet2: newsData2.GBP),
      JPY: convertEventSet(eventSet2: newsData2.JPY),
      AUD: convertEventSet(eventSet2: newsData2.AUD),
      CAD: convertEventSet(eventSet2: newsData2.CAD),
      CHF: convertEventSet(eventSet2: newsData2.CHF),
      NZD: convertEventSet(eventSet2: newsData2.NZD)
    )
  }

  private struct NewsData2: Decodable, Identifiable {
    public let id = UUID()
    var USD: NewsEventSet2
    var EUR: NewsEventSet2
    var GBP: NewsEventSet2
    var JPY: NewsEventSet2
    var AUD: NewsEventSet2
    var CAD: NewsEventSet2
    var CHF: NewsEventSet2
    var NZD: NewsEventSet2

    public init() {
      self.USD = NewsEventSet2()
      self.EUR = NewsEventSet2()
      self.GBP = NewsEventSet2()
      self.JPY = NewsEventSet2()
      self.AUD = NewsEventSet2()
      self.CAD = NewsEventSet2()
      self.CHF = NewsEventSet2()
      self.NZD = NewsEventSet2()
    }
  }

  private struct NewsEventSet2: Decodable, Identifiable {
    public let id = UUID()
    var Events: [NewsEvent2]
    var Total: Int

    public init() {
      self.Events = [NewsEvent2()]
      self.Total = 0
    }
  }

  private struct NewsEvent2: Decodable, Identifiable {
    public let id = UUID()
    var Name: String
    var Currency: String?
    var Event_ID: Int
    var SmartAnalysis: AnalysisData
    var History: [HistoryData]
    var MachineLearning: MachinLearnData

    public init() {
      self.Name = ""
      self.Currency = ""
      self.Event_ID = 0
      self.SmartAnalysis = AnalysisData()
      self.History = [HistoryData()]
      self.MachineLearning = MachinLearnData()

    }  // use default values
  }

}

public struct NewsData: Decodable, Identifiable {
  public let id = UUID()
  var USD: NewsEventSet
  var EUR: NewsEventSet
  var GBP: NewsEventSet
  var JPY: NewsEventSet
  var AUD: NewsEventSet
  var CAD: NewsEventSet
  var CHF: NewsEventSet
  var NZD: NewsEventSet

  public init() {
    self.USD = NewsEventSet()
    self.EUR = NewsEventSet()
    self.GBP = NewsEventSet()
    self.JPY = NewsEventSet()
    self.AUD = NewsEventSet()
    self.CAD = NewsEventSet()
    self.CHF = NewsEventSet()
    self.NZD = NewsEventSet()
  }

  public init(
    USD: NewsEventSet, EUR: NewsEventSet, GBP: NewsEventSet, JPY: NewsEventSet, AUD: NewsEventSet,
    CAD: NewsEventSet, CHF: NewsEventSet, NZD: NewsEventSet
  ) {
    self.USD = USD
    self.EUR = EUR
    self.GBP = GBP
    self.JPY = JPY
    self.AUD = AUD
    self.CAD = CAD
    self.CHF = CHF
    self.NZD = NZD

  }
}

public struct NewsEvent: Decodable, Identifiable {
  public let id: UUID
  var Name: String
  var Currency: String
  var Event_ID: Int
  var SmartAnalysis: AnalysisData
  var History: [HistoryData]
  var MachineLearning: MachinLearnData

  // Explicit initializer
  public init(
    id: UUID, Name: String, Currency: String, Event_ID: Int, SmartAnalysis: AnalysisData,
    History: [HistoryData], MachineLearning: MachinLearnData
  ) {
    self.id = id
    self.Name = Name
    self.Currency = Currency
    self.Event_ID = Event_ID
    self.SmartAnalysis = SmartAnalysis
    self.History = History
    self.MachineLearning = MachineLearning
  }

  public init() {
    self.id = UUID()
    self.Name = ""
    self.Currency = ""
    self.Event_ID = 0
    self.SmartAnalysis = AnalysisData()
    self.History = [HistoryData()]
    self.MachineLearning = MachinLearnData()
  }

}

public struct NewsEventSet: Decodable, Identifiable {
  public let id: UUID
  var Events: [NewsEvent]
  var Total: Int

  // Explicit initializer
  public init(id: UUID, Events: [NewsEvent], Total: Int) {
    self.id = id
    self.Events = Events
    self.Total = Total
  }

  public init() {
    self.id = UUID()
    self.Events = []
    self.Total = 0
  }
}

public struct HistoryData: Decodable, Hashable {
  var Date: String
  var Actual: Double
  var Forecast: Double
  var Previous: Double
  var Outcome: String
  var oneHour: String?
  var thirtyMinute: String?
  var oneMinute: String?

  private enum CodingKeys: String, CodingKey {
    case Date
    case Actual
    case Forecast
    case Previous
    case Outcome
    case oneHour = "1 Hour"
    case thirtyMinute = "30 Minute"
    case oneMinute = "1 Minute"
  }

  public init() {
    self.Date = ""
    self.Actual = 0.0
    self.Forecast = 0.0
    self.Previous = 0.0
    self.Outcome = ""
    self.oneHour = ""
    self.thirtyMinute = ""
    self.oneMinute = ""

  }
}

public struct AnalysisData: Decodable {
  var actual_more_than_forecast_more_than_previous: String
  var actual_more_than_forecast_less_than_previous: String
  var actual_more_than_forecast_and_actual_less_than_previous: String
  var actual_more_than_forecast_equal_to_previous: String
  var actual_more_than_forecast_and_actual_equal_to_previous: String
  var actual_less_than_forecast_and_previous: String
  var actual_less_than_forecast_more_than_previous: String
  var actual_less_than_forecast_and_actual_more_than_previous: String
  var actual_less_than_forecast_and_actual_equal_to_previous: String
  var actual_less_than_forecast_equal_to_previous: String
  var actual_equal_to_forecast_and_previous: String
  var actual_equal_to_forecast_less_than_previous: String
  var actual_equal_to_forecast_more_than_previous: String

  private enum CodingKeys: String, CodingKey {
    case actual_more_than_forecast_more_than_previous = "Actual > Forecast > Previous"
    case actual_more_than_forecast_less_than_previous = "Actual > Forecast Forecast < Previous"
    case actual_more_than_forecast_and_actual_less_than_previous =
      "Actual > Forecast Actual < Previous"
    case actual_more_than_forecast_equal_to_previous = "Actual > Forecast Forecast = Previous"
    case actual_more_than_forecast_and_actual_equal_to_previous =
      "Actual > Forecast Actual = Previous"
    case actual_less_than_forecast_and_previous = "Actual < Forecast < Previous"
    case actual_less_than_forecast_more_than_previous = "Actual < Forecast Forecast > Previous"
    case actual_less_than_forecast_and_actual_more_than_previous =
      "Actual < Forecast Actual > Previous"
    case actual_less_than_forecast_and_actual_equal_to_previous =
      "Actual < Forecast Actual = Previous"
    case actual_less_than_forecast_equal_to_previous = "Actual < Forecast = Previous"
    case actual_equal_to_forecast_and_previous = "Actual = Forecast = Previous"
    case actual_equal_to_forecast_less_than_previous = "Actual = Forecast < Previous"
    case actual_equal_to_forecast_more_than_previous = "Actual = Forecast > Previous"
  }

  public init() {
    self.actual_more_than_forecast_more_than_previous = ""
    self.actual_more_than_forecast_less_than_previous = ""
    self.actual_more_than_forecast_and_actual_less_than_previous = ""
    self.actual_more_than_forecast_equal_to_previous = ""
    self.actual_more_than_forecast_and_actual_equal_to_previous = ""
    self.actual_less_than_forecast_and_previous = ""
    self.actual_less_than_forecast_more_than_previous = ""
    self.actual_less_than_forecast_and_actual_more_than_previous = ""
    self.actual_less_than_forecast_and_actual_equal_to_previous = ""
    self.actual_less_than_forecast_equal_to_previous = ""
    self.actual_equal_to_forecast_and_previous = ""
    self.actual_equal_to_forecast_less_than_previous = ""
    self.actual_equal_to_forecast_more_than_previous = ""

  }
}

public struct MachinLearnData: Decodable {
  var Outcomes: MLData

  public init() {
    self.Outcomes = MLData()

  }
}

public struct MLData: Decodable {
  var actual_more_than_forecast_more_than_previous: MLOutcomes  // Actual > Forecast > Previous
  var actual_more_than_forecast_less_than_previous: MLOutcomes  // Actual > Forecast, Forecast < Previous
  var actual_more_than_forecast_and_actual_less_than_previous: MLOutcomes  // Actual > Forecast, Actual < Previous
  var actual_more_than_forecast_equal_to_previous: MLOutcomes  // Actual > Forecast, Forecast = Previous
  var actual_more_than_forecast_and_actual_equal_to_previous: MLOutcomes  // Actual > Forecast, Actual = Previous
  var actual_less_than_forecast_and_previous: MLOutcomes  // Actual < Forecast < Previous
  var actual_less_than_forecast_more_than_previous: MLOutcomes  // Actual < Forecast, Forecast > Previous
  var actual_less_than_forecast_and_actual_more_than_previous: MLOutcomes  // Actual < Forecast, Actual > Previous
  var actual_less_than_forecast_and_actual_equal_to_previous: MLOutcomes  // Actual < Forecast, Actual = Previous
  var actual_less_than_forecast_equal_to_previous: MLOutcomes  // Actual < Forecast, Forecast = Previous
  var actual_equal_to_forecast_and_previous: MLOutcomes  // Actual = Forecast = Previous
  var actual_equal_to_forecast_less_than_previous: MLOutcomes  // Actual = Forecast, Forecast < Previous
  var actual_equal_to_forecast_more_than_previous: MLOutcomes  // Actual = Forecast, Forecast > Previous

  private enum CodingKeys: String, CodingKey {
    case actual_more_than_forecast_more_than_previous = "Actual > Forecast > Previous"
    case actual_more_than_forecast_less_than_previous = "Actual > Forecast Forecast < Previous"
    case actual_more_than_forecast_and_actual_less_than_previous =
      "Actual > Forecast Actual < Previous"
    case actual_more_than_forecast_equal_to_previous = "Actual > Forecast Forecast = Previous"
    case actual_more_than_forecast_and_actual_equal_to_previous =
      "Actual > Forecast Actual = Previous"
    case actual_less_than_forecast_and_previous = "Actual < Forecast < Previous"
    case actual_less_than_forecast_more_than_previous = "Actual < Forecast Forecast > Previous"
    case actual_less_than_forecast_and_actual_more_than_previous =
      "Actual < Forecast Actual > Previous"
    case actual_less_than_forecast_and_actual_equal_to_previous =
      "Actual < Forecast Actual = Previous"
    case actual_less_than_forecast_equal_to_previous = "Actual < Forecast = Previous"
    case actual_equal_to_forecast_and_previous = "Actual = Forecast = Previous"
    case actual_equal_to_forecast_less_than_previous = "Actual = Forecast < Previous"
    case actual_equal_to_forecast_more_than_previous = "Actual = Forecast > Previous"
  }

  public init() {
    self.actual_more_than_forecast_more_than_previous = MLOutcomes()
    self.actual_more_than_forecast_less_than_previous = MLOutcomes()
    self.actual_more_than_forecast_and_actual_less_than_previous = MLOutcomes()
    self.actual_more_than_forecast_equal_to_previous = MLOutcomes()
    self.actual_more_than_forecast_and_actual_equal_to_previous = MLOutcomes()
    self.actual_less_than_forecast_and_previous = MLOutcomes()
    self.actual_less_than_forecast_more_than_previous = MLOutcomes()
    self.actual_less_than_forecast_and_actual_more_than_previous = MLOutcomes()
    self.actual_less_than_forecast_and_actual_equal_to_previous = MLOutcomes()
    self.actual_less_than_forecast_equal_to_previous = MLOutcomes()
    self.actual_equal_to_forecast_and_previous = MLOutcomes()
    self.actual_equal_to_forecast_less_than_previous = MLOutcomes()
    self.actual_equal_to_forecast_more_than_previous = MLOutcomes()
  }
}

public struct MLOutcomes: Decodable {
  var oneHour: MLTimeframe
  var oneMinute: MLTimeframe
  var thirtyMinute: MLTimeframe

  private enum CodingKeys: String, CodingKey {
    case oneHour = "1 Hour"
    case oneMinute = "1 Minute"
    case thirtyMinute = "30 Minute"
  }

  public init() {
    self.oneHour = MLTimeframe(Bearish: 0.0, Bullish: 0.0)
    self.oneMinute = MLTimeframe(Bearish: 0.0, Bullish: 0.0)
    self.thirtyMinute = MLTimeframe(Bearish: 0.0, Bullish: 0.0)

  }
}

public struct MLTimeframe: Decodable {
  var Bearish: Double
  var Bullish: Double
}

public struct NewsInfoBasic: Decodable, Identifiable {
  public let id = UUID()
  var Name: String
  var Currency: String
  var Event_ID: Int
}
