// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Dispatch

public class JBNews {
    public static let shared = JBNews()
    private init(apiKey: String = "") {
        self.apiKey = apiKey
    }

    func get(newsSource: String = "mql5") async -> [NewsInfo] {
        // set url
        if let url = URL(string: "https://www.jblanked.com/news/api/\(newsSource)/full-list/")
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
                let newsList = try decoder.decode([NewsInfo].self, from: dataReturned)
                
                return newsList

            } catch {
                print("Error has occurred: \(error)")
            }

        }
        
        return [NewsInfo(Name: "Test", Currency: "USD", ID: 0)]
    }

    func calendar(today: Bool = false, thisWeek: Bool = false, newsSource: String = "mql5") async -> [HistoryData] {
        // set url
        var urlStr: String = thisWeek && !today ? "https://www.jblanked.com/news/api/\(newsSource)/calendar/week/" : "https://www.jblanked.com/news/api/\(newsSource)/calendar/today/"
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
        
        return [HistoryData(Date: "", Actual: 0.0, Forecast: 0.0, Previous: 0.0, Outcome: "")]
    }
    
}

//
//  NewsData.swift
//  JBlanked.com
//
//  Created by user on 11/30/23.
//

public struct NewsInfo: Decodable,Identifiable
{
    let id = UUID()
    var Name:String
    var Currency:String
    var ID:Int
}

public struct NewsData:Decodable,Identifiable
{
    let id = UUID()
    var Name:String
    var Currency:String
    var Event_ID:Int
    var SmartAnalysis:AnalysisData
    var History:[HistoryData]
    var MachineLearning:MachinLearnData
    
    public init() {
        self.Name = ""
        self.Currency = ""
        self.Event_ID = 0
        self.SmartAnalysis = AnalysisData(actual_more_than_forecast_more_than_previous: "", actual_more_than_forecast_less_than_previous: "", actual_more_than_forecast_and_actual_less_than_previous: "", actual_more_than_forecast_equal_to_previous: "", actual_more_than_forecast_and_actual_equal_to_previous: "", actual_less_than_forecast_and_previous: "", actual_less_than_forecast_more_than_previous: "", actual_less_than_forecast_and_actual_more_than_previous: "", actual_less_than_forecast_and_actual_equal_to_previous: "", actual_less_than_forecast_equal_to_previous: "", actual_equal_to_forecast_and_previous: "", actual_equal_to_forecast_less_than_previous: "", actual_equal_to_forecast_more_than_previous: "")
        self.History = [HistoryData(Date: "", Actual: 0.0, Forecast: 0.0, Previous: 0.0, Outcome: ""),HistoryData(Date: "", Actual: 0.0, Forecast: 0.0, Previous: 0.0, Outcome: "")]
        self.MachineLearning = MachinLearnData(Outcomes: MLData(actual_more_than_forecast_more_than_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_more_than_forecast_less_than_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_more_than_forecast_and_actual_less_than_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_more_than_forecast_equal_to_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_more_than_forecast_and_actual_equal_to_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_less_than_forecast_and_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_less_than_forecast_more_than_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_less_than_forecast_and_actual_more_than_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_less_than_forecast_and_actual_equal_to_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_less_than_forecast_equal_to_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_equal_to_forecast_and_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_equal_to_forecast_less_than_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0)), actual_equal_to_forecast_more_than_previous: MLOutcomes(oneHour: MLTimeframe(Bearish: 0.0, Bullish: 0.0), oneMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0), thirtyMinute: MLTimeframe(Bearish: 0.0, Bullish: 0.0))))
        
    }  // use default values
}

public struct HistoryData: Decodable, Hashable {
    var Date: String
    var Actual: Double
    var Forecast: Double
    var Previous: Double
    var Outcome: String
    
    private enum CodingKeys: String, CodingKey {
        case Date
        case Actual
        case Forecast
        case Previous
        case Outcome
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
}

public struct MachinLearnData:Decodable
{
    var Outcomes:MLData
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
}

public struct MLTimeframe: Decodable
{
    var Bearish:Double
    var Bullish:Double
}
