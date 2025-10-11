# PyCalendar

A Python Tkinter application that fetches and displays economic news events in a user-friendly calendar format. It organizes data from financial news APIs into a sortable table, making it easy to track upcoming economic indicators, their forecasts, and historical values.

## Features

- Fetches economic news from MQL5 or Forex Factory APIs
- Displays events in a sortable table with columns for Date, Currency, Event, Actual, Forecast, and Previous values
- Sorts events by date for chronological viewing
- Includes currency flags/emojis for visual identification
- Supports time zone adjustments via offset configuration
- Clean, modern GUI built with Tkinter

## Requirements

- Python 3.6+
- Valid API key from https://www.jblanked.com/api/key/

## Installation

1. Create a virtual environment: `python -m venv venv`
2. Install dependencies: `pip install -r requirements.txt`
3. Activate the virtual environment: `source venv/bin/activate`
4. Run the application: `python main.py`

## Configuration

Before running the application, you need to configure the following settings in `main.py`:

### API Key
Set your API key from the news source:
```python
API_KEY = "YOUR_API_KEY_HERE"
```
- Obtain an API key from [https://www.jblanked.com/api/key/](https://www.jblanked.com/api/key/)

### Time Zone Offset
Adjust the time zone offset (in hours) to display dates in your local time:
```python
OFFSET = 7  # GMT-3 = 0, GMT = 3, EST = 7, PST = 10
```
Common offsets:
- GMT-3: 0
- GMT: 3
- EST (Eastern Standard Time): 7
- PST (Pacific Standard Time): 10

### News Source
Choose the news source:
```python
SOURCE = "mql5"  # Options: "mql5", "forex-factory"
```
- `"mql5"`: Fetches data from MQL5 economic calendar
- `"forex-factory"`: Fetches data from Forex Factory

## Usage

1. Configure the settings in `main.py` as described above
2. Run the application: `python main.py`
3. The GUI will display a table of economic events for the current week
4. Events are automatically sorted by date
5. Scroll through the list to view all events
6. Close the window to exit the application

The table columns show:
- **Date**: When the event occurs
- **Currency**: The affected currency with flag emoji
- **Event**: The economic indicator name
- **Actual**: The actual value (if released)
- **Forecast**: The expected value
- **Previous**: The previous period's value
