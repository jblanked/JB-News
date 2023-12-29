# JB-News

This library is a comprehensive wrapper for JBlanked's News API. It leverages the power of OpenAI, Machine Learning, and MQL5's Calendar to provide developers with easy access to news data across all computer languages, including MQL4 and Python.

## Features

- Easy access to JBlanked's News API
- Access to News Event History, Machine Learning Predictions, Smart Analysis, and more.
- Supports multiple programming languages including MQL4 and Python

## Installation

```
pip install jb-news
```
This API is freely accessible through our library and through GET requests. Get your API key from: https://www.jblanked.com/profile/. Note that the free tier has a rate limit of once every 5 minutes, but VIP members enjoy unrestricted access.
## Usage

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
```

Next step is to connect to the API by using the start method. You only need to do this once:
```python
if jb.start(api_key):  
```

Lastly, load the event info of the specified Event ID:
```python
    if jb.load(event_id):  
        name = jb.info.name 
        currency = jb.info.currency 
        event_id = jb.info.eventID 
        history = jb.info.history 
        machine_learning = jb.info.machine_learning
        smart_analysis = jb.info.smart_analysis

        # print the news info
        print(f"Event Name: {name}\nEvent ID: {event_id}\nCurrency: {currency}")