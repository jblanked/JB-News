# News API Wrapper Library

This library is a comprehensive wrapper for JBlanked's News API. It leverages the power of OpenAI, Machine Learning, and MQL5's Calendar to provide developers with easy access to news data across all computer languages, including MQL4 and Python.

## Features

- Easy access to JBlanked's News API
- Access to News Event History, Machine Learning Predictions, Smart Analysis, and more.
- Supports multiple programming languages including MQL4 and Python

## Installation

```
pip install jb-news
```

## Usage

After installation, import the class:

```python
from jb_news.news import CJBNews 
```
Then set a variable as an instance of the CJBNews class:

```python
jb = CJBNews()
```
Next, get your API key from: https://www.jblanked.com/profile/. A list of Event IDs are found on https://www.jblanked.com/news/api/docs/.

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
        name = jb.info.name # event name
        currency = jb.info.currency # event currency
        event_id = jb.info.eventID # event id

        # print the news info
        print(f"Event Name: {name}\nEvent ID: {event_id}\nCurrency: {currency}")