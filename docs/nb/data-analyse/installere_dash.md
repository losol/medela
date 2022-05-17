---
description: Kom i gang med open source analyseverktøyet Dash.
---

# Installere Dash

Installer først [brew](https://brew.sh/index_nb), dersom du ikke har det. Poetry er til god hjelp når man programmerer i Python. Installer først Poetry, `brew install poetry`

## Sette opp et nytt prosjekt

Lag deg en katalog, og kjør `poetry init` for å få et nytt prosjekt.

## Analyseverktøy

De viktigste pakkene du trenger er:

- dash
- pandas

Install disse pakkene dash og pandas: `poetry add dash pandas`

## Støtteverktøy

For å holde orden på koden din er det greit å ha med pakkene:

- flake8
- isort

Installer disse som devdependencies med kommandoen `poetry add -D flake8 isort`

## Din første side

Lag en ny fil i prosjektmappa di, som du kaller `app.py`. Legg til dette innholdet:

```python
from dash import Dash, html, dcc
import plotly.express as px
import pandas as pd

app = Dash(__name__)

# assume you have a "long-form" data frame
# see https://plotly.com/python/px-arguments/ for more options
df = pd.DataFrame({
    "Fruit": ["Apples", "Oranges", "Bananas", "Apples", "Oranges", "Bananas"],
    "Amount": [4, 1, 2, 2, 4, 5],
    "City": ["SF", "SF", "SF", "Montreal", "Montreal", "Montreal"]
})

fig = px.bar(df, x="Fruit", y="Amount", color="City", barmode="group")

app.layout = html.Div(children=[
    html.H1(children='Hello Dash'),

    html.Div(children='''
        Dash: A web application framework for your data.
    '''),

    dcc.Graph(
        id='example-graph',
        figure=fig
    )
])

if __name__ == '__main__':
    app.run_server(debug=True)
```

## Test applikasjonen

Test at du klarer å kjøre dash med `poetry run python app.py`
