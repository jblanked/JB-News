//+------------------------------------------------------------------+
//|                                            JB-News-Scheduler.mq5 |
//|                                     Copyright 2024-2026,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2026,JBlanked"
#property link      "https://www.jblanked.com/"
#property version   "1.03"
#property description "Visualize news events or use it in an expert advisor"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

#property indicator_label1 "Event ID"
#property indicator_color1 clrNONE
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID
#property indicator_type1  DRAW_NONE

#property indicator_label2 "Actual"
#property indicator_color2 clrNONE
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
#property indicator_type2  DRAW_NONE

#property indicator_label3 "Forecast"
#property indicator_color3 clrNONE
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID
#property indicator_type3  DRAW_NONE

#property indicator_label4 "Previous"
#property indicator_color4 clrNONE
#property indicator_width4 1
#property indicator_style4 STYLE_SOLID
#property indicator_type4  DRAW_NONE

#define INDICATOR_NAME "JB-News-Scheduler"
#define TIMER 60

#include <jb-news\\news.mqh>

input  string           inpApiKey     = "API-KEY";        // API Key
input  ENUM_NEWS_SOURCE inpNewsSource = NEWS_SOURCE_MQL5; // News Source
input  int              inpOffset     = 0;                // Offset

CJBNews *jb;
int amountOfEvents;
double bufferEventID[];
double bufferActual[];
double bufferForecast[];
double bufferPrevious[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("[OnInit]: Initializing...");
   jb = new CJBNews();
//---
   SetIndexBuffer(0, bufferEventID, INDICATOR_DATA);
   SetIndexBuffer(1, bufferActual, INDICATOR_DATA);
   SetIndexBuffer(2, bufferForecast, INDICATOR_DATA);
   SetIndexBuffer(3, bufferPrevious, INDICATOR_DATA);
//---
   ObjectsDeleteAll(0, "CJBNews-");
   IndicatorSetString(INDICATOR_SHORTNAME, INDICATOR_NAME);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   ChartSetInteger(0, CHART_SHOW_VOLUMES, false);
//---
   if(StringLen(inpApiKey) < 30)
   {
      Alert("[OnInit]: Invalid API Key!");
      ChartIndicatorDelete(ChartID(), 0, INDICATOR_NAME);
      return INIT_FAILED;
   }
//---
   Print("[OnInit]: Fetching calendar...");
//---
   jb.api_key = inpApiKey;
   jb.offset  = inpOffset;
//---
   if(jb.chart(inpNewsSource))
   {
      amountOfEvents = ArraySize(jb.calenderInfo);
      Print("[OnInit]: Calendar fetched! " + string(amountOfEvents) + " events available");
      bool set = EventSetTimer(TIMER);
      while(!set)
      {
         set = EventSetTimer(TIMER);
         Sleep(1000);
      }
      return INIT_SUCCEEDED;
   }
//---
   Print("[OnInit]: Failed to fetch calendar data...");
   return INIT_FAILED;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit = rates_total - prev_calculated;
   if(prev_calculated < 1)
   {
      ArraySetAsSeries(bufferEventID, true);
      ArraySetAsSeries(bufferActual, true);
      ArraySetAsSeries(bufferForecast, true);
      ArraySetAsSeries(bufferPrevious, true);

      ArrayInitialize(bufferEventID, EMPTY_VALUE);
      ArrayInitialize(bufferActual, EMPTY_VALUE);
      ArrayInitialize(bufferForecast, EMPTY_VALUE);
      ArrayInitialize(bufferPrevious, EMPTY_VALUE);
   }
   else
   {
      limit++;
   }

   for(int i = limit - 1; i >= 0; i--)
   {
      for(int j = 0; j < amountOfEvents; j++)
      {
         if(jb.calenderInfo[j].date == iTime(_Symbol, PERIOD_CURRENT, i))
         {
            bufferEventID[i] = (double)jb.calenderInfo[j].id;
            bufferActual[i] = (double)jb.calenderInfo[j].actual;
            bufferForecast[i] = (double)jb.calenderInfo[j].forecast;
            bufferPrevious[i] = (double)jb.calenderInfo[j].previous;
         }
      }
   }

   return(rates_total); // return value of prev_calculated for next call
}
//+------------------------------------------------------------------+
//| Custom indicator deinit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, "CJBNews-");

   if(CheckPointer(jb) == POINTER_DYNAMIC)
   {
      delete jb;
      jb = NULL;
   }
}
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
//--- only refresh when its the time of a news event
//--- since TIMER is 60, this should refresh every minute at a news event time
//--- sometimes it takes mql5 2-to-3 minutes to update their data
   amountOfEvents = ArraySize(jb.calenderInfo);
   for(int j = 0; j < amountOfEvents; j++)
   {
      if(jb.calenderInfo[j].date == iTime(_Symbol, PERIOD_M5, 0))
      {
         if(!jb.chart(inpNewsSource))
         {
            Print("[OnTimer]: Failed to update chart data...");
         }
         else
         {
            Print("[OnTimer]: Calendar fetched! " + string(ArraySize(jb.calenderInfo)) + " events available");
         }
         break;
      }
   }
}
//+------------------------------------------------------------------+
