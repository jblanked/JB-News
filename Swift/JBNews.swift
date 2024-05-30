// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Dispatch

public class JBNews {

    var apiKey: String = ""
    
    public init(_ apiKey: String) {
        self.apiKey = apiKey
    }

    func get() async -> NewsData {
        // set url
        if let url = URL(string: "https://www.jblanked.com/news/api/mql5/full-list/")
        {
            
            // create a request
            var request = URLRequest(url: url)
            request.addValue("Api-Key \(self.apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // 3. Send request
          
            do {
                let (dataReturned, _) = try await URLSession.shared.data(for: request)
                
            
                // 4. Parse the JSON
                let decoder = JSONDecoder()
                let newsList = try decoder.decode(NewsData.self, from: dataReturned)

                
                return newsList

            } catch {
                print("Error has occurred: \(error)")
                return NewsData()
            }

        }
        
        return NewsData()

    }

    func calendar(today: Bool = false, thisWeek: Bool = false) async -> [HistoryData] {
        // set url
        var urlStr: String = thisWeek && !today ? "https://www.jblanked.com/news/api/mql5/calendar/week/" : "https://www.jblanked.com/news/api/mql5/calendar/today/"
        if let url = URL(string: urlStr)
        {
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
                
                return newsList

            } catch {
                print("Error has occurred: \(error)")
            }
 
        }
        
        return [HistoryData()]
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
}



public struct NewsEventSet: Decodable, Identifiable
{
	public let id = UUID()
	var Events:[NewsEvent]
	var Total: Int
	
	public init() {
	    self.Events = [NewsEvent()]
        self.Total = 0
	}
}


public struct NewsEvent:Decodable,Identifiable
{
    public let id = UUID()
    var Name:String
    var Currency:String?
    var Event_ID:Int
    var SmartAnalysis:AnalysisData
    var History:[HistoryData]
    var MachineLearning:MachinLearnData
    
    public init() {
        self.Name = ""
        self.Currency = ""
        self.Event_ID = 0
        self.SmartAnalysis = AnalysisData()
        self.History = [HistoryData()]
        self.MachineLearning = MachinLearnData()
        
    }  // use default values
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

    public init(){
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
        case actual_more_than_forecast_and_actual_less_than_previous = "Actual > Forecast Actual < Previous"
        case actual_more_than_forecast_equal_to_previous = "Actual > Forecast Forecast = Previous"
        case actual_more_than_forecast_and_actual_equal_to_previous = "Actual > Forecast Actual = Previous"
        case actual_less_than_forecast_and_previous = "Actual < Forecast < Previous"
        case actual_less_than_forecast_more_than_previous = "Actual < Forecast Forecast > Previous"
        case actual_less_than_forecast_and_actual_more_than_previous = "Actual < Forecast Actual > Previous"
        case actual_less_than_forecast_and_actual_equal_to_previous = "Actual < Forecast Actual = Previous"
        case actual_less_than_forecast_equal_to_previous = "Actual < Forecast = Previous"
        case actual_equal_to_forecast_and_previous = "Actual = Forecast = Previous"
        case actual_equal_to_forecast_less_than_previous = "Actual = Forecast < Previous"
        case actual_equal_to_forecast_more_than_previous = "Actual = Forecast > Previous"
    }

    public init()
    {
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

public struct MachinLearnData:Decodable
{
    var Outcomes:MLData

    public init(){
        self.Outcomes = MLData()
    
    }
}

public struct MLData: Decodable
{
    var actual_more_than_forecast_more_than_previous:MLOutcomes  // Actual > Forecast > Previous
    var actual_more_than_forecast_less_than_previous:MLOutcomes  // Actual > Forecast, Forecast < Previous
    var actual_more_than_forecast_and_actual_less_than_previous:MLOutcomes  // Actual > Forecast, Actual < Previous
    var actual_more_than_forecast_equal_to_previous:MLOutcomes  // Actual > Forecast, Forecast = Previous
    var actual_more_than_forecast_and_actual_equal_to_previous:MLOutcomes // Actual > Forecast, Actual = Previous
    var actual_less_than_forecast_and_previous:MLOutcomes  // Actual < Forecast < Previous
    var actual_less_than_forecast_more_than_previous:MLOutcomes  // Actual < Forecast, Forecast > Previous
    var actual_less_than_forecast_and_actual_more_than_previous:MLOutcomes  // Actual < Forecast, Actual > Previous
    var actual_less_than_forecast_and_actual_equal_to_previous:MLOutcomes // Actual < Forecast, Actual = Previous
    var actual_less_than_forecast_equal_to_previous:MLOutcomes // Actual < Forecast, Forecast = Previous
    var actual_equal_to_forecast_and_previous:MLOutcomes  // Actual = Forecast = Previous
    var actual_equal_to_forecast_less_than_previous:MLOutcomes  // Actual = Forecast, Forecast < Previous
    var actual_equal_to_forecast_more_than_previous:MLOutcomes // Actual = Forecast, Forecast > Previous
    
    private enum CodingKeys: String, CodingKey {
        case actual_more_than_forecast_more_than_previous = "Actual > Forecast > Previous"
        case actual_more_than_forecast_less_than_previous = "Actual > Forecast Forecast < Previous"
        case actual_more_than_forecast_and_actual_less_than_previous = "Actual > Forecast Actual < Previous"
        case actual_more_than_forecast_equal_to_previous = "Actual > Forecast Forecast = Previous"
        case actual_more_than_forecast_and_actual_equal_to_previous = "Actual > Forecast Actual = Previous"
        case actual_less_than_forecast_and_previous = "Actual < Forecast < Previous"
        case actual_less_than_forecast_more_than_previous = "Actual < Forecast Forecast > Previous"
        case actual_less_than_forecast_and_actual_more_than_previous = "Actual < Forecast Actual > Previous"
        case actual_less_than_forecast_and_actual_equal_to_previous = "Actual < Forecast Actual = Previous"
        case actual_less_than_forecast_equal_to_previous = "Actual < Forecast = Previous"
        case actual_equal_to_forecast_and_previous = "Actual = Forecast = Previous"
        case actual_equal_to_forecast_less_than_previous = "Actual = Forecast < Previous"
        case actual_equal_to_forecast_more_than_previous = "Actual = Forecast > Previous"
    }

    public init()
    {
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

    public init(){
        self.oneHour = MLTimeframe(Bearish: 0.0, Bullish: 0.0)
        self.oneMinute = MLTimeframe(Bearish: 0.0, Bullish: 0.0)
        self.thirtyMinute = MLTimeframe(Bearish: 0.0, Bullish: 0.0)
    
    }
}

public struct MLTimeframe: Decodable
{
    var Bearish:Double
    var Bullish:Double
}
