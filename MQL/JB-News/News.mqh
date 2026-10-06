//+------------------------------------------------------------------+
//|                                                 News-Library.mqh |
//|                                     Copyright 2024-2026,JBlanked |
//|                          https://www.jblanked.com/news/api/docs/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2026,JBlanked"
#property link      "https://www.jblanked.com/news/api/docs/"
#property description "Access JBlanked's News Library."
#property strict
#include "Models.mqh"
// Last Update: October 6th, 2026

#import "Wininet.dll"
int InternetOpenW(string name, int config, string, string, int);
int InternetOpenUrlW(int, string, string, int, int, int);
bool InternetReadFile(int, uchar &sBuffer[], int, int &OneInt);
bool InternetCloseHandle(int);
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, uchar &lpOptional[], int dwOptionalLength);
#import

#ifdef __MQL5__
#define NEWS_USER_AGENT "MetaTrader 5 Terminal (Wininet)"
#else
#define NEWS_USER_AGENT "MetaTrader 4 Terminal (Wininet)"
#endif
/*
   Example use:

   #include <jb-news\\news.mqh>
   CJBNews *jb;

   int OnInit()
   {
      jb = new CJBNews();
      jb.api_key = "API_KEY";

      jb.offset = 0; // GMT-3 = 0, GMT = 3, EST = 7, PST = 10

      jb.chart();

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
   int               offset;                    // GMT-3 = 0, GMT = 3, EST = 7, PST = 10
   string            api_key;                   // API key from www.jblanked.com/profile/
   CJBNewsModel      newsInfo[];                // holds the event info after using the .get method
   NewsHistoryModel  calenderInfo[];            // holds the history info after using the .calendar method
   string            eventNames[];              // holds a list of all the event names after using the .get method
   long              eventIDs[];                // holds a list of all the event IDs after using the .get method
   EventInfo         info;                      // holds the event info after loading

   CJBNews();                                               // constructor
   ~CJBNews();                                              // deconstructor
   void              addNews(CJAVal & json);                // adds one news event's data to newsInfo
   bool              calendar(                              // connects api with your key and loads all the calendar data
      const ENUM_NEWS_FREQUENCY newsFrequency,
      const ENUM_NEWS_SOURCE newsSource = NEWS_SOURCE_MQL5
   );
   bool              chart(                                 // displays this weeks history on the chart
      const ENUM_NEWS_SOURCE newsSource = NEWS_SOURCE_MQL5
   );
   int               count(void);                           // returns the amount of news events
   bool              get(void);                             // connects to the api with your api key and loads all data
   string            GPT(const string message);             // query the NewsGPT
   bool              load(const long eventID);              // load a specific event into the .info property
   void              removeNews(const int index);           // remove news event from newsInfo array
   void              removeAllNews(void);                   // remove all news events from newsInfo array
   bool              _deserialize(string apiResult);        // takes api.result from  and converts into news model
   string            getRequest(const string url);          // send a get request to the URL with preset headers

   ENUM_BULLISH_OR_BEARISH  runAll(                         // EA trading staregy
      const datetime currentTime,
      ENUM_NEWS_TREND_TYPE trendType = ENUM_SMART_ANALYSIS
   );

private:
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

   bool              ObjectFound(const string name);
   double            ChartPriceMin(const long chart_ID = 0, const int sub_window = 0);
   void              Chart_Angled_Text(string name, double price, datetime time, string text, int fontsize, color color_type, int sub_window = 0, int angle = 90);
   void              Chart_V_Line(string name, double price, datetime time, int width, color color_type, int sub_window = 0);
   datetime          ChangeTime(datetime initial_time, int increment_by = 1);
   int               amountOfDays(int current_month, int year);
   void              setNewsModel(CJAVal & currencyJSON, const long eventCount, const string currency);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CJBNews::CJBNews()   // constructor
{
   api_key = "";
   offset = 0;
   ObjectsDeleteAll(0, "CJBNews");
   ArrayResize(eventNames, 0);
   ArrayResize(calenderInfo, 0);
   ArrayResize(eventIDs, 0);
}
//+------------------------------------------------------------------+
//| Deconstructor                                                    |
//+------------------------------------------------------------------+
CJBNews::        ~CJBNews() // deconstructor
{
   api_key = "";
   offset = 0;
   ObjectsDeleteAll(0, "CJBNews");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              CJBNews::_deserialize(string apiResult)
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

//+------------------------------------------------------------------+
//| Adds one news event's data to newsInfo                           |
//+------------------------------------------------------------------+
void              CJBNews::addNews(CJAVal & json)
{
   const int n = this.count();
   ArrayResize(this.newsInfo, n + 1);
   this.newsInfo[n] = CJBNewsModel(json);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double            CJBNews::ChartPriceMin(const long chart_ID = 0, const int sub_window = 0)
{
   double results = EMPTY_VALUE;
   ResetLastError();
   if(!ChartGetDouble(chart_ID, CHART_PRICE_MIN, sub_window, results))
      Print(__FUNCTION__ + ", Error Code = ", GetLastError());
   return(results);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              CJBNews::Chart_Angled_Text(string name, double price, datetime time, string text, int fontsize, color color_type, int sub_window = 0, int angle = 90)
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              CJBNews::Chart_V_Line(string name, double price, datetime time, int width, color color_type, int sub_window = 0)
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

//+------------------------------------------------------------------+
//| Remove news event from newsInfo array                            |
//+------------------------------------------------------------------+
void              CJBNews::removeNews(const int index)
{
// shift items down
   for(int i = index; i < this.count() - 1; i++)
   {
      this.newsInfo[i] = this.newsInfo[i + 1];
   }
// drop last item in list
   ArrayResize(this.newsInfo, this.count() - 1);
}

//+------------------------------------------------------------------+
//| Remove all news events from newsInfo array                       |
//+------------------------------------------------------------------+
void              CJBNews::removeAllNews(void)
{
   ArrayResize(this.newsInfo, 0);
}

//+------------------------------------------------------------------+
//| Get the amount of news events                                    |
//+------------------------------------------------------------------+
int               CJBNews::count(void)
{
   return ArraySize(this.newsInfo);
}

//+------------------------------------------------------------------+
//|           displays this weeks history on the chart               |
//+------------------------------------------------------------------+
bool CJBNews::chart(const ENUM_NEWS_SOURCE newsSource = NEWS_SOURCE_MQL5)
{
   if(this.calendar(NEWS_FREQUENCY_WEEK, newsSource))
   {
      static color _color = clrGray;
      for(int j = 0; j < ArraySize(this.calenderInfo); j++)
      {
         _color = NewsImpactToColor(this.calenderInfo[j].impact);

         this.Chart_V_Line(
            "CJBNews-" + (string)this.calenderInfo[j].date,
            ChartPriceMin(),
            this.calenderInfo[j].date,
            1,
            _color
         );

         this.Chart_Angled_Text(
            "CJBNews-Ang-" + (string)this.calenderInfo[j].date,
            ChartPriceMin(),
            this.calenderInfo[j].date,
            "   " + CurrencyToString(this.calenderInfo[j].currency) + "  -  " + this.calenderInfo[j].name,
            8,
            _color
         );
      }
      return true;
   }
   return false;
}
//+------------------------------------------------------------------+
//|    connects api with your key and loads all the calendar data    |
//+------------------------------------------------------------------+
bool CJBNews::calendar(ENUM_NEWS_FREQUENCY newsFrequency, ENUM_NEWS_SOURCE newsSource = NEWS_SOURCE_MQL5)
{
   const string url = NewsFrequencyToEndpoint(newsFrequency, newsSource);
   string result = getRequest(url);
   if(result == "") return false;
   this.JSON.Deserialize(result, CP_UTF8); // deserialize into JSON format

   CJAVal temp;

   ArrayResize(this.calenderInfo, 7000);
   for(e = 0; e < 7000; e++)
   {
      temp = this.JSON[e];

      if(datetime(temp["Date"].ToStr()) == 0)
         break;

      this.calenderInfo[e].set(temp);
   }

   ArrayResize(this.calenderInfo, e + 1);
   return true;
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
         this.info.impact     = this.newsInfo[a].m_impact;

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
   string result = getRequest("https://www.jblanked.com/news/api/mql5/full-list/");
   if(result == "") return false;
   return this._deserialize(result);
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

   uchar buffer[1024];
   int bytesRead = 0;
   string result = "";
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
         result = "";
         // run get request with wait
         Sleep(2000);
         // Initialize WinHTTP
         const int hInternet = InternetOpenW(NEWS_USER_AGENT, 1, NULL, NULL, 0);
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
//|                                                                  |
//+------------------------------------------------------------------+
string CJBNews::getRequest(const string url)
{
   if(StringLen(this.api_key) < 30)
      return "";

   uchar buffer[1024];
   int bytesRead = 0;
   string result = "";
   const string headers = "Content-Type: application/json" + "\r\n" + "Authorization: Api-Key " + this.api_key;

// Initialize WinHTTP
   const int hInternet = InternetOpenW(NEWS_USER_AGENT, 1, NULL, NULL, 0);
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
         InternetCloseHandle(hUrl); // Close the URL handle
      }
      InternetCloseHandle(hInternet); // Close the WinHTTP handle
   }
   return result;
}
//+------------------------------------------------------------------+
bool              CJBNews::ObjectFound(const string name)
{
   return ObjectFind(0, name) < 0 ? false : true;
}
//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH  CJBNews::runAll(             // EA trading staregy
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
//+------------------------------------------------------------------+
