//+------------------------------------------------------------------+
//|                                                 News-Library.mqh |
//|                                          Copyright 2024,JBlanked |
//|                          https://www.jblanked.com/news/api/docs/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/news/api/docs/"
#property description "Access JBlanked's News Library that includes Machine Learning, Auto Smart Analysis, and Event History information."

// Last Update: April 13th, 2024

#import "Wininet.dll"
int InternetOpenW(string name, int config, string, string, int);
int InternetOpenUrlW(int, string, string, int, int, int);
bool InternetReadFile(int, uchar &sBuffer[], int, int &OneInt);
bool InternetCloseHandle(int);
bool HttpAddRequestHeadersW(int, string, int, int);
int HttpOpenRequestW(int, string, string, string, string, string, int, int);
bool HttpSendRequestW(int hRequest, string lpszHeaders, int dwHeadersLength, char &lpOptional[], int dwOptionalLength);
bool InternetWriteFile(int, uchar &[], int, int &);
bool InternetQueryDataAvailable(int, int &);
bool InternetSetOptionW(int, int, int &, int);
int InternetConnectW(int, string, int, string, string, int, int, int);
int InternetReadFile(int, string, int, int& OneInt[]);
#import

/*
   Example use:

  CJBNews *jb = new CJBNews();

   int OnInit(){
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

#include <jason_with_search.mqh> // JSON library
enum enum_list_choice {ENUM_NAMES,ENUM_IDS}; // enum for eventList function (event names or event IDs)
enum enum_news_trend {ENUM_BULL,ENUM_BEAR,ENUM_NEUTRAL}; // enum for news trend (bullish, bearish, neutral)
enum enum_ml_sa {ENUM_ML,ENUM_SA,ENUM_ML_SA}; // enum to choose machine learning, smart analysis, or both
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CJBNews
  {
private:
   uchar             buffer[1024];
   int               bytesRead;
   string            result;
   int               evnt;
   int               k;
   int               hist;
   int               l;
   int               a;
   int               b;
   int               c;
   int               d;
   int               e;
   int               place;
   CJAVal            JSON;
   CJAVal            NZD,USD,CAD,AUD,EUR,CHF,GBP,JPY;
   double            act,forc,prev;
   CJAVal            EventTemp,HistTemp, Hist2Temp, MLTemp, SATemp;
   long              total_events, total_usd, total_eur, total_nzd, total_gbp, total_chf, total_jpy, total_aud, total_cad;
   string            EventHistory[8][60][250][11];
   string            MachineLearning[8][60][14][10];
   string            SmartAnalysis[8][60][14][2];
   string            EventNames[8][60];
   string            EventCurrencies[8];
   long              EventIDs[8][60];
   string            EventCategories[8][60];
   void              json_set(CJAVal & Currency, long event_total, int currency);
   void              eventList(string & destination_list[]);
   void              eventList(long & destination_list[]);
   string            object_name;

   bool              ObjectFound(string name) {return ObjectFind(0, name) < 0 ? false : true;}

   double            ChartPriceMin(const long chart_ID=0,const int sub_window=0)
     {
      double results=EMPTY_VALUE;
      ResetLastError();
      if(!ChartGetDouble(chart_ID,CHART_PRICE_MIN,sub_window,results))
         Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(results);
     }

   void              Chart_Angled_Text(string name, double price, datetime time, string text, int fontsize, color color_type, int sub_window = 0, int angle = 90)
     {
      object_name = name + "AngTxt";

      if(!ObjectFound(object_name))
        {
         ObjectCreate(0,object_name,OBJ_TEXT,sub_window,time,price);
         ObjectSetInteger(0,object_name,OBJPROP_YDISTANCE,5);
         ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type);
         ObjectSetDouble(0,object_name,OBJPROP_ANGLE,angle);
         ObjectSetString(0,object_name,OBJPROP_TEXT,text);
         ObjectSetInteger(0,object_name,OBJPROP_BACK,true);
         ObjectSetInteger(0,object_name,OBJPROP_FONTSIZE,fontsize);
        }
     }

   void              Chart_V_Line(string name, double price, datetime time, int width, color color_type, int sub_window = 0)
     {
      object_name = name;

      if(!ObjectFound(object_name))
        {
         ObjectCreate(0,object_name,OBJ_VLINE,0,time,price);
         ObjectSetInteger(0,object_name,OBJPROP_COLOR,color_type);
         ObjectSetInteger(0,object_name,OBJPROP_STYLE,STYLE_SOLID);
         ObjectSetInteger(0,object_name,OBJPROP_WIDTH,width);
         ObjectSetInteger(0,object_name,OBJPROP_BACK,true);
         ObjectSetInteger(0,object_name,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,object_name,OBJPROP_SELECTED,false);
         ObjectSetInteger(0,object_name,OBJPROP_HIDDEN,true);
         ObjectSetInteger(0,object_name,OBJPROP_ZORDER,0);
        }
     }
   
   datetime ChangeTime(datetime initial_time, int increment_by = 1);
   int amountOfDays(int current_month, int year);


   struct HistoryInfo
     {
      string         name;
      string         currency;
      long           eventID;
      string         category;
      datetime       date;
      double         actual;
      double         forecast;
      double         previous;
      double         projection;
      string         outcome;
      string         strength;
      string         quality;
     };

   struct EventInfo
     {
   private:
      double         division(double numerator,double denominator) {return denominator == 0 ? 0 : numerator / denominator;}
   public:
      enum_news_trend trendML(const string outcome);
      enum_news_trend trendSA(const string outcome);
      string         outcome(const int iteration);
      bool           isEventTime(const int iteration,const datetime currentTime) { return (datetime)eventHistory[iteration].date != 0 && (datetime)eventHistory[iteration].date == currentTime; }
      string         name;
      string         currency;
      long           eventID;
      string         category;
      HistoryInfo    eventHistory[];
      int            eventCount;
      string         machineLearning[14][10];
      string         smartAnalysis[14][2];

      enum_news_trend runEvent(const datetime currentTime,enum_ml_sa trendType = ENUM_ML_SA)
        {
         /*
         1. Checks if the current time matches the event's dates in history
         2. Checks the ML trend and SA trend of the event
         3. Return bullish/bearish based upon the trend
         */

         for(int q = 0; q < 250; q++)
            if(isEventTime(q,currentTime))
              {
               const string oc = outcome(q);
               const enum_news_trend mL = trendML(oc);
               const enum_news_trend sa = trendSA(oc);
               if(trendType == ENUM_ML)
                  return mL;
               else
                  if(trendType == ENUM_SA)
                     return sa;
                  else
                    {
                     if(sa == ENUM_BULL && (mL == ENUM_BULL || mL == ENUM_NEUTRAL))
                        return ENUM_BULL;
                     else
                        if(sa == ENUM_BEAR && (mL == ENUM_BEAR || mL == ENUM_NEUTRAL))
                           return ENUM_BEAR;
                        else
                           return ENUM_NEUTRAL;
                    }

              }

         return ENUM_NEUTRAL;
        }

     };

public:
                     CJBNews::CJBNews()   // constructor
     {
      api_key = "";
      offset = 0;
      ObjectsDeleteAll(0,"CJBNews");
      ArrayResize(eventNames,0);
      ArrayResize(history,0);
      ArrayResize(eventIDs,0);
     }

   CJBNews::        ~CJBNews() // deconstructor
     {
      api_key = "";
      offset = 0;
      ObjectsDeleteAll(0,"CJBNews");
     }

   int               offset;                    // GMT-3 = 0, GMT = 3, EST = 7, PST = 10
   string            api_key;                  // API key from www.jblanked.com/profile/
   bool              get();                      // connects to the api with your api key and loads all data
   bool              calendar(bool today=false, bool this_week = false); // connects api with your key and loads all the calendar data
   bool              load(const long eventID);   // sets the appropriate .info properties to the eventID's event information
   string            eventNames[];             // list of all the event names
   long              eventIDs[];                 // list of all the event IDs
   EventInfo         info;                  // holds the event info after loading
   HistoryInfo       history[];           // holds the history info after loading the calendar
   void              chart(const color colorOfLine, const color colorOfText); // displays this weeks history on the chart

   enum_news_trend   CJBNews::runAll(const datetime currentTime,enum_ml_sa trendType = ENUM_ML_SA) // EA trading staregy
     {
      /*
      1. Loops through the list of all event IDs.
      2. Loads that event IDs info.
      3. Checks if the current time matches any of that event's dates in history
      4. Checks the ML trend and SA trend of the event
      5. Return bullish/bearish based upon the trend
      */
      for(c = 0; c < ArraySize(eventIDs); c++)
         if(load(eventIDs[c]))
            for(d = 0; d < info.eventCount; d++)
               if(info.isEventTime(d,currentTime))
                 {
                  const string oc = info.outcome(d);
                  const enum_news_trend mL = info.trendML(oc);
                  const enum_news_trend sa = info.trendSA(oc);
                  if(trendType == ENUM_ML)
                     return mL;
                  else
                     if(trendType == ENUM_SA)
                        return sa;
                     else
                       {
                        if(sa == ENUM_BULL && (mL == ENUM_BULL || mL == ENUM_NEUTRAL))
                           return ENUM_BULL;
                        else
                           if(sa == ENUM_BEAR && (mL == ENUM_BEAR || mL == ENUM_NEUTRAL))
                              return ENUM_BEAR;
                           else
                              return ENUM_NEUTRAL;
                       }

                 }


      return ENUM_NEUTRAL;
     }


  };
//+------------------------------------------------------------------+
//|           displays this weeks history on the chart               |
//+------------------------------------------------------------------+
void CJBNews::chart(const color colorOfLine, const color colorOfText)
  {
   if(calendar(false,true))
      for(int j = 0; j < ArraySize(history); j++)
        {
         Chart_V_Line(
            "CJBNews-" + (string)history[j].date,
            ChartPriceMin(),
            history[j].date,
            1,
            colorOfLine
         );

         Chart_Angled_Text(
            "CJBNews-Ang-" + (string)history[j].date,
            ChartPriceMin(),
            history[j].date,
            "   " + history[j].currency + "  -  " + history[j].name,
            8,
            colorOfText
         );
        }

  }
//+------------------------------------------------------------------+
//|    connects api with your key and loads all the calendar data    |
//+------------------------------------------------------------------+
bool CJBNews::calendar(bool today=false, bool this_week = false)
  {
   if(StringLen(api_key)<30)
      return false;

   bytesRead = 0;
   result = "";

   string url = "https://www.jblanked.com/news/api/calendar/";
   if(today&&!this_week)
      url = "https://www.jblanked.com/news/api/calendar/today/";
   else
      if(this_week && !today)
         url = "https://www.jblanked.com/news/api/calendar/week/";


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
      JSON.Deserialize(result, CP_UTF8); // deserialize into JSON format

      CJAVal temp;

      ArrayResize(history,7000);
      for(e = 0; e < 7000; e++)
        {
         temp = JSON[e];

         if(datetime(temp["Date"].ToStr())==0)
            break;
         else
           {
            history[e].actual = temp["Actual"].ToDbl();
            history[e].forecast = temp["Forecast"].ToDbl();
            history[e].previous = temp["Previous"].ToDbl();
            history[e].category = temp["Category"].ToStr();
            history[e].date = (ChangeTime(StringToTime(temp["Date"].ToStr()),offset));
            history[e].eventID = temp["Event_ID"].ToInt();
            history[e].name = temp["Name"].ToStr();
            history[e].outcome = temp["Outcome"].ToStr();
            history[e].quality = temp["Quality"].ToStr();
            history[e].strength = temp["Strength"].ToStr();
            history[e].currency = temp["Currency"].ToStr();
            history[e].projection = temp["Projection"].ToDbl();
           }

        }

      ArrayResize(history,e+1);

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
enum_news_trend CJBNews::EventInfo::trendML(const string outcome)
  {
   for(int q = 0; q < 13; q++)
      if(machineLearning[q][0] == outcome)
        {
         const double bullish = division((double)machineLearning[q][1] + (double)machineLearning[q][3] + (double)machineLearning[q][5],3);
         const double bearish = division((double)machineLearning[q][2] + (double)machineLearning[q][4] + (double)machineLearning[q][6],3);
         const double accuracy = division((double)machineLearning[q][7] + (double)machineLearning[q][8] + (double)machineLearning[q][9],3) * 100;
         if(accuracy>50)
           {
            if(bullish>bearish)
               return ENUM_BULL;
            else
               return ENUM_BEAR;
           }
         else
            return ENUM_BEAR;
        }
      else
         return ENUM_BEAR;

   return ENUM_NEUTRAL;
  }
//+------------------------------------------------------------------+
//|       Get the Smart Analysis Trend based upon the outcome        |
//+------------------------------------------------------------------+
enum_news_trend CJBNews::EventInfo::trendSA(const string outcome)
  {

   for(int q = 0; q < 13; q++)
      if(smartAnalysis[q][0] == outcome)
        {
         if(smartAnalysis[q][1] == "Bullish")
            return ENUM_BULL;
         else
            if(smartAnalysis[q][1] == "Bearish")
               return ENUM_BEAR;
            else
               return ENUM_NEUTRAL;
        }

   return ENUM_NEUTRAL;
  }
//+------------------------------------------------------------------+
//|                     Get the outcome                              |
//+------------------------------------------------------------------+
string CJBNews::EventInfo:: outcome(const int iteration)
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

   const double actual = (double)eventHistory[iteration].actual;
   const double forecast = (double)eventHistory[iteration].forecast;
   const double previous = (double)eventHistory[iteration].previous;

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
//|               Get list of News Events IDs in the API             |
//+------------------------------------------------------------------+
void CJBNews::eventList(long & destination_list[])
  {
   ArrayResize(destination_list,5000);
   place = 0;

   for(c = 0; c < 8; c++)
     {
      for(d = 0; d < 60; d++)
         if(EventIDs[c][d] !=  NULL)
           {
            destination_list[place] = EventIDs[c][d];
            place++;
           }
     }
     
   ArrayResize(destination_list,c+d+1);

  }
//+------------------------------------------------------------------+
//|               Get list of News Events Names in the API           |
//+------------------------------------------------------------------+
void CJBNews::eventList(string & destination_list[])
  {
   ArrayResize(destination_list,5000);
   place = 0;

   for(c = 0; c < 8; c++)
     {
      for(d = 0; d < 60; d++){
         if(EventNames[c][d] !=  NULL)
           {
            destination_list[place] = EventNames[c][d];
            place++;
           }
       }
     }
   
   ArrayResize(destination_list,c+d+1);

  }
//+------------------------------------------------------------------+
//|            Load the Event Info for the specified Event ID        |
//+------------------------------------------------------------------+
bool CJBNews::load(long eventID)
  {
  
  ArrayResize(info.eventHistory,250);
  info.eventCount = 0;
  
   for(a = 0; a < 8; a++)
      for(l = 0; l < 60; l++)
         if(EventIDs[a][l] == eventID)
           {

            info.name = EventNames[a][l];
            info.currency = EventCurrencies[a];
            info.eventID = EventIDs[a][l];
            info.category = EventCategories[a][l];
            
            for(hist = 0; hist < 250; hist++)
              {
               if((EventHistory[a][l][hist][0]) != "")
                 {
                  info.eventCount++;

                  info.eventHistory[hist].name = EventHistory[a][l][hist][0];
                  info.eventHistory[hist].currency = EventHistory[a][l][hist][1];
                  info.eventHistory[hist].eventID = long(EventHistory[a][l][hist][2]);
                  info.eventHistory[hist].category = EventHistory[a][l][hist][3];
                  info.eventHistory[hist].date = datetime(EventHistory[a][l][hist][4]);
                  info.eventHistory[hist].actual = double(EventHistory[a][l][hist][5]);
                  info.eventHistory[hist].forecast = double(EventHistory[a][l][hist][6]);
                  info.eventHistory[hist].previous = double(EventHistory[a][l][hist][7]);
                  info.eventHistory[hist].outcome = EventHistory[a][l][hist][8];
                  info.eventHistory[hist].strength = EventHistory[a][l][hist][9];
                  info.eventHistory[hist].quality = EventHistory[a][l][hist][10];
                 }
              }

            for(k = 0; k < 14; k++)
              {
               info.machineLearning[k][0] = MachineLearning[a][l][k][0];
               info.machineLearning[k][1] = MachineLearning[a][l][k][1];
               info.machineLearning[k][2] = MachineLearning[a][l][k][2];
               info.machineLearning[k][3] = MachineLearning[a][l][k][3];
               info.machineLearning[k][4] = MachineLearning[a][l][k][4];
               info.machineLearning[k][5] = MachineLearning[a][l][k][5];
               info.machineLearning[k][6] = MachineLearning[a][l][k][6];
               info.machineLearning[k][7] = MachineLearning[a][l][k][7];
               info.machineLearning[k][8] = MachineLearning[a][l][k][8];
               info.machineLearning[k][9] = MachineLearning[a][l][k][9];
              }

            for(b = 0; b < 14; b++)
              {
               info.smartAnalysis[b][0] = SmartAnalysis[a][l][b][0];
               info.smartAnalysis[b][1] = SmartAnalysis[a][l][b][1];
              }
            ArrayResize(info.eventHistory,info.eventCount);
            return true;
           }
   ArrayResize(info.eventHistory,info.eventCount);
   return false;
  }
//+------------------------------------------------------------------+
//|            Connect to API and Parse the Data                     |
//+------------------------------------------------------------------+
bool CJBNews::get()
  {
   if(StringLen(api_key)<30)
      return false;

   bytesRead = 0;
   result = "";
   static const string url = "https://www.jblanked.com/news/api/full-list/";
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
      JSON.Deserialize(result, CP_UTF8); // deserialize into JSON format


      //--- Setting USD events
      USD = JSON["USD"];

      total_usd = USD["Total"].ToInt();

      if(total_usd == 0)
         return false;

      json_set(USD,total_usd,0);

      //--- Setting EUR events
      EUR = JSON["EUR"];
      total_eur = EUR["Total"].ToInt();
      json_set(EUR,total_eur,1);

      //--- Setting GBP events
      GBP = JSON["GBP"];
      total_gbp = GBP["Total"].ToInt();
      json_set(GBP, total_gbp, 2);

      //--- Setting JPY events
      JPY = JSON["JPY"];
      total_jpy = JPY["Total"].ToInt();
      json_set(JPY, total_jpy, 3);

      //--- Setting AUD events
      AUD = JSON["AUD"];
      total_aud = AUD["Total"].ToInt();
      json_set(AUD, total_aud, 4);

      //--- Setting CAD events
      CAD = JSON["CAD"];
      total_cad = CAD["Total"].ToInt();
      json_set(CAD, total_cad, 5);

      //--- Setting CHF events
      CHF = JSON["CHF"];
      total_chf = CHF["Total"].ToInt();
      json_set(CHF, total_chf, 6);

      //--- Setting NZD events
      NZD = JSON["NZD"];
      total_nzd = NZD["Total"].ToInt();
      json_set(NZD, total_nzd, 7);

      eventList(eventNames);
      eventList(eventIDs);



      return true;
     }
   else
     {
      return false;
     }
  }
//+------------------------------------------------------------------+
//|                   Parse by Currency                              |
//+------------------------------------------------------------------+
void CJBNews::json_set(CJAVal & Currency, long event_total, int currency)
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


   for(evnt = 0; evnt < (int)event_total; evnt++)
     {
      EventTemp = Currency["Events"][evnt];
      EventNames[currency][evnt] = EventTemp["Name"].ToStr();
      EventIDs[currency][evnt] = EventTemp["Event_ID"].ToInt();
      EventCategories[currency][evnt] = EventTemp["Category"].ToStr();

      switch(currency)
        {
         case 0:
            EventCurrencies[currency] = "USD";
            break;
         case 1:
            EventCurrencies[currency] = "EUR";
            break;
         case 2:
            EventCurrencies[currency] = "GBP";
            break;
         case 3:
            EventCurrencies[currency] = "JPY";
            break;
         case 4:
            EventCurrencies[currency] = "AUD";
            break;
         case 5:
            EventCurrencies[currency] = "CAD";
            break;
         case 6:
            EventCurrencies[currency] = "CHF";
            break;
         case 7:
            EventCurrencies[currency] = "NZD";
            break;
        }

      //--- Event History
      HistTemp = EventTemp["History"];

      for(hist = 0; hist < 250; hist++)
        {
         Hist2Temp = HistTemp[hist];

         if(Hist2Temp["Date"].ToStr() != "")
           {

            EventHistory[currency][evnt][hist][0] = EventNames[currency][evnt];
            EventHistory[currency][evnt][hist][1] = EventTemp["Currency"].ToStr();
            EventHistory[currency][evnt][hist][2] = string(EventIDs[currency][evnt]);
            EventHistory[currency][evnt][hist][3] = EventCategories[currency][evnt];
            EventHistory[currency][evnt][hist][4] = TimeToString(ChangeTime(StringToTime(Hist2Temp["Date"].ToStr()),offset));
            EventHistory[currency][evnt][hist][5] = Hist2Temp["Actual"].ToStr();
            EventHistory[currency][evnt][hist][6] = Hist2Temp["Forecast"].ToStr();
            EventHistory[currency][evnt][hist][7] = Hist2Temp["Previous"].ToStr();
            EventHistory[currency][evnt][hist][8] = Hist2Temp["Outcome"].ToStr();
            EventHistory[currency][evnt][hist][9] = Hist2Temp["Strength"].ToStr();
            EventHistory[currency][evnt][hist][10] = Hist2Temp["Quality"].ToStr();

           }
         else
            break;
        }

      //--- Machine Learning
      MLTemp = EventTemp["MachineLearning"];

      for(k = 1; k <= 13; k++)
        {
         MachineLearning[currency][evnt][k-1][0] = patterns[k-1];
         MachineLearning[currency][evnt][k-1][1] = MLTemp["Outcomes"][patterns[k-1]]["1 Minute"]["Bullish"].ToStr();
         MachineLearning[currency][evnt][k-1][2] = MLTemp["Outcomes"][patterns[k-1]]["1 Minute"]["Bearish"].ToStr();
         MachineLearning[currency][evnt][k-1][3] = MLTemp["Outcomes"][patterns[k-1]]["30 Minute"]["Bullish"].ToStr();
         MachineLearning[currency][evnt][k-1][4] = MLTemp["Outcomes"][patterns[k-1]]["30 Minute"]["Bearish"].ToStr();
         MachineLearning[currency][evnt][k-1][5] = MLTemp["Outcomes"][patterns[k-1]]["1 Hour"]["Bullish"].ToStr();
         MachineLearning[currency][evnt][k-1][6] = MLTemp["Outcomes"][patterns[k-1]]["1 Hour"]["Bearish"].ToStr();
         MachineLearning[currency][evnt][k-1][7] = MLTemp["1 Minute Accuracy"].ToStr();
         MachineLearning[currency][evnt][k-1][8] = MLTemp["30 Minute Accuracy"].ToStr();
         MachineLearning[currency][evnt][k-1][9] = MLTemp["1 Hour Accuracy"].ToStr();
        }

      //--- Auto Smart Analysis
      SATemp = EventTemp["SmartAnalysis"];

      SmartAnalysis[currency][evnt][0][0] = "Actual > Forecast > Previous";
      SmartAnalysis[currency][evnt][1][0] = "Actual > Forecast Forecast < Previous";
      SmartAnalysis[currency][evnt][2][0] = "Actual > Forecast Actual < Previous";
      SmartAnalysis[currency][evnt][3][0] = "Actual > Forecast Forecast = Previous";
      SmartAnalysis[currency][evnt][4][0] = "Actual > Forecast Actual = Previous";
      SmartAnalysis[currency][evnt][5][0] = "Actual < Forecast Forecast > Previous";
      SmartAnalysis[currency][evnt][6][0] = "Actual < Forecast < Previous";
      SmartAnalysis[currency][evnt][7][0] = "Actual < Forecast Actual > Previous";
      SmartAnalysis[currency][evnt][8][0] = "Actual < Forecast = Previous";
      SmartAnalysis[currency][evnt][9][0] = "Actual = Forecast = Previous";
      SmartAnalysis[currency][evnt][10][0] = "Actual = Forecast > Previous";
      SmartAnalysis[currency][evnt][11][0] = "Actual = Forecast < Previous";
      SmartAnalysis[currency][evnt][12][0] = "Actual < Forecast Actual = Previous";

      SmartAnalysis[currency][evnt][0][1] = SATemp["Actual > Forecast > Previous"].ToStr();
      SmartAnalysis[currency][evnt][1][1] = SATemp["Actual > Forecast Forecast < Previous"].ToStr();
      SmartAnalysis[currency][evnt][2][1] = SATemp["Actual > Forecast Actual < Previous"].ToStr();
      SmartAnalysis[currency][evnt][3][1] = SATemp["Actual > Forecast Forecast = Previous"].ToStr();
      SmartAnalysis[currency][evnt][4][1] = SATemp["Actual > Forecast Actual = Previous"].ToStr();
      SmartAnalysis[currency][evnt][5][1] = SATemp["Actual < Forecast Forecast > Previous"].ToStr();
      SmartAnalysis[currency][evnt][6][1] = SATemp["Actual < Forecast < Previous"].ToStr();
      SmartAnalysis[currency][evnt][7][1] = SATemp["Actual < Forecast Actual > Previous"].ToStr();
      SmartAnalysis[currency][evnt][8][1] = SATemp["Actual < Forecast = Previous"].ToStr();
      SmartAnalysis[currency][evnt][9][1] = SATemp["Actual = Forecast = Previous"].ToStr();
      SmartAnalysis[currency][evnt][10][1] = SATemp["Actual = Forecast > Previous"].ToStr();
      SmartAnalysis[currency][evnt][11][1] = SATemp["Actual = Forecast < Previous"].ToStr();
      SmartAnalysis[currency][evnt][12][1] = SATemp["Actual < Forecast Actual = Previous"].ToStr();

     }


  }
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

    if (increase < 24)
        date.hour = increase;
    else {
        date.day += increase / 24;  // Increment days by the number of complete days in 'increase'
        date.hour = increase % 24;  // Set hour to the remainder

        // Check and update the month and year if needed
        while (date.day > amountOfDays(date.mon, date.year)) {
            date.day -= amountOfDays(date.mon, date.year);
            date.mon++;

            if (date.mon > 12) {
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
int CJBNews::amountOfDays(int current_month, int year)
{
   int amount = 0;
   
   switch(current_month)
   {
      case 2: amount = year % 4 == 0 ? 28 : 29; break;
      
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