//+------------------------------------------------------------------+
//|                                                 News-Library.mqh |
//|                                          Copyright 2023,JBlanked |
//|                          https://www.jblanked.com/news/api/docs/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,JBlanked"
#property link      "https://www.jblanked.com/news/api/docs/"
#property description "Access JBlanked's News Library that includes Machine Learning, Auto Smart Analysis, and Event History information."

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
   
#define INTERNET_OPTION_SECURITY_FLAGS 31
#define SECURITY_FLAG_IGNORE_REVOCATION 32
#define INTERNET_OPTION_IGNORE_OFFLINE 37
#define INTERNET_OPEN_TYPE_DIRECT 1
#define INTERNET_FLAG_RELOAD 0x80000000
#define INTERNET_FLAG_NO_CACHE_WRITE 0x04000000
#define INTERNET_FLAG_PRAGMA_NOCACHE 0x00000100
#define INTERNET_FLAG_NO_UI 0x00000200
#define INTERNET_FLAG_RAW_DATA 0x40000000
#define INTERNET_FLAG_KEEP_CONNECTION 0x00400000
#define INTERNET_FLAG_SECURE 0x00800000
#define INTERNET_FLAG_IGNORE_CERT_CN_INVALID 0x00001000
#define INTERNET_FLAG_IGNORE_CERT_DATE_INVALID 0x00002000
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTP 0x00008000
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS 0x00004000
#define INTERNET_FLAG_IGNORE_REDIRECT_TO_HTTPS_ 0x00010000
#define INTERNET_FLAG_OFFLINE 0x01000000
#define INTERNET_FLAG_SECURE_SCHANNEL 0x00004000
#define INTERNET_FLAG_TRANSFER_ASCII 0x00000001
#define INTERNET_FLAG_TRANSFER_BINARY 0x00000002
#define INTERNET_ERROR_BASE 12000
#define INTERNET_ERROR_LAST (INTERNET_ERROR_BASE + 2000)

#define HTTP_QUERY_FLAG_NUMBER 0x20000000
#define HTTP_QUERY_STATUS_CODE 19
#define HTTP_QUERY_FLAG_NUMBER64 0x2000000000000000
#define HTTP_QUERY_RAW_HEADERS 21
#define HTTP_STATUS_DENIED 401
#define HTTP_STATUS_PROXY_AUTH_REQ 407
#import

/*
   Example use:
   
   #include <JB-News.mqh>

   CJBNews jb;
   const string api_key = "Your-API-Key"; // API key
   const long eventID = 756020001; // Event ID
   
   int OnInit()  
   {
   
      if(jb.start(api_key) && jb.load(756020001)){
         EventSetTimer(300);
         return INIT_SUCCEEDED;
         }
      else
         return INIT_FAILED;
   }
   
   void OnTimer() // refresh API every 5 minutes
   {
      if(!jb.start(api_key))
      {
      Alert("Failed to refresh data");
      ExpertRemove();
      }
      else
      {
       jb.load(756020001);
      }
   }
   
   void OnTick()
   {
      for(int i = 0; i < 250; i++){ // loop through event history
         const string event_date = jb.info.eventHistory[i][0];
         if(jb.info.isEventTime(event_date,TimeCurrent())) // if current time is event time
         {
         // Execute Code Here
         }
      }
   }
   
   

*/

#include <jason_with_search.mqh> // JSON library
enum enum_list_choice{ENUM_NAMES,ENUM_IDS}; // enum for eventList function
enum enum_news_trend{ENUM_BULL,ENUM_BEAR,ENUM_NEUTRAL};
 
class CJBNews
{
   private:
      uchar buffer[1024]; 
      int bytesRead;
      string result;
      int evnt;
      int k;
      int hist;
      int l;
      int a;
      int b;
      int c;
      int d;
      int place;
      CJAVal JSON;
      CJAVal NZD,USD,CAD,AUD,EUR,CHF,GBP,JPY;
      double act,forc,prev;
      CJAVal EventTemp,HistTemp, Hist2Temp, MLTemp, SATemp;
      long total_events, total_usd, total_eur, total_nzd, total_gbp, total_chf, total_jpy, total_aud, total_cad;
      string EventHistory[8][60][250][4];
      string MachineLearning[8][60][14][10];
      string SmartAnalysis[8][60][14][2];
      string EventNames[8][60];
      string EventCurrencies[8];
      long EventIDs[8][60];
      void json_set(CJAVal & Currency, long event_total, int currency);

   public:
      bool start(const string api_key);
      bool load(const long eventID);
      void eventList(string & destination_list[], const enum_list_choice names_or_ids = ENUM_IDS);
       
      
      // structure to hold all of the event information
      struct EventInfo
      {
         private:
            double division(double numerator,double denominator){return denominator == 0 ? 0 : numerator / denominator;}
         public:
            enum_news_trend trendML(const string outcome);
            enum_news_trend trendSA(const string outcome);
            string outcome(const string actual, const string forecast, const string previous);
            bool isEventTime(string eventTime,const datetime currentTime){return (datetime)eventTime == currentTime;}
            string name;
            string currency;
            long eventID;
            string eventHistory[250][4];
            string machineLearning[14][10];
            string smartAnalysis[14][2];
      };
      
      EventInfo info;  // holds the event info after loading
};
//+------------------------------------------------------------------+
//|       Get the Machine Learning Trend based upon the outcome      |
//+------------------------------------------------------------------+
enum_news_trend CJBNews::EventInfo::trendML(const string outcome)
{ 
   for(int q = 0; q < 13; q++)
      if(machineLearning[q][0] == outcome){
         const double bullish = division((double)machineLearning[q][1] + (double)machineLearning[q][3] + (double)machineLearning[q][5],3);
         const double bearish = division((double)machineLearning[q][2] + (double)machineLearning[q][4] + (double)machineLearning[q][6],3);  
         const double accuracy = division((double)machineLearning[q][7] + (double)machineLearning[q][8] + (double)machineLearning[q][9],3) * 100; 
         if(accuracy>50){ 
         if(bullish>bearish) return ENUM_BULL;
         else return ENUM_BEAR;
         }
         else return ENUM_BEAR;
      }
      else return ENUM_BEAR;
            
   return ENUM_NEUTRAL;
}
//+------------------------------------------------------------------+
//|       Get the Smart Analysis Trend based upon the outcome        |
//+------------------------------------------------------------------+
enum_news_trend CJBNews::EventInfo::trendSA(const string outcome)
{
   
   for(int q = 0; q < 13; q++)
      if(smartAnalysis[q][0] == outcome){
         if(smartAnalysis[q][1] == "Bullish")
            return ENUM_BULL;
         else if(smartAnalysis[q][1] == "Bearish")
            return ENUM_BEAR;
         else
            return ENUM_NEUTRAL;
      }
            
   return ENUM_NEUTRAL;
}
//+------------------------------------------------------------------+
//|                     Get the outcome                              |
//+------------------------------------------------------------------+
string CJBNews::EventInfo::outcome(const string actual, const string forecast, const string previous)
{
   const string patterns[13] = {
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
      
   if(actual > forecast && forecast > previous)
      return patterns[0];
   else if(actual > forecast && forecast < previous && actual > previous)
      return patterns[1];
   else if(actual > forecast && actual < previous)
      return patterns[2]; 
   else if(actual > forecast && forecast == previous)
      return patterns[3];       
   else if(actual > forecast && actual == previous)
      return patterns[4];
      
   else if(actual < forecast && forecast < previous)
      return patterns[5];
   else if(actual < forecast && forecast > previous && actual < previous)
      return patterns[6];
   else if(actual < forecast && actual > previous)
      return patterns[7]; 
   else if(actual < forecast && forecast == previous)
      return patterns[8];
   else if(actual < forecast && actual == previous)
      return patterns[9]; 
            
   else if(actual == forecast && actual == previous)
      return patterns[10];
   else if(actual == forecast && forecast > previous)
      return patterns[11];
   else if(actual == forecast && forecast < previous)
      return patterns[12];  
   
   else return "Data Not Loaded";
         
}
//+------------------------------------------------------------------+
//|                 Get list of News Events in the API               |
//+------------------------------------------------------------------+
void CJBNews::eventList(string & destination_list[], enum_list_choice names_or_ids)
{
   ZeroMemory(destination_list);
   place = 0;
   
   
   switch(names_or_ids)
   {
      case ENUM_NAMES:
         for(c = 0; c < 8; c++){
            for(d = 0; d < 60; d++)
               if(EventNames[c][d] !=  NULL)
               {
               ArrayResize(destination_list,destination_list.Size()+1);
               destination_list[place] = EventNames[c][d];
               place++;
               }
            }
          break;
          
       default:
         for(c = 0; c < 8; c++){
            for(d = 0; d < 60; d++)
               if((string)EventIDs[c][d] !=  "0")
               {
               ArrayResize(destination_list,destination_list.Size()+1);
               destination_list[place] = (string)EventIDs[c][d];
               place++;
               }
            }
          break;     
   }
}

//+------------------------------------------------------------------+
//|            Load the Event Info for the specified Event ID        |
//+------------------------------------------------------------------+
bool CJBNews::load(long eventID)
{
   for(a = 0; l < 8; a++)
      for(l = 0; l < 60; l++)
         if(EventIDs[a][l] == eventID)
            {
            info.name = EventNames[a][l];
            info.currency = EventCurrencies[a];
            info.eventID = EventIDs[a][l];
           
            
            for(hist = 0; hist < 250; hist++){
               if(int(EventHistory[a][l][hist][1]) != 0)
               {
               info.eventHistory[hist][0] = EventHistory[a][l][hist][0];
               info.eventHistory[hist][1] = EventHistory[a][l][hist][1];
               info.eventHistory[hist][2] = EventHistory[a][l][hist][2];
               info.eventHistory[hist][3] = EventHistory[a][l][hist][3];
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
               
            
            return true;
            }
            
    return false;
}
//+------------------------------------------------------------------+
//|            Connect to API and Parse the Data                     |
//+------------------------------------------------------------------+
bool CJBNews::start(string api_key)
{
    bytesRead = 0;
    result = "";
    const string url = "https://www.jblanked.com/news/api/full-list/";
    const string headers = "Content-Type: application/json" + "\r\n" + "Authorization: Api-Key " + api_key; 

    // Initialize WinHTTP
    const int hInternet = InternetOpenW("MyApp", 1, NULL, NULL, 0);
    if (hInternet)
    {
        // Open a URL
        const int hUrl = InternetOpenUrlW(hInternet, url, NULL, 0, 0, 0);
        if (hUrl)
        {
                // Send the request headers
                if (HttpSendRequestW(hUrl, headers, StringLen(headers), buffer, 0))
                {
                    // Read the response
                    while (InternetReadFile(hUrl, buffer, ArraySize(buffer) - 1, bytesRead) && bytesRead > 0)
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
    
    if (result != "") {
        JSON.Deserialize(result, CP_UTF8); // deserialize into JSON format
                  
         //--- Setting USD events
         USD = JSON["USD"]; 
         total_usd = USD["Total"].ToInt(); 
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
void CJBNews::json_set(CJAVal & Currency, long event_total, int currency){
      
      const string patterns[13] = {
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
      
     
         for(evnt = 0; evnt < (int)event_total; evnt++){
            EventTemp = Currency["Events"][evnt];
            EventNames[currency][evnt] = EventTemp["Name"].ToStr();
            EventIDs[currency][evnt] = EventTemp["Event_ID"].ToInt();
            
            switch(currency)
            {
               case 0: EventCurrencies[currency] = "USD"; break;
               case 1: EventCurrencies[currency] = "EUR"; break;
               case 2: EventCurrencies[currency] = "GBP"; break;
               case 3: EventCurrencies[currency] = "JPY"; break;
               case 4: EventCurrencies[currency] = "AUD"; break;
               case 5: EventCurrencies[currency] = "CAD"; break;
               case 6: EventCurrencies[currency] = "CHF"; break;
               case 7: EventCurrencies[currency] = "NZD"; break;
            }
             
            //--- Event History
            HistTemp = EventTemp["History"];
          
                      
               for(hist = 0; hist < 250; hist++){
                  Hist2Temp = HistTemp[hist];
                     if(Hist2Temp["Date"].ToInt() != 0){
                     EventHistory[currency][evnt][hist][0] = Hist2Temp["Date"].ToStr();
                     EventHistory[currency][evnt][hist][1] = Hist2Temp["Actual"].ToStr();  
                     EventHistory[currency][evnt][hist][2] = Hist2Temp["Forecast"].ToStr();
                     EventHistory[currency][evnt][hist][3] = Hist2Temp["Previous"].ToStr(); 
                     
                     }
                     else break;
                }
            
            //--- Machine Learning
            MLTemp = EventTemp["MachineLearning"];
            
               for(k = 1; k <= 13; k++){
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