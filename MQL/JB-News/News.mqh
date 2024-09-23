//+------------------------------------------------------------------+
//|                                                 News-Library.mqh |
//|                                          Copyright 2024,JBlanked |
//|                          https://www.jblanked.com/news/api/docs/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/news/api/docs/"
#property description "Access JBlanked's News Library."
#property strict
#include <jb-news\\Models.mqh>
// Last Update: September 23rd, 2024

#import "Wininet.dll"
int InternetOpenW(string name, int config, string, string, int);
int InternetOpenUrlW(int, string, string, int, int, int);
bool InternetReadFile(int, uchar &sBuffer[], int, int &OneInt);
bool InternetCloseHandle(int);
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, char &lpOptional[], int dwOptionalLength);
#import

/*
   Example use:

   #include <jb-news\\news.mqh>
   CJBNews *jb;

   int OnInit()
   {
      jb = new CJBNews();
      jb.api_key = "API_KEY";

      jb.offset = 0; // GMT-3 = 0, GMT = 3, EST = 7, PST = 10

      jb.chart(clrAliceBlue,clrWhite);


      return INIT_SUCCEEDED;
   }
   void OnDeinit(const int reason)
   {
      delete jb;
   }
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CJBNews
  {
public:
                     CJBNews::CJBNews()   // constructor
     {
      api_key = "";
      offset = 0;
      ObjectsDeleteAll(0, "CJBNews");
      ArrayResize(eventNames, 0);
      ArrayResize(calenderInfo, 0);
      ArrayResize(eventIDs, 0);
     }

   CJBNews::        ~CJBNews() // deconstructor
     {
      api_key = "";
      offset = 0;
      ObjectsDeleteAll(0, "CJBNews");
     }

   // adds one news event's data to newsInfo
   void              addNews(CJAVal & json)
     {
      const int n = this.count();
      ArrayResize(this.newsInfo, n + 1);
      this.newsInfo[n] = CJBNewsModel(json);
     }

   // remove news event from newsInfo array
   void              removeNews(const int index)
     {
      // shift items down
      for(int i = index; i < this.count() - 1; i++)
        {
         this.newsInfo[i] = this.newsInfo[i + 1];
        }
      // drop last item in list
      ArrayResize(this.newsInfo, this.count() - 1);
     }

   // remove all news events from newsInfo array
   void              removeAllNews(void)
     {
      ArrayResize(this.newsInfo, 0);
     }

   // returns the amount of news events
   int               count(void)
     {
      return ArraySize(this.newsInfo);
     }

   int               offset;                    // GMT-3 = 0, GMT = 3, EST = 7, PST = 10
   string            api_key;                   // API key from www.jblanked.com/profile/

   CJBNewsModel      newsInfo[];                // holds the event info after using the .get method
   bool              get(void);                 // connects to the api with your api key and loads all data

   NewsHistoryModel  calenderInfo[];            // holds the history info after using the .calendar method
   bool              calendar(                  // connects api with your key and loads all the calendar data
      bool today = false,
      bool this_week = false
   );

   bool              load(const long eventID);  // load a specific event into the .info property
   string            eventNames[];              // holds a list of all the event names after using the .get method
   long              eventIDs[];                // holds a list of all the event IDs after using the .get method

   void              chart(                     // displays this weeks history on the chart
      const color colorOfLine,
      const color colorOfText
   );

   string            GPT(const string message); // query the NewsGPT

   ENUM_BULLISH_OR_BEARISH  runAll(             // EA trading staregy
      const datetime currentTime,
      ENUM_NEWS_TREND_TYPE trendType = ENUM_SMART_ANALYSIS
   )
     {
      /*
      1. Loops through the list of all event IDs.
      2. Loads that event IDs info.
      3. Checks if the current time matches any of that event's dates in history
      4. Checks the ML trend and SA trend of the event
      5. Return bullish/bearish based upon the trend
      */
      for(c = 0; c < ArraySize(this.eventIDs); c++)
        {
         if(this.load(this.eventIDs[c]))
           {
            for(d = 0; d < this.info.eventCount; d++)
              {
               if(this.info.history[d].isEventTime(currentTime))
                 {
                  const ENUM_BULLISH_OR_BEARISH mL = this.info.trend(this.info.machineLearning.outcomes, this.info.history[d].outcome);
                  const ENUM_BULLISH_OR_BEARISH sa = this.info.trend(this.info.smartAnalysis, this.info.history[d].outcome);
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
           }
        }
      return ENUM_NEUTRAL;
     }

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
      double               division(const double numerator, const double denominator) {return denominator == 0 ? 0 : numerator / denominator;}

     }; // end of EventInfo struct

   EventInfo         info;                  // holds the event info after loading

   //--- takes api.result from  and converts into news model (use with caution)
   bool              _deserialize(string apiResult)
     {
      this.JSON.Deserialize(apiResult, CP_UTF8); // deserialize into JSON format

      //--- Setting USD events
      this.USD = this.JSON["USD"];
      this.EUR = this.JSON["EUR"];
      this.GBP = this.JSON["GBP"];
      this.JPY = this.JSON["JPY"];
      this.AUD = this.JSON["AUD"];
      this.CAD = this.JSON["CAD"];
      this.CHF = this.JSON["CHF"];
      this.NZD = this.JSON["NZD"];

      this.total_usd = this.USD["Total"].ToInt();

      if(this.total_usd == 0)
         return false;

      this.total_eur = this.EUR["Total"].ToInt();
      this.total_gbp = this.GBP["Total"].ToInt();
      this.total_jpy = this.JPY["Total"].ToInt();
      this.total_aud = this.AUD["Total"].ToInt();
      this.total_cad = this.CAD["Total"].ToInt();
      this.total_chf = this.CHF["Total"].ToInt();
      this.total_nzd = this.NZD["Total"].ToInt();

      // init
      this.place = 0;

      // clear arrays
      ArrayResize(this.newsInfo, 0);
      ArrayResize(this.eventIDs, 0);
      ArrayResize(this.eventNames, 0);

      // set
      this.setNewsModel(this.USD, this.total_usd, "USD");
      this.setNewsModel(this.EUR, this.total_eur, "EUR");
      this.setNewsModel(this.GBP, this.total_gbp, "GBP");
      this.setNewsModel(this.JPY, this.total_jpy, "JPY");
      this.setNewsModel(this.AUD, this.total_aud, "AUD");
      this.setNewsModel(this.CAD, this.total_cad, "CAD");
      this.setNewsModel(this.CHF, this.total_chf, "CHF");
      this.setNewsModel(this.NZD, this.total_nzd, "NZD");

      return true;
     }
   
   string            result; // used to hold API request json
   
private:
   uchar             buffer[1024];
   int               bytesRead;

   int               k;
   int               l;
   int               a;
   int               c;
   int               d;
   int               e;

   int               place;
   CJAVal            JSON;
   CJAVal            NZD, USD, CAD, AUD, EUR, CHF, GBP, JPY;

   long              total_events, total_usd, total_eur, total_nzd, total_gbp, total_chf, total_jpy, total_aud, total_cad;

   string            object_name;

   bool              ObjectFound(const string name) {return ObjectFind(0, name) < 0 ? false : true;}

   double            ChartPriceMin(const long chart_ID = 0, const int sub_window = 0)
     {
      double results = EMPTY_VALUE;
      ResetLastError();
      if(!ChartGetDouble(chart_ID, CHART_PRICE_MIN, sub_window, results))
         Print(__FUNCTION__ + ", Error Code = ", GetLastError());
      return(results);
     }

   void              Chart_Angled_Text(string name, double price, datetime time, string text, int fontsize, color color_type, int sub_window = 0, int angle = 90)
     {
      this.object_name = name + "AngTxt";

      if(!ObjectFound(this.object_name))
        {
         ObjectCreate(0, this.object_name, OBJ_TEXT, sub_window, time, price);
         ObjectSetInteger(0, this.object_name, OBJPROP_YDISTANCE, 5);
         ObjectSetInteger(0, this.object_name, OBJPROP_COLOR, color_type);
         ObjectSetDouble(0, this.object_name, OBJPROP_ANGLE, angle);
         ObjectSetString(0, this.object_name, OBJPROP_TEXT, text);
         ObjectSetInteger(0, this.object_name, OBJPROP_BACK, true);
         ObjectSetInteger(0, this.object_name, OBJPROP_FONTSIZE, fontsize);
        }
     }

   void              Chart_V_Line(string name, double price, datetime time, int width, color color_type, int sub_window = 0)
     {
      this.object_name = name;

      if(!ObjectFound(this.object_name))
        {
         ObjectCreate(0, this.object_name, OBJ_VLINE, 0, time, price);
         ObjectSetInteger(0, this.object_name, OBJPROP_COLOR, color_type);
         ObjectSetInteger(0, this.object_name, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, this.object_name, OBJPROP_WIDTH, width);
         ObjectSetInteger(0, this.object_name, OBJPROP_BACK, true);
         ObjectSetInteger(0, this.object_name, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, this.object_name, OBJPROP_SELECTED, false);
         ObjectSetInteger(0, this.object_name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, this.object_name, OBJPROP_ZORDER, 0);
        }
     }

   datetime          ChangeTime(datetime initial_time, int increment_by = 1);
   int               amountOfDays(int current_month, int year);
   void              setNewsModel(CJAVal & currencyJSON, const long eventCount, const string currency);

  }; // end of class
//+------------------------------------------------------------------+
//|           displays this weeks history on the chart               |
//+------------------------------------------------------------------+
void CJBNews::chart(const color colorOfLine, const color colorOfText)
  {
   if(this.calendar(false, true))
     {
      for(int j = 0; j < ArraySize(this.calenderInfo); j++)
        {
         this.Chart_V_Line(
            "CJBNews-" + (string)this.calenderInfo[j].date,
            ChartPriceMin(),
            this.calenderInfo[j].date,
            1,
            colorOfLine
         );

         this.Chart_Angled_Text(
            "CJBNews-Ang-" + (string)this.calenderInfo[j].date,
            ChartPriceMin(),
            this.calenderInfo[j].date,
            "   " + EnumToString(this.calenderInfo[j].currency) + "  -  " + this.calenderInfo[j].name,
            8,
            colorOfText
         );
        }
     }
  }
//+------------------------------------------------------------------+
//|    connects api with your key and loads all the calendar data    |
//+------------------------------------------------------------------+
bool CJBNews::calendar(bool today = false, bool this_week = false)
  {
   if(StringLen(this.api_key) < 30)
      return false;

   this.bytesRead = 0;
   this.result = "";

   string url = "https://www.jblanked.com/news/api/mql5/calendar/";
   if(today && !this_week)
      url = "https://www.jblanked.com/news/api/mql5/calendar/today/";
   else
      if(this_week && !today)
         url = "https://www.jblanked.com/news/api/mql5/calendar/week/";


   const string headers = "Content-Type: application/json" + "\r\n" + "Authorization: Api-Key " + api_key;

// Initialize WinHTTP
   const int hInternet = InternetOpenW("MyApp", 1, NULL, NULL, 0);
   if(hInternet)
     {
      // Open a URL
      const int hUrl = InternetOpenUrlW(hInternet, url, NULL, 0, 0, 0);
      if(hUrl)
        {
         // Send the request headers
         if(HttpSendRequestW(hUrl, headers, StringLen(headers), buffer, 0))
           {
            // Read the response
            while(InternetReadFile(hUrl, buffer, ArraySize(buffer) - 1, bytesRead) && bytesRead > 0)
              {
               buffer[bytesRead] = 0; // Null-terminate the buffer
               result += CharArrayToString(buffer, 0, bytesRead, CP_UTF8); // Append the data to the result string
              }
           }
         else
           {
            return false;
           }

         InternetCloseHandle(hUrl); // Close the request handle

         InternetCloseHandle(hUrl); // Close the URL handle
        }
      else
        {
         return false;
        }
      InternetCloseHandle(hInternet); // Close the WinHTTP handle
     }
   else
     {
      return false;
     }

   if(result != "")
     {
      this.JSON.Deserialize(result, CP_UTF8); // deserialize into JSON format

      CJAVal temp;

      ArrayResize(this.calenderInfo, 7000);
      for(e = 0; e < 7000; e++)
        {
         temp = this.JSON[e];

         if(datetime(temp["Date"].ToStr()) == 0)
            break;
         else
           {
            this.calenderInfo[e].set(temp);
           }

        }

      ArrayResize(this.calenderInfo, e + 1);

      return true;
     }
   else
     {
      return false;
     }
  }

//+------------------------------------------------------------------+
//|       Get the Machine Learning Trend based upon the outcome      |
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH CJBNews::EventInfo::trendML(const string outcome)
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
ENUM_BULLISH_OR_BEARISH CJBNews::EventInfo::trendSA(const string outcome)
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
string CJBNews::EventInfo::outcome(const int iteration)
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
//----------------------------------------------------------------+
//|            Load the Event Info for the specified Event ID        |
//+------------------------------------------------------------------+
bool CJBNews::load(const long eventID)
  {
   for(a = 0; a < ArraySize(this.newsInfo); a++)
     {
      if(this.newsInfo[a].m_id == eventID)
        {
         this.info.name       = this.newsInfo[a].m_name;
         this.info.currency   = this.newsInfo[a].m_currency;
         this.info.id         = this.newsInfo[a].m_id;
         this.info.category   = this.newsInfo[a].m_category;

         this.info.eventCount = ArraySize(this.newsInfo[a].m_history);
         ArrayResize(this.info.history, this.info.eventCount);

         for(l = 0; l < this.info.eventCount; l++)
           {
            this.info.history[l]    = this.newsInfo[a].m_history[l];
           }

         this.info.machineLearning  = this.newsInfo[a].m_machineLearning;
         this.info.smartAnalysis    = this.newsInfo[a].m_smartAnalysis;

         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//|            Connect to API and Parse the Data                     |
//+------------------------------------------------------------------+
bool CJBNews::get()
  {
   if(StringLen(this.api_key) < 30)
      return false;

   this.bytesRead = 0;
   this.result = "";
   static const string url = "https://www.jblanked.com/news/api/mql5/full-list/";
   const string headers = "Content-Type: application/json" + "\r\n" + "Authorization: Api-Key " + this.api_key;

// Initialize WinHTTP
   const int hInternet = InternetOpenW("MyApp", 1, NULL, NULL, 0);
   if(hInternet)
     {
      // Open a URL
      const int hUrl = InternetOpenUrlW(hInternet, url, NULL, 0, 0, 0);
      if(hUrl)
        {
         // Send the request headers
         if(HttpSendRequestW(hUrl, headers, StringLen(headers), this.buffer, 0))
           {
            // Read the response
            while(InternetReadFile(hUrl, this.buffer, ArraySize(this.buffer) - 1, this.bytesRead) && this.bytesRead > 0)
              {
               this.buffer[this.bytesRead] = 0; // Null-terminate the buffer
               this.result += CharArrayToString(this.buffer, 0, this.bytesRead, CP_UTF8); // Append the data to the result string
              }
           }
         else
           {
            Print("Failed to send request headers");
            return false;
           }

         InternetCloseHandle(hUrl); // Close the request handle

         InternetCloseHandle(hUrl); // Close the URL handle
        }
      else
        {
         Print("Failed to open ", url);
         return false;
        }
      InternetCloseHandle(hInternet); // Close the WinHTTP handle
     }
   else
     {
      Print("Failed to open internet");
      return false;
     }

   if(this.result != "")
     {
      return this._deserialize(this.result);
     }
   else
     {
      Print("Failed! Data is empty");
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CJBNews::setNewsModel(CJAVal & currencyJSON, const long eventCount, const string currency)
  {
   ArrayResize(this.newsInfo, ArraySize(this.newsInfo) + (int)eventCount);
   ArrayResize(this.eventIDs, ArraySize(this.eventIDs) + (int)eventCount);
   ArrayResize(this.eventNames, ArraySize(this.eventNames) + (int)eventCount);
   for(int n = 0; n < (int)eventCount; n++)
     {
      // set currency since the /full-list/ endpoint doesn't contain currency in the list
      currencyJSON["Events"][n]["Currency"] = currency;
      this.newsInfo[this.place]    = CJBNewsModel(currencyJSON["Events"][n]);
      this.eventIDs[this.place]    = this.newsInfo[this.place].m_id;
      this.eventNames[this.place]  = this.newsInfo[this.place].m_name;
      this.place++;
     }
  };
//+------------------------------------------------------------------+
datetime CJBNews::ChangeTime(datetime initial_time, int increment_by = 1)
  {
   MqlDateTime date;
   TimeToStruct(initial_time, date);

   int year = 0, month = 0, day = 0;
   int increase;

   year = date.year;
   month = date.mon;
   day = date.day;

   increase = date.hour + increment_by;

   if(increase < 24)
      date.hour = increase;
   else
     {
      date.day += increase / 24;  // Increment days by the number of complete days in 'increase'
      date.hour = increase % 24;  // Set hour to the remainder

      // Check and update the month and year if needed
      while(date.day > amountOfDays(date.mon, date.year))
        {
         date.day -= amountOfDays(date.mon, date.year);
         date.mon++;

         if(date.mon > 12)
           {
            date.mon = 1;
            date.year++;
           }
        }

      // Update the year, month, and day from the date structure
      year = date.year;
      month = date.mon;
      day = date.day;
     }

// Return the modified datetime
   return datetime(StringToTime((string)year + "." + (string)month + "." + (string)day + " " + (string)date.hour + ":" + (string)date.min + ":" + (string)date.sec));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CJBNews::amountOfDays(int current_month, int year)
  {
   int amount = 0;

   switch(current_month)
     {
      case 2:
         amount = year % 4 == 0 ? 28 : 29;
         break;

      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
         amount = 31;
         break;

      case 4:
      case 6:
      case 9:
      case 11:
         amount = 30;
         break;
     }

   return amount;

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CJBNews::GPT(const string message)
  {
   if(StringLen(api_key) < 30)
      return "Invalid API Key";

   bytesRead = 0;
   result = "";
   string tempMessage = "";
   int iter = 0;

//--- serialize to string
   result = "";
   char data[];
   this.JSON["content"] = message;
   ArrayResize(data, StringToCharArray(this.JSON.Serialize(), data, 0, WHOLE_ARRAY) - 1);

   static const string gptUrl = "https://www.jblanked.com/news/api/gpt/";
   const string headers = "Content-Type: application/json" + "\r\n" + "Authorization: Api-Key " + api_key;

//--- send data
   char res_data[];
   string res_headers = NULL;
   int r = WebRequest("POST", gptUrl, headers, 5000, data, res_data, res_headers);

   if(r != -1)
     {
      result = CharArrayToString(res_data, 0, -1, CP_UTF8);

      if(StringLen(result) > 0)
        {
         this.JSON.Clear();
         this.JSON.Deserialize(result, CP_UTF8);
        }

      const string task_id = this.JSON["task_id"].ToStr();


      while(
         (tempMessage == "" || tempMessage == "Task started" || tempMessage == "Task is still processing")
         && iter < 15)
        {
         this.result = "";
         // run get request with wait
         Sleep(2000);
         // Initialize WinHTTP
         const int hInternet = InternetOpenW("MyApp", 1, NULL, NULL, 0);
         if(hInternet)
           {
            // Open a URL
            const int hUrl = InternetOpenUrlW(hInternet, (gptUrl + "status/" + task_id + "/"), NULL, 0, 0, 0);
            if(hUrl)
              {
               // Send the request headers
               if(HttpSendRequestW(hUrl, headers, StringLen(headers), buffer, 0))
                 {
                  // Read the response
                  while(InternetReadFile(hUrl, buffer, ArraySize(buffer) - 1, bytesRead) && bytesRead > 0)
                    {
                     buffer[bytesRead] = 0; // Null-terminate the buffer
                     result += CharArrayToString(buffer, 0, bytesRead, CP_UTF8); // Append the data to the result string
                    }
                 }
               else
                 {
                  return "Error sending the request headers";
                 }

               InternetCloseHandle(hUrl); // Close the request handle

               InternetCloseHandle(hUrl); // Close the URL handle
              }
            else
              {
               return "Error opening the internet";
              }
            InternetCloseHandle(hInternet); // Close the WinHTTP handle
           }
         else
           {
            return "Error initializing WinHTTP";
           }

         if(result != "")
           {
            this.JSON.Clear();
            this.JSON.Deserialize(result, CP_UTF8);
            tempMessage = this.JSON["message"].ToStr();
           }
         else
           {
            return "Error... response returned nothing.";
           }

        }


     }
   else
     {
      MessageBox("Add the address 'https://www.jblanked.com/'  to the list of allowed URLs on tab 'Expert Advisors'", "Error", MB_ICONINFORMATION);
      return "Error occured..";
     }

   return tempMessage;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH CJBNews::EventInfo::trend(SmartAnalysisModel & model, ENUM_NEWS_STRATEGY strategy)
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
ENUM_BULLISH_OR_BEARISH CJBNews::EventInfo::trend(MachineLearningOutcomeModel & model, ENUM_NEWS_STRATEGY strategy)
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
