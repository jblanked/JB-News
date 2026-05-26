//+------------------------------------------------------------------+
//|                                                      Structs.mqh |
//|                                     Copyright 2024-2026,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2026,JBlanked"
#property link      "https://www.jblanked.com/news/api/docs/"
#property strict
#include "JSON.mqh"
#include "Enums.mqh"

struct NewsHistoryModel
{
public:
   string            name;
   datetime          date;
   long              id;
   ENUM_CURRENCY     currency;
   ENUM_NEWS_CATEGORY category;
   ENUM_NEWS_IMPACT  impact;
   double            actual;
   double            forecast;
   double            previous;
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
      this.impact    = StringToImpact(json["Impact"].ToStr());
      this.date      = StringToTime(json["Date"].ToStr());
      this.id        = json["Event_ID"].ToInt();
      this.name      = json["Name"].ToStr();
      this.outcome   = StringToStrategy(json["Outcome"].ToStr());
      this.quality   = StringToQuality(json["Quality"].ToStr());
      this.strength  = StringToStrength(json["Strength"].ToStr());
      this.currency  = StringToCurrency(json["Currency"].ToStr());
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
struct EventInfo
{
public:
   ENUM_BULLISH_OR_BEARISH trendML(const string outcome);
   ENUM_BULLISH_OR_BEARISH trendSA(const string outcome);
   ENUM_BULLISH_OR_BEARISH trend(MachineLearningOutcomeModel & model, ENUM_NEWS_STRATEGY strategy);
   ENUM_BULLISH_OR_BEARISH trend(SmartAnalysisModel & model, ENUM_NEWS_STRATEGY strategy);
   string               outcome(const int iteration);
   string               name;
   ENUM_CURRENCY        currency;
   long                 id;
   ENUM_NEWS_CATEGORY   category;
   ENUM_NEWS_IMPACT     impact;
   NewsHistoryModel     history[];
   int                  eventCount;
   MachineLearningModel machineLearning;
   SmartAnalysisModel   smartAnalysis;

   ENUM_BULLISH_OR_BEARISH runEvent(const datetime currentTime, const ENUM_NEWS_TREND_TYPE trendType = ENUM_SMART_ANALYSIS)
   {
      /*
      1. Checks if the current time matches the event's dates in history
      2. Checks the ML trend and SA trend of the event
      3. Return bullish/bearish based upon the trend
      */

      for(int q = 0; q < ArraySize(this.history); q++)
      {
         if(this.history[q].isEventTime(currentTime))
         {
            const ENUM_BULLISH_OR_BEARISH mL = this.trend(this.machineLearning.outcomes, this.history[q].outcome);
            const ENUM_BULLISH_OR_BEARISH sa = this.trend(this.smartAnalysis, this.history[q].outcome);

            switch(trendType)
            {
            case ENUM_MACHINE_LEARNING:
               return mL;

            case ENUM_SMART_ANALYSIS:
               return sa;

            default:

               if(sa == ENUM_BULLISH && (mL == ENUM_BULLISH || mL == ENUM_NEUTRAL))
               {
                  return ENUM_BULLISH;
               }

               if(sa == ENUM_BEARISH && (mL == ENUM_BEARISH || mL == ENUM_NEUTRAL))
               {
                  return ENUM_BEARISH;
               }

               return ENUM_NEUTRAL;

            };

         }
      }

      return ENUM_NEUTRAL;
   }
private:
   double               division(const double numerator, const double denominator)
   {
      return denominator == 0 ? 0 : numerator / denominator;
   }

}; // end of EventInfo struct
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH EventInfo::trend(SmartAnalysisModel & model, ENUM_NEWS_STRATEGY strategy)
{
   switch(strategy)
   {
   case actual_equal_to_forecast_and_previous:
      return model.actual_equal_to_forecast_and_previous;

   case actual_equal_to_forecast_less_than_previous:
      return model.actual_equal_to_forecast_less_than_previous;

   case actual_equal_to_forecast_more_than_previous:
      return model.actual_equal_to_forecast_more_than_previous;

   case actual_less_than_forecast_and_actual_equal_to_previous:
      return model.actual_less_than_forecast_and_actual_equal_to_previous;

   case actual_less_than_forecast_and_actual_more_than_previous:
      return model.actual_less_than_forecast_and_actual_more_than_previous;

   case actual_less_than_forecast_and_previous:
      return model.actual_less_than_forecast_and_previous;

   case actual_less_than_forecast_equal_to_previous:
      return model.actual_less_than_forecast_equal_to_previous;

   case actual_less_than_forecast_more_than_previous:
      return model.actual_less_than_forecast_more_than_previous;

   case actual_more_than_forecast_and_actual_equal_to_previous:
      return model.actual_more_than_forecast_and_actual_equal_to_previous;

   case actual_more_than_forecast_and_actual_less_than_previous:
      return model.actual_more_than_forecast_and_actual_less_than_previous;

   case actual_more_than_forecast_equal_to_previous:
      return model.actual_more_than_forecast_equal_to_previous;

   case actual_more_than_forecast_less_than_previous:
      return model.actual_more_than_forecast_less_than_previous;

   case actual_more_than_forecast_more_than_previous:
      return model.actual_more_than_forecast_more_than_previous;

   default:
      return ENUM_NEUTRAL;
   };
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH EventInfo::trend(MachineLearningOutcomeModel & model, ENUM_NEWS_STRATEGY strategy)
{
   double bearVal = 0;
   double bullVal = 0;

   switch(strategy)
   {
   case actual_equal_to_forecast_and_previous:
      bearVal += model.actual_equal_to_forecast_and_previous[0].bearish;
      bearVal += model.actual_equal_to_forecast_and_previous[1].bearish;
      bearVal += model.actual_equal_to_forecast_and_previous[2].bearish;
      bullVal += model.actual_equal_to_forecast_and_previous[0].bullish;
      bullVal += model.actual_equal_to_forecast_and_previous[1].bullish;
      bullVal += model.actual_equal_to_forecast_and_previous[2].bullish;
      break;

   case actual_equal_to_forecast_less_than_previous:
      bearVal += model.actual_equal_to_forecast_less_than_previous[0].bearish;
      bearVal += model.actual_equal_to_forecast_less_than_previous[1].bearish;
      bearVal += model.actual_equal_to_forecast_less_than_previous[2].bearish;
      bullVal += model.actual_equal_to_forecast_less_than_previous[0].bullish;
      bullVal += model.actual_equal_to_forecast_less_than_previous[1].bullish;
      bullVal += model.actual_equal_to_forecast_less_than_previous[2].bullish;
      break;

   case actual_equal_to_forecast_more_than_previous:
      bearVal += model.actual_equal_to_forecast_more_than_previous[0].bearish;
      bearVal += model.actual_equal_to_forecast_more_than_previous[1].bearish;
      bearVal += model.actual_equal_to_forecast_more_than_previous[2].bearish;
      bullVal += model.actual_equal_to_forecast_more_than_previous[0].bullish;
      bullVal += model.actual_equal_to_forecast_more_than_previous[1].bullish;
      bullVal += model.actual_equal_to_forecast_more_than_previous[2].bullish;
      break;

   case actual_less_than_forecast_and_actual_equal_to_previous:
      bearVal += model.actual_less_than_forecast_and_actual_equal_to_previous[0].bearish;
      bearVal += model.actual_less_than_forecast_and_actual_equal_to_previous[1].bearish;
      bearVal += model.actual_less_than_forecast_and_actual_equal_to_previous[2].bearish;
      bullVal += model.actual_less_than_forecast_and_actual_equal_to_previous[0].bullish;
      bullVal += model.actual_less_than_forecast_and_actual_equal_to_previous[1].bullish;
      bullVal += model.actual_less_than_forecast_and_actual_equal_to_previous[2].bullish;
      break;

   case actual_less_than_forecast_and_actual_more_than_previous:
      bearVal += model.actual_less_than_forecast_and_actual_more_than_previous[0].bearish;
      bearVal += model.actual_less_than_forecast_and_actual_more_than_previous[1].bearish;
      bearVal += model.actual_less_than_forecast_and_actual_more_than_previous[2].bearish;
      bullVal += model.actual_less_than_forecast_and_actual_more_than_previous[0].bullish;
      bullVal += model.actual_less_than_forecast_and_actual_more_than_previous[1].bullish;
      bullVal += model.actual_less_than_forecast_and_actual_more_than_previous[2].bullish;
      break;

   case actual_less_than_forecast_and_previous:
      bearVal += model.actual_less_than_forecast_and_previous[0].bearish;
      bearVal += model.actual_less_than_forecast_and_previous[1].bearish;
      bearVal += model.actual_less_than_forecast_and_previous[2].bearish;
      bullVal += model.actual_less_than_forecast_and_previous[0].bullish;
      bullVal += model.actual_less_than_forecast_and_previous[1].bullish;
      bullVal += model.actual_less_than_forecast_and_previous[2].bullish;
      break;

   case actual_less_than_forecast_equal_to_previous:
      bearVal += model.actual_less_than_forecast_equal_to_previous[0].bearish;
      bearVal += model.actual_less_than_forecast_equal_to_previous[1].bearish;
      bearVal += model.actual_less_than_forecast_equal_to_previous[2].bearish;
      bullVal += model.actual_less_than_forecast_equal_to_previous[0].bullish;
      bullVal += model.actual_less_than_forecast_equal_to_previous[1].bullish;
      bullVal += model.actual_less_than_forecast_equal_to_previous[2].bullish;
      break;

   case actual_less_than_forecast_more_than_previous:
      bearVal += model.actual_less_than_forecast_more_than_previous[0].bearish;
      bearVal += model.actual_less_than_forecast_more_than_previous[1].bearish;
      bearVal += model.actual_less_than_forecast_more_than_previous[2].bearish;
      bullVal += model.actual_less_than_forecast_more_than_previous[0].bullish;
      bullVal += model.actual_less_than_forecast_more_than_previous[1].bullish;
      bullVal += model.actual_less_than_forecast_more_than_previous[2].bullish;
      break;

   case actual_more_than_forecast_and_actual_equal_to_previous:
      bearVal += model.actual_more_than_forecast_and_actual_equal_to_previous[0].bearish;
      bearVal += model.actual_more_than_forecast_and_actual_equal_to_previous[1].bearish;
      bearVal += model.actual_more_than_forecast_and_actual_equal_to_previous[2].bearish;
      bullVal += model.actual_more_than_forecast_and_actual_equal_to_previous[0].bullish;
      bullVal += model.actual_more_than_forecast_and_actual_equal_to_previous[1].bullish;
      bullVal += model.actual_more_than_forecast_and_actual_equal_to_previous[2].bullish;
      break;

   case actual_more_than_forecast_and_actual_less_than_previous:
      bearVal += model.actual_more_than_forecast_and_actual_less_than_previous[0].bearish;
      bearVal += model.actual_more_than_forecast_and_actual_less_than_previous[1].bearish;
      bearVal += model.actual_more_than_forecast_and_actual_less_than_previous[2].bearish;
      bullVal += model.actual_more_than_forecast_and_actual_less_than_previous[0].bullish;
      bullVal += model.actual_more_than_forecast_and_actual_less_than_previous[1].bullish;
      bullVal += model.actual_more_than_forecast_and_actual_less_than_previous[2].bullish;
      break;

   case actual_more_than_forecast_equal_to_previous:
      bearVal += model.actual_more_than_forecast_equal_to_previous[0].bearish;
      bearVal += model.actual_more_than_forecast_equal_to_previous[1].bearish;
      bearVal += model.actual_more_than_forecast_equal_to_previous[2].bearish;
      bullVal += model.actual_more_than_forecast_equal_to_previous[0].bullish;
      bullVal += model.actual_more_than_forecast_equal_to_previous[1].bullish;
      bullVal += model.actual_more_than_forecast_equal_to_previous[2].bullish;
      break;

   case actual_more_than_forecast_less_than_previous:
      bearVal += model.actual_more_than_forecast_less_than_previous[0].bearish;
      bearVal += model.actual_more_than_forecast_less_than_previous[1].bearish;
      bearVal += model.actual_more_than_forecast_less_than_previous[2].bearish;
      bullVal += model.actual_more_than_forecast_less_than_previous[0].bullish;
      bullVal += model.actual_more_than_forecast_less_than_previous[1].bullish;
      bullVal += model.actual_more_than_forecast_less_than_previous[2].bullish;
      break;

   case actual_more_than_forecast_more_than_previous:
      bearVal += model.actual_more_than_forecast_more_than_previous[0].bearish;
      bearVal += model.actual_more_than_forecast_more_than_previous[1].bearish;
      bearVal += model.actual_more_than_forecast_more_than_previous[2].bearish;
      bullVal += model.actual_more_than_forecast_more_than_previous[0].bullish;
      bullVal += model.actual_more_than_forecast_more_than_previous[1].bullish;
      bullVal += model.actual_more_than_forecast_more_than_previous[2].bullish;
      break;
   };

   bullVal = bullVal == 0 ? 0 : bullVal / 3;
   bearVal = bearVal == 0 ? 0 : bearVal / 3;

   return bullVal > bearVal ? ENUM_BULLISH : bullVal < bearVal ? ENUM_BEARISH : ENUM_NEUTRAL;
}
//+------------------------------------------------------------------+
//|       Get the Machine Learning Trend based upon the outcome      |
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH EventInfo::trendML(const string outcome)
{
   switch(StringToStrategy(outcome))
   {
   case actual_equal_to_forecast_and_previous:
      return this.trend(this.machineLearning.outcomes, actual_equal_to_forecast_and_previous);

   case actual_equal_to_forecast_less_than_previous:
      return this.trend(this.machineLearning.outcomes, actual_equal_to_forecast_less_than_previous);

   case actual_equal_to_forecast_more_than_previous:
      return this.trend(this.machineLearning.outcomes, actual_equal_to_forecast_more_than_previous);

   case actual_less_than_forecast_and_actual_equal_to_previous:
      return this.trend(this.machineLearning.outcomes, actual_less_than_forecast_and_actual_equal_to_previous);

   case actual_less_than_forecast_and_actual_more_than_previous:
      return this.trend(this.machineLearning.outcomes, actual_less_than_forecast_and_actual_more_than_previous);

   case actual_less_than_forecast_and_previous:
      return this.trend(this.machineLearning.outcomes, actual_less_than_forecast_and_previous);

   case actual_less_than_forecast_equal_to_previous:
      return this.trend(this.machineLearning.outcomes, actual_less_than_forecast_equal_to_previous);

   case actual_less_than_forecast_more_than_previous:
      return this.trend(this.machineLearning.outcomes, actual_less_than_forecast_more_than_previous);

   case actual_more_than_forecast_and_actual_equal_to_previous:
      return this.trend(this.machineLearning.outcomes, actual_more_than_forecast_and_actual_equal_to_previous);

   case actual_more_than_forecast_and_actual_less_than_previous:
      return this.trend(this.machineLearning.outcomes, actual_more_than_forecast_and_actual_less_than_previous);

   case actual_more_than_forecast_equal_to_previous:
      return this.trend(this.machineLearning.outcomes, actual_more_than_forecast_equal_to_previous);

   case actual_more_than_forecast_less_than_previous:
      return this.trend(this.machineLearning.outcomes, actual_more_than_forecast_less_than_previous);

   case actual_more_than_forecast_more_than_previous:
      return this.trend(this.machineLearning.outcomes, actual_more_than_forecast_more_than_previous);
   };

   return ENUM_NEUTRAL;
}
//+------------------------------------------------------------------+
//|       Get the Smart Analysis Trend based upon the outcome        |
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH EventInfo::trendSA(const string outcome)
{
   switch(StringToStrategy(outcome))
   {
   case actual_equal_to_forecast_and_previous:
      return this.smartAnalysis.actual_equal_to_forecast_and_previous;

   case actual_equal_to_forecast_less_than_previous:
      return this.smartAnalysis.actual_equal_to_forecast_less_than_previous;

   case actual_equal_to_forecast_more_than_previous:
      return this.smartAnalysis.actual_equal_to_forecast_more_than_previous;

   case actual_less_than_forecast_and_actual_equal_to_previous:
      return this.smartAnalysis.actual_less_than_forecast_and_actual_equal_to_previous;

   case actual_less_than_forecast_and_actual_more_than_previous:
      return this.smartAnalysis.actual_less_than_forecast_and_actual_more_than_previous;

   case actual_less_than_forecast_and_previous:
      return this.smartAnalysis.actual_less_than_forecast_and_previous;

   case actual_less_than_forecast_equal_to_previous:
      return this.smartAnalysis.actual_less_than_forecast_equal_to_previous;

   case actual_less_than_forecast_more_than_previous:
      return this.smartAnalysis.actual_less_than_forecast_more_than_previous;

   case actual_more_than_forecast_and_actual_equal_to_previous:
      return this.smartAnalysis.actual_more_than_forecast_and_actual_equal_to_previous;

   case actual_more_than_forecast_and_actual_less_than_previous:
      return this.smartAnalysis.actual_more_than_forecast_and_actual_less_than_previous;

   case actual_more_than_forecast_equal_to_previous:
      return this.smartAnalysis.actual_more_than_forecast_equal_to_previous;

   case actual_more_than_forecast_less_than_previous:
      return this.smartAnalysis.actual_more_than_forecast_less_than_previous;

   case actual_more_than_forecast_more_than_previous:
      return this.smartAnalysis.actual_more_than_forecast_more_than_previous;

   default:
      return ENUM_NEUTRAL;
   };
}
//+------------------------------------------------------------------+
//|                     Get the outcome                              |
//+------------------------------------------------------------------+
string EventInfo::outcome(const int iteration)
{
   const string patterns[13] =
   {
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
      "Actual < Forecast Actual = Previous"
   };

   const double actual = (double)this.history[iteration].actual;
   const double forecast = (double)this.history[iteration].forecast;
   const double previous = (double)this.history[iteration].previous;

   if(actual > forecast && forecast > previous)
   {
      return patterns[0];
   }
   if(actual > forecast && forecast < previous && actual > previous)
   {
      return patterns[1];
   }
   if(actual > forecast && actual < previous)
   {
      return patterns[2];
   }
   if(actual > forecast && forecast == previous)
   {
      return patterns[3];
   }
   if(actual > forecast && actual == previous)
   {
      return patterns[4];
   }
   if(actual < forecast && forecast < previous)
   {
      return patterns[5];
   }
   if(actual < forecast && forecast > previous && actual < previous)
   {
      return patterns[6];
   }
   if(actual < forecast && actual > previous)
   {
      return patterns[7];
   }
   if(actual < forecast && forecast == previous)
   {
      return patterns[8];
   }
   if(actual < forecast && actual == previous)
   {
      return patterns[9];
   }
   if(actual == forecast && actual == previous)
   {
      return patterns[10];
   }
   if(actual == forecast && forecast > previous)
   {
      return patterns[11];
   }
   if(actual == forecast && forecast < previous)
   {
      return patterns[12];
   }

   return "Data Not Loaded";
}
//+------------------------------------------------------------------+
