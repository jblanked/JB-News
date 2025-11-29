//+------------------------------------------------------------------+
//|                                                  JB-News-Bot.mq5 |
//|                                 Copyright 2024-2025,JBlanked LLC |
//|                          https://www.jblanked.com/trading-tools/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024-2025,JBlanked LLC"
#property link      "https://www.jblanked.com/trading-tools/"
#property version   "1.01"
#property description "An MT4 and MT5 expert advisor that trades using JBlanked's NewsAPI"
#property strict

//--- defines
#define TIMER 60
#define IS_TESTING bool(MQLInfoInteger(MQL_OPTIMIZATION)) || bool(MQLInfoInteger(MQL_TESTER))

#ifdef __MQL5__
#define Ask SymbolInfoDouble(_Symbol,SYMBOL_ASK)
#define Bid SymbolInfoDouble(_Symbol,SYMBOL_BID)
#endif

//--- includes
#include <jb-news/news.mqh>

#ifdef __MQL5__
#include <trade/trade.mqh>
#endif

//--- inputs
#ifdef __MQL5__
input  group "News Settings"
#else
input  string           inpNews       = "====News Settings===="; //------------------->
#endif
sinput string           inpApiKey     = "API-KEY";        // API Key
input  ENUM_NEWS_SOURCE inpNewsSource = NEWS_SOURCE_MQL5; // News Source
input  int              inpOffset     = 0;                // Offset

#ifdef __MQL5__
input  group "Trade Settings"
#else
input  string            inpTrade      = "====Trade Settings===="; //------------------->
#endif
input ENUM_CURRENCY      inpCurrency   = USD;                                          // News Currency
input ENUM_NEWS_EVENTS   inpNewsEvent  = Core_CPI_monthly;                             // News Event
input ENUM_NEWS_STRATEGY inpBuyStrat   = actual_more_than_forecast_equal_to_previous;  // Buy Strategy
input ENUM_NEWS_STRATEGY inpSellStrat  = actual_less_than_forecast_equal_to_previous;  // Sell Strategy
input  double            inpLotSize    = 0.10;                                         // Lot size
input  double            inpTakeProfit = 100.00;                                       // Take Profit (Points)
input  double            inpStopLoss   = 50.00;                                        // Stop Loss (Points)
sinput string            inpComment    = "JB-News-Bot";                                // Order Comment
sinput long              inpMagic      = 124211;                                       // Magic Number

//--- globals
CJBNews *news;
NewsHistoryModel currentNews;
int amountOfEvents;

#ifdef __MQL5__
CTrade trade;
#endif
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   Print("[OnInit]: Initializing...");
   news = new CJBNews();
//---
   if(StringLen(inpApiKey) < 30)
   {
      Alert("[OnInit]: Invalid API Key!");
      ExpertRemove();
      return INIT_FAILED;
   }
//---
   Print("[OnInit]: Fetching data...");
   news.api_key = inpApiKey;
   news.offset  = inpOffset;
//--- get data from today (if not testing) otherthis this year's data'
   if(!news.calendar(IS_TESTING ? NEWS_FREQUENCY_YEAR : NEWS_FREQUENCY_TODAY, inpNewsSource))
   {
      Print("[OnInit]: Failed to fetch calendar data...");
      ExpertRemove();
      return INIT_FAILED;
   }
   amountOfEvents = ArraySize(news.calenderInfo);
   Print("[OnInit]: Data fetched! " + string(amountOfEvents) + " events available");
//---
   bool set = EventSetTimer(TIMER);
   while(!set)
   {
      set = EventSetTimer(TIMER);
      Sleep(1000);
   }
//---
#ifdef __MQL5__
   trade.SetExpertMagicNumber(inpMagic);
   trade.SetDeviationInPoints(10);
#endif
//---
   Print("[OnInit]: Initialized successfully!!");
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   if(CheckPointer(news) == POINTER_DYNAMIC)
   {
      delete news;
      news = NULL;
   }
//---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//--- check if orders are open
#ifdef __MQL5__
   if(PositionsTotal() > 0) return;
#else
   if(OrdersTotal() > 0) return;
#endif
//--- set current time
   const datetime timeCurrent = iTime(_Symbol, PERIOD_M5, 0);
//--- only check once per 5 minute candle
   static datetime lastChecked = 0;
   if(lastChecked == timeCurrent)
   {
      return;
   }
   lastChecked = timeCurrent;
//--- check if it's a news event time
   if(!isNewsEventTime(timeCurrent)) return;
//--- check if its our news currency
   if(inpCurrency != currentNews.currency) return;
//--- check if it's our news event
   if(NewsEventToString(inpNewsEvent) != currentNews.name) return;
//--- check if data is loaded
   if(currentNews.outcome == data_not_loaded) return;
//--- trade if outcome matches
   const ENUM_NEWS_STRATEGY outcome = currentNews.outcome;
   if(outcome == inpBuyStrat)
   {
      const double stopLoss   = Ask - inpStopLoss * _Point;
      const double takeProfit = Ask + inpTakeProfit * _Point;
      //--- buy
#ifdef __MQL5__
      if(!trade.PositionOpen(_Symbol, ORDER_TYPE_BUY, inpLotSize, Ask, stopLoss, takeProfit, inpComment))
      {
         Print("Failed to open buy trade!");
      }
#else
      const int ticket = OrderSend(_Symbol, OP_BUY, inpLotSize, Ask, 10, stopLoss, takeProfit, inpComment, (int)inpMagic);
      if(ticket == -1)
      {
         Print("Failed to open buy trade!");
      }
#endif
   }
   else if(outcome == inpSellStrat)
   {
      const double stopLoss   = Bid + inpStopLoss * _Point;
      const double takeProfit = Bid - inpTakeProfit * _Point;
      //--- sell
#ifdef __MQL5__
      if(!trade.PositionOpen(_Symbol, ORDER_TYPE_SELL, inpLotSize, Bid, stopLoss, takeProfit, inpComment))
      {
         Print("Failed to open sell trade!");
      }
#else
      const int ticket = OrderSend(_Symbol, OP_SELL, inpLotSize, Bid, 10, stopLoss, takeProfit, inpComment, (int)inpMagic);
      if(ticket == -1)
      {
         Print("Failed to open sell trade!");
      }
#endif
   }
//---
}
//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
   if(IS_TESTING) return;
//--- only refresh when its the time of a news event
//--- since TIMER is 60, this should refresh every minute at a news event time
//--- sometimes it takes mql5 2-to-3 minutes to update their data
   amountOfEvents = ArraySize(news.calenderInfo);
   if(isNewsEventTime(iTime(_Symbol, PERIOD_M5, 0)))
   {
      if(!news.calendar(IS_TESTING ? NEWS_FREQUENCY_YEAR : NEWS_FREQUENCY_TODAY, inpNewsSource))
      {
         Print("[OnTimer]: Failed to update news data...");
      }
      else
      {
         amountOfEvents = ArraySize(news.calenderInfo);
         Print("[OnTimer]: Data fetched! " + string(amountOfEvents) + " events available");
      }
   }
}
//+------------------------------------------------------------------+
//| Custom function that returns true if it's a news event time      |
//+------------------------------------------------------------------+
bool isNewsEventTime(datetime currentTime = 0)
{
   amountOfEvents = ArraySize(news.calenderInfo);
   for(int j = 0; j < amountOfEvents; j++)
   {
      if(news.calenderInfo[j].isEventTime(currentTime))
      {
         currentNews = news.calenderInfo[j];
         return true;
      }
   }
   return false;
}
//+------------------------------------------------------------------+
