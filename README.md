# JB-News

This library is a comprehensive wrapper for JBlanked's News API. It leverages the power of OpenAI, Machine Learning, and MQL5's Calendar to provide developers with easy access to news data across all computer languages, including MQL4 and Python. Full documentation: https://www.jblanked.com/news/api/docs/

## Features

- Easy access to JBlanked's News API
- Access to News Event History, Machine Learning Predictions, Smart Analysis, and more.
- Access to News Calendar
- Supports multiple programming languages including MQL4, Python, and Swift.

## Python Installation

```
pip install jb-news
```
This API is freely accessible through our library and through GET requests. Get your API key from: https://www.jblanked.com/profile/. Note that the free tier has a rate limit of once every 5 minutes, but VIP members enjoy unrestricted access.
## Python Usage

After installation, import the class:

```python
from jb_news.news import CJBNews 
```
Then set a variable as an instance of the CJBNews class:

```python
jb = CJBNews()
```
A list of Event IDs are found on https://www.jblanked.com/news/api/docs/.

Next, set your API key and Event ID:

```python
api_key = "YOUR_API_KEY_HERE" 

event_id = 756020001 # CHF CPI

jb.offset = 7  # GMT-3 = 0, GMT = 3, EST = 7, PST = 10
```

Next step is to connect to the API by using the get method. 
```python
if jb.get(api_key):  
```

Lastly, load the event info of the specified Event ID:
```python
    if jb.load(event_id):  
        name = jb.info.name 
        currency = jb.info.currency 
        event_id = jb.info.eventID 
        history = jb.info.history 
        category = jb.info.category
        machine_learning = jb.info.machine_learning
        smart_analysis = jb.info.smart_analysis

        # print the news info
        print(f"Event Name: {name}\nEvent ID: {event_id}\nCurrency: {currency}")
```

Alternatively, instead of using the get method, you can load the calendar:
```python
if jb.calendar(api_key,today=True):
    for event in jb.calendar_info:
        name = event.name
        currency = event.currency 
        event_id = event.eventID 
        category = event.category 
        date = event.date 
        actual = event.actual
        forecast = event.forecast 
        previous = event.previous 
        outcome = event.outcome 
        strength = event.strength 
        quality = event.quality 
        projection = event.projection 

        # print the calendar info
        print(f"Event Name: {name}\nEvent ID: {event_id}\nCurrency: {currency}\nDate: {date}\nActual: {actual}\nForecast: {forecast}\nPrevious: {previous}")
```

You can also access our NewsGPT model:

```python
gpt_response = jb.GPT(api_key,"What does bullish mean in forex?")
print(gpt_response)
```