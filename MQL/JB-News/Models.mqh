//+------------------------------------------------------------------+
//|                                                       Models.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"
#property strict
#include <jb-news\\Structs.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CJBNewsModel
  {
public:
   string               m_name;
   ENUM_CURRENCY        m_currency;
   long                 m_id;
   ENUM_NEWS_CATEGORY   m_category;
   MachineLearningModel m_machineLearning;
   NewsHistoryModel     m_history[];
   SmartAnalysisModel   m_smartAnalysis;

   //+----
                     CJBNewsModel::CJBNewsModel()
     {
      // default constructor - do NOT use
     };

                     CJBNewsModel::CJBNewsModel(
      const string               name,
      const ENUM_CURRENCY        currency,
      const long                 id,
      const ENUM_NEWS_CATEGORY   category,
      const MachineLearningModel&machineLearning,
      const NewsHistoryModel    &history[],
      const SmartAnalysisModel  &smartAnalysis
   )
     {
      this.m_name              = name;
      this.m_currency          = currency;
      this.m_id                = id;
      this.m_category          = category;
      this.setHistory(history);
      this.m_machineLearning   = machineLearning;
      this.m_smartAnalysis     = smartAnalysis;
     }

                     CJBNewsModel::CJBNewsModel(
      const string               name,
      const ENUM_CURRENCY        currency,
      const long                 id,
      const ENUM_NEWS_CATEGORY   category,
      const MachineLearningModel&machineLearning,
      const SmartAnalysisModel  &smartAnalysis
   )
     {
      this.m_name              = name;
      this.m_currency          = currency;
      this.m_id                = id;
      this.m_category          = category;
      this.m_machineLearning   = machineLearning;
      this.m_smartAnalysis     = smartAnalysis;
     }

   // sets properties from JSON
                     CJBNewsModel::CJBNewsModel(CJAVal & json)
     {
      this.m_name             = json["Name"].ToStr();
      this.m_currency         = StringToCurrency(json["Currency"].ToStr());
      this.m_id               = json["Event_ID"].ToInt();
      this.m_category         = StringToCategory(json["Category"].ToStr());

      CJAVal temp;

      // set history
      for(int h = 0; h < 250; h++)
        {
         temp = json["History"][h];

         if(temp["Date"].ToStr() != "")
           {
            this.increaseHistory();
            this.m_history[h].actual      = temp["Actual"].ToDbl();
            this.m_history[h].category    = StringToCategory(temp["Category"].ToStr());
            this.m_history[h].currency    = this.m_currency;
            this.m_history[h].date        = StringToTime(temp["Date"].ToStr());
            this.m_history[h].id          = this.m_id;
            this.m_history[h].forecast    = temp["Forecast"].ToDbl();
            this.m_history[h].name        = this.m_name;
            this.m_history[h].outcome     = StringToStrategy(temp["Outcome"].ToStr());
            this.m_history[h].previous    = temp["Previous"].ToDbl();
            this.m_history[h].projection  = temp["Projection"].ToDbl();
            this.m_history[h].quality     = StringToQuality(temp["Quality"].ToStr());
            this.m_history[h].strength    = StringToStrength(temp["Strength"].ToStr());
           }
         else
           {
            break;
           }

        }

      // set smart analysis
      temp = json["SmartAnalysis"];

      this.m_smartAnalysis.actual_more_than_forecast_more_than_previous = StringToTrend(temp["Actual > Forecast > Previous"].ToStr());
      this.m_smartAnalysis.actual_more_than_forecast_less_than_previous = StringToTrend(temp["Actual > Forecast Forecast < Previous"].ToStr());
      this.m_smartAnalysis.actual_more_than_forecast_and_actual_less_than_previous = StringToTrend(temp["Actual > Forecast Actual < Previous"].ToStr());
      this.m_smartAnalysis.actual_more_than_forecast_equal_to_previous = StringToTrend(temp["Actual > Forecast = Previous"].ToStr());
      this.m_smartAnalysis.actual_more_than_forecast_and_actual_equal_to_previous = StringToTrend(temp["Actual > Forecast Actual = Previous"].ToStr());
      this.m_smartAnalysis.actual_less_than_forecast_and_previous = StringToTrend(temp["Actual < Forecast < Previous"].ToStr());
      this.m_smartAnalysis.actual_less_than_forecast_more_than_previous = StringToTrend(temp["Actual < Forecast Forecast > Previous"].ToStr());
      this.m_smartAnalysis.actual_less_than_forecast_and_actual_more_than_previous = StringToTrend(temp["Actual < Forecast Actual > Previous"].ToStr());
      this.m_smartAnalysis.actual_less_than_forecast_and_actual_equal_to_previous = StringToTrend(temp["Actual < Forecast Actual = Previous"].ToStr());
      this.m_smartAnalysis.actual_less_than_forecast_equal_to_previous = StringToTrend(temp["Actual < Forecast = Previous"].ToStr());
      this.m_smartAnalysis.actual_equal_to_forecast_and_previous = StringToTrend(temp["Actual = Forecast = Previous"].ToStr());
      this.m_smartAnalysis.actual_equal_to_forecast_less_than_previous = StringToTrend(temp["Actual = Forecast < Previous"].ToStr());
      this.m_smartAnalysis.actual_equal_to_forecast_more_than_previous = StringToTrend(temp["Actual = Forecast > Previous"].ToStr());

      // set machine learning
      temp = json["MachineLearning"];
      this.setML(temp);

     }

   void               addHistory(const NewsHistoryModel & history)
     {
      this.increaseHistory();
      for(int i = this.countHistory() - 1; i > 0; i--)
        {
         this.m_history[i] = this.m_history[i-1];
        }
      this.m_history[0] = history;
     }

   void               appendHistory(const NewsHistoryModel & history)
     {
      this.increaseHistory();
      this.m_history[this.countHistory()-1] = history;
     }

   void                clearHistory()
     {
      ZeroMemory(this.m_history);
      ArrayResize(this.m_history,0);

     }

   bool              decreaseHistory(void)
     {
      return ArrayResize(this.m_history,this.countHistory()-1) > 0;
     }


   int               countHistory(void)
     {
      return ArraySize(this.m_history);
     }

   bool              increaseHistory(void)
     {
      return ArrayResize(this.m_history,this.countHistory()+1) > 0;
     }

   void              removeHistory(const int index)
     {
      for(int i = index; i < this.countHistory() - 1; i++)
        {
         this.m_history[i] = this.m_history[i+1];
        }

      this.decreaseHistory();
     }

   void              removeHistory(const NewsHistoryModel & history)
     {
      for(int i = countHistory() - 1; i >= 0; i--)
        {
         if(
            this.m_history[i].actual      == history.actual &&
            this.m_history[i].category    == history.category &&
            this.m_history[i].currency    == history.currency &&
            this.m_history[i].date        == history.date &&
            this.m_history[i].id          == history.id &&
            this.m_history[i].forecast    == history.forecast &&
            this.m_history[i].name        == history.name &&
            this.m_history[i].outcome     == history.outcome &&
            this.m_history[i].previous    == history.previous &&
            this.m_history[i].projection  == history.projection &&
            this.m_history[i].quality     == history.quality &&
            this.m_history[i].strength    == history.strength
         )
           {
            this.removeHistory(i);
            break;
           }
        }
     }

   void              sortHistory(bool earliestFirst = true)
     {
      int n = this.countHistory();
      if(n <= 1)
         return;

      NewsHistoryModel temp;
      for(int i = 0; i < n - 1; i++)
        {
         for(int j = 0; j < n - 1 - i; j++)
           {
            if((earliestFirst && this.m_history[j].date > this.m_history[j + 1].date) ||
               (!earliestFirst && this.m_history[j].date < this.m_history[j + 1].date))
              {
               // Swap elements
               temp.actual = this.m_history[j].actual;
               temp.category = this.m_history[j].category;
               temp.currency = this.m_history[j].currency;
               temp.date = this.m_history[j].date;
               temp.forecast = this.m_history[j].forecast;
               temp.name = this.m_history[j].name;
               temp.id = this.m_history[j].id;
               temp.outcome = this.m_history[j].outcome;
               temp.previous = this.m_history[j].previous;
               temp.projection = this.m_history[j].projection;
               temp.quality = this.m_history[j].quality;
               temp.strength = this.m_history[j].strength;

               this.m_history[j].actual = this.m_history[j + 1].actual;
               this.m_history[j].category = this.m_history[j + 1].category;
               this.m_history[j].currency = this.m_history[j + 1].currency;
               this.m_history[j].date = this.m_history[j + 1].date;
               this.m_history[j].id  =  this.m_history[j + 1].id;
               this.m_history[j].forecast = this.m_history[j + 1].forecast;
               this.m_history[j].name = this.m_history[j + 1].name;
               this.m_history[j].outcome = this.m_history[j + 1].outcome;
               this.m_history[j].previous = this.m_history[j + 1].previous;
               this.m_history[j].projection = this.m_history[j + 1].projection;
               this.m_history[j].quality = this.m_history[j + 1].quality;
               this.m_history[j].strength = this.m_history[j + 1].strength;

               this.m_history[j + 1].actual = temp.actual;
               this.m_history[j + 1].category = temp.category;
               this.m_history[j + 1].currency = temp.currency;
               this.m_history[j + 1].date = temp.date;
               this.m_history[j + 1].id = temp.id;
               this.m_history[j + 1].forecast = temp.forecast;
               this.m_history[j + 1].name = temp.name;
               this.m_history[j + 1].outcome = temp.outcome;
               this.m_history[j + 1].previous = temp.previous;
               this.m_history[j + 1].projection = temp.projection;
               this.m_history[j + 1].quality = temp.quality;
               this.m_history[j + 1].strength = temp.strength;
              }
           }
        }
     }

   void              setHistory(const NewsHistoryModel & history[])
     {
      ArrayResize(this.m_history,ArraySize(history));
      for(int i = 0; i < ArraySize(history); i++)
        {
         this.m_history[i].actual      = history[i].actual;
         this.m_history[i].category    = history[i].category;
         this.m_history[i].currency    = history[i].currency;
         this.m_history[i].date        = history[i].date;
         this.m_history[i].id          = history[i].id;
         this.m_history[i].forecast    = history[i].forecast;
         this.m_history[i].name        = history[i].name;
         this.m_history[i].outcome     = history[i].outcome;
         this.m_history[i].previous    = history[i].previous;
         this.m_history[i].projection  = history[i].projection;
         this.m_history[i].quality     = history[i].quality;
         this.m_history[i].strength    = history[i].strength;
        }
     }

   void              setML(CJAVal & temp);

  };
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void CJBNewsModel::setML(CJAVal & temp)
  {
   this.m_machineLearning.oneHourAccuracy       = temp["1 Hour Accuracy"].ToDbl();
   this.m_machineLearning.thirtyMinuteAccuracy  = temp["30 Minute Accuracy"].ToDbl();
   this.m_machineLearning.oneMinuteAccuracy     = temp["1 Minute Accuracy"].ToDbl();


// actual_more_than_forecast_more_than_previous
   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[0].bearish = temp["Outcomes"]["Actual > Forecast > Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[0].bullish = temp["Outcomes"]["Actual > Forecast > Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[2].bearish = temp["Outcomes"]["Actual > Forecast > Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[2].bullish = temp["Outcomes"]["Actual > Forecast > Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[1].bearish = temp["Outcomes"]["Actual > Forecast > Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[1].bullish = temp["Outcomes"]["Actual > Forecast > Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_more_than_previous[1].timeframe = PERIOD_M30;



// actual_more_than_forecast_less_than_previous
   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[0].bearish = temp["Outcomes"]["Actual > Forecast Forecast < Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[0].bullish = temp["Outcomes"]["Actual > Forecast Forecast < Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[2].bearish = temp["Outcomes"]["Actual > Forecast Forecast < Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[2].bullish = temp["Outcomes"]["Actual > Forecast Forecast < Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[1].bearish = temp["Outcomes"]["Actual > Forecast Forecast < Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[1].bullish = temp["Outcomes"]["Actual > Forecast Forecast < Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_less_than_previous[1].timeframe = PERIOD_M30;



// actual_more_than_forecast_and_actual_less_than_previous
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[0].bearish = temp["Outcomes"]["Actual > Forecast Actual < Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[0].bullish = temp["Outcomes"]["Actual > Forecast Actual < Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[2].bearish = temp["Outcomes"]["Actual > Forecast Actual < Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[2].bullish = temp["Outcomes"]["Actual > Forecast Actual < Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[1].bearish = temp["Outcomes"]["Actual > Forecast Actual < Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[1].bullish = temp["Outcomes"]["Actual > Forecast Actual < Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_less_than_previous[1].timeframe = PERIOD_M30;



// actual_more_than_forecast_equal_to_previous
   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[0].bearish = temp["Outcomes"]["Actual > Forecast = Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[0].bullish = temp["Outcomes"]["Actual > Forecast = Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[2].bearish = temp["Outcomes"]["Actual > Forecast = Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[2].bullish = temp["Outcomes"]["Actual > Forecast = Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[1].bearish = temp["Outcomes"]["Actual > Forecast = Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[1].bullish = temp["Outcomes"]["Actual > Forecast = Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_equal_to_previous[1].timeframe = PERIOD_M30;



// actual_more_than_forecast_and_actual_equal_to_previous
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[0].bearish = temp["Outcomes"]["Actual > Forecast Actual = Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[0].bullish = temp["Outcomes"]["Actual > Forecast Actual = Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[2].bearish = temp["Outcomes"]["Actual > Forecast Actual = Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[2].bullish = temp["Outcomes"]["Actual > Forecast Actual = Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[1].bearish = temp["Outcomes"]["Actual > Forecast Actual = Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[1].bullish = temp["Outcomes"]["Actual > Forecast Actual = Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_more_than_forecast_and_actual_equal_to_previous[1].timeframe = PERIOD_M30;



// actual_less_than_forecast_and_previous
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[0].bearish = temp["Outcomes"]["Actual < Forecast < Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[0].bullish = temp["Outcomes"]["Actual < Forecast < Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[2].bearish = temp["Outcomes"]["Actual < Forecast < Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[2].bullish = temp["Outcomes"]["Actual < Forecast < Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[1].bearish = temp["Outcomes"]["Actual < Forecast < Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[1].bullish = temp["Outcomes"]["Actual < Forecast < Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_previous[1].timeframe = PERIOD_M30;



// actual_less_than_forecast_more_than_previous
   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[0].bearish = temp["Outcomes"]["Actual < Forecast Forecast > Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[0].bullish = temp["Outcomes"]["Actual < Forecast Forecast > Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[2].bearish = temp["Outcomes"]["Actual < Forecast Forecast > Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[2].bullish = temp["Outcomes"]["Actual < Forecast Forecast > Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[1].bearish = temp["Outcomes"]["Actual < Forecast Forecast > Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[1].bullish = temp["Outcomes"]["Actual < Forecast Forecast > Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_more_than_previous[1].timeframe = PERIOD_M30;



// actual_less_than_forecast_and_actual_more_than_previous
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[0].bearish = temp["Outcomes"]["Actual < Forecast Actual > Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[0].bullish = temp["Outcomes"]["Actual < Forecast Actual > Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[2].bearish = temp["Outcomes"]["Actual < Forecast Actual > Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[2].bullish = temp["Outcomes"]["Actual < Forecast Actual > Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[1].bearish = temp["Outcomes"]["Actual < Forecast Actual > Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[1].bullish = temp["Outcomes"]["Actual < Forecast Actual > Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_more_than_previous[1].timeframe = PERIOD_M30;



// actual_less_than_forecast_and_actual_equal_to_previous
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[0].bearish = temp["Outcomes"]["Actual < Forecast Actual = Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[0].bullish = temp["Outcomes"]["Actual < Forecast Actual = Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[2].bearish = temp["Outcomes"]["Actual < Forecast Actual = Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[2].bullish = temp["Outcomes"]["Actual < Forecast Actual = Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[1].bearish = temp["Outcomes"]["Actual < Forecast Actual = Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[1].bullish = temp["Outcomes"]["Actual < Forecast Actual = Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_and_actual_equal_to_previous[1].timeframe = PERIOD_M30;



// actual_less_than_forecast_equal_to_previous
   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[0].bearish = temp["Outcomes"]["Actual < Forecast = Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[0].bullish = temp["Outcomes"]["Actual < Forecast = Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[2].bearish = temp["Outcomes"]["Actual < Forecast = Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[2].bullish = temp["Outcomes"]["Actual < Forecast = Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[1].bearish = temp["Outcomes"]["Actual < Forecast = Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[1].bullish = temp["Outcomes"]["Actual < Forecast = Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_less_than_forecast_equal_to_previous[1].timeframe = PERIOD_M30;



// actual_equal_to_forecast_and_previous
   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[0].bearish = temp["Outcomes"]["Actual = Forecast = Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[0].bullish = temp["Outcomes"]["Actual = Forecast = Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[2].bearish = temp["Outcomes"]["Actual = Forecast = Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[2].bullish = temp["Outcomes"]["Actual = Forecast = Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[1].bearish = temp["Outcomes"]["Actual = Forecast = Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[1].bullish = temp["Outcomes"]["Actual = Forecast = Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_and_previous[1].timeframe = PERIOD_M30;



// actual_equal_to_forecast_less_than_previous
   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[0].bearish = temp["Outcomes"]["Actual = Forecast < Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[0].bullish = temp["Outcomes"]["Actual = Forecast < Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[2].bearish = temp["Outcomes"]["Actual = Forecast < Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[2].bullish = temp["Outcomes"]["Actual = Forecast < Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[1].bearish = temp["Outcomes"]["Actual = Forecast < Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[1].bullish = temp["Outcomes"]["Actual = Forecast < Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_less_than_previous[1].timeframe = PERIOD_M30;


// actual_equal_to_forecast_more_than_previous
   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[0].bearish = temp["Outcomes"]["Actual = Forecast > Previous"]["1 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[0].bullish = temp["Outcomes"]["Actual = Forecast > Previous"]["1 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[0].timeframe = PERIOD_M1;

   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[2].bearish = temp["Outcomes"]["Actual = Forecast > Previous"]["1 Hour"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[2].bullish = temp["Outcomes"]["Actual = Forecast > Previous"]["1 Hour"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[2].timeframe = PERIOD_H1;

   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[1].bearish = temp["Outcomes"]["Actual = Forecast > Previous"]["30 Minute"]["Bearish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[1].bullish = temp["Outcomes"]["Actual = Forecast > Previous"]["30 Minute"]["Bullish"].ToDbl();
   this.m_machineLearning.outcomes.actual_equal_to_forecast_more_than_previous[1].timeframe = PERIOD_M30;
  }
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH SmartAnalysisTrend(SmartAnalysisModel & model, ENUM_NEWS_STRATEGY strategy)
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
ENUM_BULLISH_OR_BEARISH MachineLearningTrend(MachineLearningOutcomeModel & model, ENUM_NEWS_STRATEGY strategy)
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
