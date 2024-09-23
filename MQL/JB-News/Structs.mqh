//+------------------------------------------------------------------+
//|                                                      Structs.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#property strict
#include <jb-news\\JSON.mqh>
#include <jb-news\\Enums.mqh>

struct NewsHistoryModel
  {
public:
   string            name;
   datetime          date;
   long              id;
   ENUM_CURRENCY     currency;
   ENUM_NEWS_CATEGORY category;
   double            actual;
   double            forecast;
   double            previous;
   double            projection;
   ENUM_NEWS_STRATEGY outcome;
   ENUM_NEWS_STRENGTH strength;
   ENUM_NEWS_QUALITY quality;

   bool              isEventTime(datetime currentTime = 0)
     {
      currentTime = currentTime == 0 ? TimeCurrent() : currentTime;
      return currentTime == this.date;
     }

   void              set(CJAVal & json)
     {
      this.actual    = json["Actual"].ToDbl();
      this.forecast  = json["Forecast"].ToDbl();
      this.previous  = json["Previous"].ToDbl();
      this.category  = StringToCategory(json["Category"].ToStr());
      this.date      = StringToTime(json["Date"].ToStr());
      this.id        = json["Event_ID"].ToInt();
      this.name      = json["Name"].ToStr();
      this.outcome   = StringToStrategy(json["Outcome"].ToStr());
      this.quality   = StringToQuality(json["Quality"].ToStr());
      this.strength  = StringToStrength(json["Strength"].ToStr());
      this.currency  = StringToCurrency(json["Currency"].ToStr());
      this.projection= json["Projection"].ToDbl();
     }


  };

struct MachineLearningTrendModel
  {
   ENUM_TIMEFRAMES   timeframe;
   double            bullish;
   double            bearish;
  };

struct MachineLearningOutcomeModel
  {
   MachineLearningTrendModel actual_more_than_forecast_more_than_previous[3];             // Actual > Forecast > Previous
   MachineLearningTrendModel actual_more_than_forecast_less_than_previous[3];             // Actual > Forecast Forecast < Previous
   MachineLearningTrendModel actual_more_than_forecast_and_actual_less_than_previous[3];  // Actual > Forecast Actual < Previous
   MachineLearningTrendModel actual_more_than_forecast_equal_to_previous[3];              // Actual > Forecast Forecast = Previous
   MachineLearningTrendModel actual_more_than_forecast_and_actual_equal_to_previous[3];   // "Actual > Forecast Actual = Previous
   MachineLearningTrendModel actual_less_than_forecast_and_previous[3];                   // "Actual < Forecast < Previous
   MachineLearningTrendModel actual_less_than_forecast_more_than_previous[3];             // Actual < Forecast Forecast > Previous
   MachineLearningTrendModel actual_less_than_forecast_and_actual_more_than_previous[3];  // Actual < Forecast Actual > Previous
   MachineLearningTrendModel actual_less_than_forecast_and_actual_equal_to_previous[3];   // Actual < Forecast Actual = Previous
   MachineLearningTrendModel actual_less_than_forecast_equal_to_previous[3];              // Actual < Forecast = Previous
   MachineLearningTrendModel actual_equal_to_forecast_and_previous[3];                    // Actual = Forecast = Previous
   MachineLearningTrendModel actual_equal_to_forecast_less_than_previous[3];              // Actual = Forecast < Previous
   MachineLearningTrendModel actual_equal_to_forecast_more_than_previous[3];              // Actual = Forecast > Previous
  };

struct MachineLearningModel
  {
   MachineLearningOutcomeModel   outcomes;
   double                        oneMinuteAccuracy;      // 1 Minute
   double                        thirtyMinuteAccuracy;   // 30 Minute
   double                        oneHourAccuracy;        // 1 Hour
  };

struct SmartAnalysisModel
  {
   ENUM_BULLISH_OR_BEARISH actual_more_than_forecast_more_than_previous;            // Actual > Forecast > Previous
   ENUM_BULLISH_OR_BEARISH actual_more_than_forecast_less_than_previous;            // Actual > Forecast Forecast < Previous
   ENUM_BULLISH_OR_BEARISH actual_more_than_forecast_and_actual_less_than_previous; // Actual > Forecast Actual < Previous
   ENUM_BULLISH_OR_BEARISH actual_more_than_forecast_equal_to_previous;             // Actual > Forecast Forecast = Previous
   ENUM_BULLISH_OR_BEARISH actual_more_than_forecast_and_actual_equal_to_previous;  // Actual > Forecast Actual = Previous
   ENUM_BULLISH_OR_BEARISH actual_less_than_forecast_and_previous;                  // Actual < Forecast < Previous
   ENUM_BULLISH_OR_BEARISH actual_less_than_forecast_more_than_previous;            // Actual < Forecast Forecast > Previous
   ENUM_BULLISH_OR_BEARISH actual_less_than_forecast_and_actual_more_than_previous; // Actual < Forecast Actual > Previous
   ENUM_BULLISH_OR_BEARISH actual_less_than_forecast_and_actual_equal_to_previous;  // Actual < Forecast Actual = Previous
   ENUM_BULLISH_OR_BEARISH actual_less_than_forecast_equal_to_previous;             // Actual < Forecast = Previous
   ENUM_BULLISH_OR_BEARISH actual_equal_to_forecast_and_previous;                   // Actual = Forecast = Previous
   ENUM_BULLISH_OR_BEARISH actual_equal_to_forecast_less_than_previous;             // Actual = Forecast < Previous
   ENUM_BULLISH_OR_BEARISH actual_equal_to_forecast_more_than_previous;             // Actual = Forecast > Previous
  };
//+------------------------------------------------------------------+
