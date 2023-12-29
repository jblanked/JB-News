//+------------------------------------------------------------------+
//|                                                 News-Library.mqh |
//|                                          Copyright 2023,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,JBlanked"
#property link      "https://www.jblanked.com/"
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
   string empty[];
   
   int OnInit()  
   {
   
      if(jb.start("Your-API-Key")){
         if(jb.load(840040001)){
           
           Print("Name: " + jb.info.name);
           Print("Currency: " + jb.info.currency);
           Print("Event ID: " + (string)jb.info.eventID);
           
            return INIT_SUCCEEDED;
            }
         else
           {
            return INIT_FAILED;
           }
         
         }
      else
         return INIT_FAILED;
   }

*/

#include <jason_with_search.mqh> // JSON library
enum enum_list_choice{names,ids}; // enum for eventList function
 
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
      CJAVal EventTemp,HistTemp, Hist2Temp, MLTemp, SATemp;
      long total_events, total_usd, total_eur, total_nzd, total_gbp, total_chf, total_jpy, total_aud, total_cad;
      string EventHistory[8][60][250][4];
      string MachineLearning[8][60][14][10];
      string SmartAnalysis[8][60][14][2];
      string EventNames[8][60];
      string EventCurrencies[8];
      long EventIDs[8][60];
      void json_set(CJAVal & Currency, long event_total, int currency);
      
      struct EventInfo
      {
         string name;
         string currency;
         long eventID;
         string eventHistory[250][4];
         string machineLearning[14][10];
         string smartAnalysis[14][2];
      }; 
      
   public:
      bool start(string api_key);
      bool load(long eventID);
      void eventList(string & destination_list[], enum_list_choice names_or_ids);
      EventInfo info;  // holds the event info after loading
};
//+------------------------------------------------------------------+
//|                 Get list of News Events in the API               |
//+------------------------------------------------------------------+
void CJBNews::eventList(string & destination_list[], enum_list_choice names_or_ids)
{
   ZeroMemory(destination_list);
   place = 0;
   
   
   switch(names_or_ids)
   {
      case names:
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
       case ids:
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
      
      string patterns[13] = {
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