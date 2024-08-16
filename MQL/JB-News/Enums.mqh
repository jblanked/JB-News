//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                                          Copyright 2024,JBlanked |
//|                                        https://www.jblanked.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024,JBlanked"
#property link      "https://www.jblanked.com/"

enum ENUM_BULLISH_OR_BEARISH
  {
   ENUM_BEARISH = -1,   // Bearish
   ENUM_NEUTRAL = 0,    // Neutral
   ENUM_BULLISH = 1,    // Bullish
  };

enum ENUM_NEWS_SOURCE
  {
   MQL5_NEWS = 0,          // MQL5
   FOREX_FACTORY_NEWS = 1, // Forex Factory
  };


enum ENUM_NEWS_CATEGORY
  {
   Consumer_Inflation_Report = 0,   // Consumer Inflation
   Producer_Inflation_Report = 1,   // Producer Inflation
   Job_Inflation_Report = 2,        // Job Inflation
   Currency_Report = 3,             // Currency
   Core_Economy_Report = 4,         // Core Economy
   Economy_Report = 5,              // Economy
   Production_Report = 6,           // Production
   Job_Report = 7,                  // Job
   Commodity_Report = 8,            // Commodity
   Speech_Report = 9,               // Speech
   Interest_Rate_Report = 10,       // Interest Rate
   Survery_Report = 11,             // Survey
   No_Category = -1,                // None
  };

enum ENUM_NEWS_STRENGTH
  {
   Weak_Data = 0,    // Weak Data
   Strong_Data = 1,  // Strong Data
  };

enum ENUM_NEWS_QUALITY
  {
   Good_Data = 0,    // Good Data
   Bad_Data = 1,     // Bad Data
  };

enum ENUM_NEWS_STRATEGY
  {
   data_not_loaded = -1,                                       // Data Not Loaded
   actual_more_than_forecast_more_than_previous = 0,           // Actual > Forecast > Previous
   actual_more_than_forecast_less_than_previous = 1,           // Actual > Forecast, Forecast < Previous
   actual_more_than_forecast_and_actual_less_than_previous = 2,// Actual > Forecast, Actual < Previous
   actual_more_than_forecast_equal_to_previous = 3,            // Actual > Forecast, Forecast = Previous
   actual_more_than_forecast_and_actual_equal_to_previous = 4, // Actual > Forecast, Actual = Previous
   actual_less_than_forecast_and_previous = 5,                 // Actual < Forecast < Previous
   actual_less_than_forecast_more_than_previous = 6,           // Actual < Forecast, Forecast > Previous
   actual_less_than_forecast_and_actual_more_than_previous = 7,// Actual < Forecast, Actual > Previous
   actual_less_than_forecast_and_actual_equal_to_previous = 8, // Actual < Forecast, Actual = Previous
   actual_less_than_forecast_equal_to_previous = 9,            // Actual < Forecast, Forecast = Previous
   actual_equal_to_forecast_and_previous = 10,                 // Actual = Forecast = Previous
   actual_equal_to_forecast_less_than_previous = 11,           // Actual = Forecast, Forecast < Previous
   actual_equal_to_forecast_more_than_previous = 12,           // Actual = Forecast, Forecast > Previous
  };

enum ENUM_CURRENCY
  {
   USD = 0, // USD
   EUR = 1, // EUR
   GBP = 2, // GBP
   AUD = 3, // AUD
   NZD = 4, // NZD
   CHF = 5, // CHF
   JPY = 6, // JPY
   CAD = 7, // CAD
   CNY = 8, // CNY
  };

enum ENUM_NEWS_EVENTS
  {
   ADP_Nonfarm_Employment_Change = 32,                // ADP Non-Farm Employment Change
   Adjusted_Current_Account = 87,                     // Adjusted Current Account
   Adjusted_Trade_Balance = 86,                       // Adjusted Trade Balance
   au_Jibun_Bank_Composite_PMI = 114,                 // au Jibun Bank Composite PMI
   au_Jibun_Bank_Manufacturing_PMI = 112,             // au Jibun Bank Manufacturing PMI
   au_Jibun_Bank_Services_PMI = 113,                  // au Jibun Bank Services PMI
   Average_Hourly_Earnings_monthly = 0,               // Average Hourly Earnings m/m
   Average_Hourly_Earnings_yearly = -1,               // Average Hourly Earnings y/y
   Average_Weekly_Earnings_Total_Pay_yearly = 81,     // Average Weekly Earnings, Total Pay y/y
   Baker_Hughes_US_Oil_Rig_Count = 101,               // Baker Hughes US Oil Rig Count
   Baker_Hughes_US_Total_Rig_Count = 102,             // Baker Hughes US Oil Total Count
   BoC_Financial_System_Review_Press_Conference = 55, // BoC Financial System Review Press Conference
   BoC_Governor_Macklem_Speech = 53,                  // Gov. Macklem Speech (CAD)
   BoC_Interest_Rate_Decision = 51,                   // BoC Rate (CAD)
   BoC_Monetary_Policy_Report_Press_Conference = 52,  // BoC Monetary Policy Report Press Conference
   BoE_Governor_Bailey_Speech = 37,                   // Gov. Bailey Speech (GBP)
   BoE_Interest_Rate_Decision = 36,                   // BoE Rate (GBP)
   BoJ_Bank_Lending_yearly = 124,                     // BoJ Bank Lending y/y
   BoJ_Corporate_Goods_Price_Index_monthly = 125,     // BoJ Corporate Goods Price Index m/m
   BoJ_Corporate_Goods_Price_Index_yearly = 126,      // BoJ Corporate Goods Price Index y/y
   BoJ_Interest_Rate_Decision = 56,                   // BoJ Interest Rate Decision
   BoJ_M2_Money_Stock_yearly = 133,                   // BoJ M2 Money Stock y/y
   BoJ_Monetary_Base_yearly = 134,                    // BoJ Monetary Base y/y
   BoJ_Press_Conference = 57,                         // BoJ Press Conference
   BoJ_Tankan_Large_Manufacturing_Index = 60,         // BoJ Tankan Large Manufacturing Index
   BoJ_Tankan_Large_Non_Manufacturing_Index = 61,     // BoJ Tankan Large Non-Manufacturing Index
   BoJ_Weighted_Median_Core_CPI_yearly = 132,         // BoJ Weighted Median Core CPI y/y
   Budget_Release = 65,                               // Budget Release
   CB_Consumer_Confidence_Index = 78,                 // Consumer Confidence
   CAD_CPI = 55,                                      // CAD CPI
   Claimant_Count_Change = 70,                        // Claimant Count Change
   Composite_PMI = 129,                               // Composite PMI
   Core_CPI_monthly = 6,                              // Core CPI m/m
   Core_CPI_yearly = 7,                               // Core CPI y/y
   Core_Durable_Goods_Orders_monthly = 80,            // Core Durable Goods Orders m/m
   Core_Machinery_Orders_monthly = 122,               // Core Machinery Orders m/m
   Core_Machinery_Orders_yearly = 123,                // Core Machinery Orders y/y
   Core_PCE_Price_Index_monthly = 10,                 // Core PCE Price Index m/m
   Core_PPI_monthly = 2,                              // Core PPI m/m
   Core_PPI_Output_monthly = 42,                      // Core PPI Output m/m
   Core_PPI_Output_yearly = 43,                       // Core PPI Output y/y
   Core_PPI_yearly = 3,                               // Core PPI y/y
   Core_Retail_Sales_monthly = 31,                    // Core Retail Sales m/m
   CPI_monthly = 8,                                   // CPI m/m
   CPI_quarterly = 67,                                // CPI q/q
   CPI_yearly = 9,                                    // CPI y/y
   CPI_sa_monthly = 75,                               // CPI s.a. m/m
   Current_Account = 83,                              // Current Account
   Durable_Goods_Orders_monthly = 79,                 // Durable Goods Orders m/m
   EIA_Crude_Oil_Stocks_Change = 23,                  // Crude Oil Inventories
   EIA_Natural_Gas_Storage_Change = 25,               // Natural Gas Storage
   ECB_Deposit_Facility_Rate_Decision = 105,          // ECB Deposit Facility Rate Decision
   ECB_Interest_Rate_Decision = 49,                   // ECB Rate (EUR)
   ECB_Marginal_Lending_Facility_Rate_Decision = 106, // ECB Marginal Lending Facility Rate Decision
   ECB_President_Lagarde_Speech = 44,                 // Lagarde Speech (EUR)
   Employment_Change = 54,                            // Employment Change
   Employment_Change_quarterly = 71,                  // Employment Change q/q
   Electronic_Card_Retail_Sales_monthly = 84,         // Electronic Card Retail Sales m/m
   Electronic_Card_Retail_Sales_yearly = 85,          // Electronic Card Retail Sales y/y
   Existing_Home_Sales = 110,                         // Existing Home Sales
   Existing_Home_Sales_monthly = 111,                 // Existing Home Sales Monthly
   Export_Price_Index_monthly = 95,                   // Export Price Index m/m
   Export_Price_Index_yearly = 96,                    // Export Price Index y/y
   Factory_Orders_monthly = 89,                       // Factory Orders m/m
   Factory_Orders_yearly = 90,                        // Factory Orders y/y
   Federal_Budget_Balance = 139,                      // Federal Budget Balance
   Fed_Chair_Powell_Speech = 11,                      // Powell Speech
   Fed_Governor_Cook_Speech = 16,                     // Fed Cook Speech
   Fed_Governor_Jefferson_Speech = 12,                // Jefferson Speech
   Fed_Governor_Waller_Speech = 13,                   // Waller Speech
   Fed_Interest_Rate_Decision = 18,                   // Fed Rate
   Fed_Vice_Chair_for_Supervision_Barr_Speech = 14,   // Fed Barr Speech
   FOMC_Member_Williams_Speech = 15,                  // FOMC Williams Speech
   FOMC_Minutes = 17,                                 // FOMC Minutes
   FOMC_Press_Conference = 19,                        // FOMC Press Conference
   Foreign_Securities_Purchases = 109,                // Foreign Securities Purchases
   GDP_3m_3m = 104,                                   // GDP 3m/3m
   GDP_monthly = 34,                                  // GDP m/m
   GDP_quarterly = 33,                                // GDP q/q
   GDP_yearly = 35,                                   // GDP y/y
   HICP_monthly = 91,                                 // HICP m/m
   Household_Spending_monthly = 88,                   // Household Spending m/m
   Household_Spending_yearly = 88,                    // Household Spending y/y
   Import_Price_Index_monthly = 93,                   // Import Price Index m/m
   Import_Price_Index_yearly = 94,                    // Import Price Index y/y
   Industrial_Production_monthly = 45,                // Industrial Production m/m
   Industrial_Production_yearly = 46,                 // Industrial Production y/y
   Initial_Jobless_Claims = 22,                       // Unemployment Claims
   IPPI_monthly = 76,                                 // IPPI m/m
   ISM_Manufacturing_PMI = 26,                        // ISM Manufacturing PMI
   ISM_Non_Manufacturing_PMI = 27,                    // ISM Non Manufacturing PMI
   Ivey_PMI = 50,                                     // Ivey PMI
   JOLTS_Job_Openings = 1,                            // JOLTS Job Openings
   Labor_Cash_Earnings_yearly = 137,                  // Labor Cash Earnings y/y
   Labor_Cost_Index_quarterly = 135,                  // Labor Cost Index q/q
   Labor_Cost_Index_yearly = 136,                     // Labor Cost Index y/y
   Manufacturing_PMI = 127,                           // Manufacturing PMI
   Manufacturing_Production_monthly = 47,             // Manufacturing Production m/m
   Manufacturing_Production_yearly = 48,              // Manufacturing Production y/y
   Manufacturing_Sales_monthly = 103,                 // Manufacturing Sales m/m
   Michigan_Consumer_Expectations = 98,               // Michigan Consumer Expectations
   Michigan_Consumer_Sentiment = 28,                  // Michigan Consumer Sentiment
   Michigan_Inflation_Expectations = 99,              // Michigan Inflation Expectations
   Michigan_5_Year_Inflation_Expectations = 100,      // Michigan 5-Year Inflation Expectations
   New_Home_Sales = 118,                              // New Home Sales
   New_Home_Sales_monthly = 119,                      // New Home Sales m/m
   NY_Fed_Empire_State_Manufacturing_Index = 97,      // NY Fed Empire Manufacturing Index
   No_Event = -2,                                     // No Event
   Non_Manufacturing_PMI = 128,                       // Non Manufacturing PMI
   Nonfarm_Payrolls = 21,                             // Non-Farm Employment Change
   PPI_Input_monthly = 38,                            // PPI Input m/m
   PPI_Input_quarterly = 72,                          // PPI Input q/q
   PPI_Input_yearly = 40,                             // PPI Input y/y
   PPI_monthly = 4,                                   // PPI m/m
   PPI_Output_monthly = 39,                           // PPI Output m/m
   PPI_Output_quarterly = 73,                         // PPI Output q/q
   PPI_Output_yearly = 41,                            // PPI Output y/y
   PPI_quarterly = 69,                                // PPI q/q
   PPI_yearly = 5,                                    // PPI y/y
   Pending_Home_Sales_monthly = 120,                  // Pending Home Sales m/m
   Pending_Home_Sales_yearly = 121,                   // Pending Home Sales y/y
   RBA_Interest_Rate_Decision = 63,                   // RBA Rate (AUD)
   RBA_Trimmed_Mean_CPI_quarterly = 68,               // RBA Trimmed Mean CPI q/q
   RBNZ_2_Year_Inflation_Expectations = 92,           // RBNZ 2-Year Inflation Expectations
   RBNZ_Interest_Rate_Decision = 62,                  // RBNZ Interest Rate Decision
   RBNZ_Press_Conference = 64,                        // RBNZ Press Conference
   Real_Wage_yearly = 138,                            // Real Wage y/y
   Retail_Control_monthly = 108,                      // Retail Control m/m
   Retail_Sales_monthly = 29,                         // Retail Sales m/m
   Retail_Sales_quarterly = 82,                       // Retail Sales q/q
   Retail_Sales_yearly = 30,                          // Retail Sales y/y
   RMPI_monthly = 77,                                 // RMPI m/m
   SNB_Chairman_Jordan_Speech = 66,                   // SNB Chairman Jordan Speech
   SNB_Interest_Rate_Decision = 58,                   // SNB Interest Rate Decision
   SNB_News_Conference = 59,                          // SNB News Conference
   Global_Composite_PMI = 117,                        // S&P Global Composite PMI
   Global_Manufacturing_PMI = 115,                    // S&P Global Manufacturing PMI
   Global_Services_PMI = 116,                         // S&P Global Services PMI
   Tokyo_Core_CPI_yearly = 130,                       // Tokyo Core CPI y/y
   Tokyo_CPI_sa_monthly = 131,                        // Tokyo CPI s.a. m/m
   Trade_Balance = 24,                                // Trade Balance
   Unemployment_Rate = 20,                            // Unemployment Rate
   Unemployment_Rate_nsa = 74,                        // Unemployment Rate n.s.a.
   Wholesale_Trade_monthly = 107                      // Wholesale Trade m/m
  };
enum ENUM_NEWS_TREND_TYPE
  {
   ENUM_MACHINE_LEARNING,                 // Machine Learning
   ENUM_SMART_ANALYSIS,                   // Smart Analysis
   ENUM_MACHINE_LEARNING_SMART_ANALYSIS   // Both
  }; // enum to choose machine learning, smart analysis, or both

//+------------------------------------------------------------------+
ENUM_BULLISH_OR_BEARISH StringToTrend(const string trendVar)
  {
   return trendVar == "Bullish" ? ENUM_BULLISH : trendVar == "Bearish" ? ENUM_BEARISH : ENUM_NEUTRAL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_NEWS_CATEGORY StringToCategory(string category)
  {

// remove _ if in string
   StringReplace(category,"_"," ");

   if(category == "Consumer Inflation Report" || category == "Consumer Inflation" || category == "0")
     {
      return Consumer_Inflation_Report; // 0
     }

   if(category == "Producer Inflation Report" || category == "Producer Inflation" || category == "1")
     {
      return Producer_Inflation_Report; // 1
     }

   if(category == "Job Inflation Report" || category == "Job Inflation" || category == "2")
     {
      return Job_Inflation_Report; // 2
     }

   if(category == "Currency Report" || category == "Currency" || category == "3")
     {
      return Currency_Report; // 3
     }

   if(category == "Core Economy Report" || category == "Core Economy" || category == "4")
     {
      return Core_Economy_Report; // 4
     }

   if(category == "Economy Report" || category == "Economy" || category == "5")
     {
      return Economy_Report; // 5
     }

   if(category == "Production Report" || category == "Production" || category == "6")
     {
      return Production_Report; // 6
     }

   if(category == "Job Report" || category == "Job" || category == "7")
     {
      return Job_Report; // 7
     }

   if(category == "Commodity Report" || category == "Commodity" || category == "8")
     {
      return Commodity_Report; // 8
     }

   if(category == "Speech Report" || category == "Speech" || category == "9")
     {
      return Speech_Report; // 9
     }

   if(category == "Interest Rate Report" || category == "Interest Rate" || category == "10")
     {
      return Interest_Rate_Report; // 10
     }

   if(category == "Survery Report" || category == "Survey" || category == "11")
     {
      return Survery_Report; // 11
     }

   return No_Category; // -1

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_CURRENCY     StringToCurrency(const string currency)
  {

   if(currency == "EUR" || currency == "1")
     {
      return EUR; // 1
     }
   if(currency == "GBP" || currency == "2")
     {
      return GBP; // 2
     }
   if(currency == "AUD" || currency == "3")
     {
      return AUD; // 3
     }
   if(currency == "NZD" || currency == "4")
     {
      return NZD; // 4
     }
   if(currency == "CHF" || currency == "5")
     {
      return CHF; // 5
     }
   if(currency == "JPY" || currency == "6")
     {
      return JPY; // 6
     }
   if(currency == "CAD" || currency == "7")
     {
      return CAD; // 7
     }
   if(currency == "CNY" || currency == "8")
     {
      return CNY; // 8
     }

   return USD; // 0
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_NEWS_STRATEGY StringToStrategy(string strategy)
  {
// remove _ from string if any
   StringReplace(strategy,"_"," ");

// remove double space from string if any
   StringReplace(strategy,"  "," ");

// remove , from string if any
   StringReplace(strategy,",","");

   if(strategy == "0" || strategy == "actual more than forecast more than previous" || strategy == "Actual > Forecast > Previous")
     {
      return actual_more_than_forecast_more_than_previous; // 0
     }

   if(strategy == "1" || strategy == "actual more than forecast less than previous" || strategy == "Actual > Forecast Forecast < Previous")
     {
      return actual_more_than_forecast_less_than_previous; // 1
     }

   if(strategy == "2" || strategy == "actual more than forecast and actual less than previous" || strategy == "Actual > Forecast Actual < Previous")
     {
      return actual_more_than_forecast_and_actual_less_than_previous; // 2
     }

   if(strategy == "3" ||
      strategy == "actual more than forecast equal to previous" ||
      strategy == "Actual > Forecast Forecast = Previous" ||
      strategy == "Actual > Forecast = Previous"
     )
     {
      return actual_more_than_forecast_equal_to_previous; // 3
     }

   if(strategy == "4" || strategy == "actual more than forecast and actual equal to previous" || strategy == "Actual > Forecast Actual = Previous")
     {
      return actual_more_than_forecast_and_actual_equal_to_previous; // 4
     }

   if(strategy == "5" || strategy == "actual less than forecast and previous" || strategy == "Actual < Forecast < Previous")
     {
      return actual_less_than_forecast_and_previous; // 5
     }

   if(strategy == "6" || strategy == "actual less than forecast more than previous" || strategy == "Actual < Forecast Forecast > Previous")
     {
      return actual_less_than_forecast_more_than_previous; // 6
     }

   if(strategy == "7" || strategy == "actual less than forecast and actual more than previous" || strategy == "Actual < Forecast Actual > Previous")
     {
      return actual_less_than_forecast_and_actual_more_than_previous; // 7
     }

   if(strategy == "8" || strategy == "actual less than forecast and actual equal to previous" || strategy == "Actual < Forecast Actual = Previous")
     {
      return actual_less_than_forecast_and_actual_equal_to_previous; // 8
     }

   if(strategy == "9" ||
      strategy == "actual less than forecast equal to previous" ||
      strategy == "Actual < Forecast Forecast = Previous" ||
      strategy == "Actual < Forecast = Previous"
     )
     {
      return actual_less_than_forecast_equal_to_previous; // 9
     }

   if(strategy == "10" || strategy == "actual equal to forecast and previous" || strategy == "Actual = Forecast = Previous")
     {
      return actual_equal_to_forecast_and_previous; // 10
     }

   if(strategy == "11" ||
      strategy == "actual equal to forecast less than previous" ||
      strategy == "Actual = Forecast Forecast < Previous" ||
      strategy == "Actual = Forecast < Previous"
     )
     {
      return actual_equal_to_forecast_less_than_previous; // 11
     }

   if(strategy == "12" ||
      strategy == "actual equal to forecast more than previous" ||
      strategy == "Actual = Forecast Forecast > Previous" ||
      strategy == "Actual = Forecast > Previous"
     )
     {
      return actual_equal_to_forecast_more_than_previous; // 12
     }


   return data_not_loaded; // -1
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_NEWS_STRENGTH StringToStrength(string strengthVariable)
  {
// remove _ from string if any
   StringReplace(strengthVariable,"_"," ");

   if(strengthVariable == "Strong Data" || strengthVariable == "1")
     {
      return Strong_Data;
     }

   return Weak_Data;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_NEWS_QUALITY StringToQuality(string quality)
  {
// remove _ from string if any
   StringReplace(quality,"_"," ");

   if(quality == "Bad Data" || quality == "1")
     {
      return Bad_Data;
     }

   return Good_Data;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
