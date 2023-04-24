# Import required packages
import logging

from logging.handlers import RotatingFileHandler
from fastapi.logger import logger as fastapi_logger

from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from os import environ
from pymongo import MongoClient, InsertOne

# Initialize FastAPI
app = FastAPI()


formatter = logging.Formatter(
    "[%(asctime)s.%(msecs)03d] %(levelname)s [%(thread)d] - %(message)s", "%Y-%m-%d %H:%M:%S")
try:
    handler = RotatingFileHandler('./log/record.log', backupCount=0)
except: # for testing
    handler = RotatingFileHandler('./newshopapp/log/record.log', backupCount=0)

logging.getLogger().setLevel(logging.NOTSET)
fastapi_logger.addHandler(handler)
handler.setFormatter(formatter)

fastapi_logger.info("starting")


# MongoDB connection
mongo_pass = environ.get('MONGO_PASS')
CONNECTION_STRING = f'mongodb+srv://admin:{mongo_pass}@cluster0.ds6gvkt.mongodb.net/?retryWrites=true&w=majority'
client = MongoClient(CONNECTION_STRING)
db=client['purchases_db']
col = db['purchases']

templates = Jinja2Templates(directory="templates")

purchase_form = """
    <h1> a brand new day</h1>
    <form method="post">
        <label for="item">Item:</label>
        <input type="text" name="item"><br>
        <label for="quantity">Quantity:</label>
        <input type="number" name="quantity"><br>
        <label for="price">Price:</label>
        <input type="number" name="price"><br>
        <input type="submit" value="Purchase"> <br> <br>
    </form>

AttributeError: 'FastAPI' object has no attribute 'logger'

"""

purchase_success = """
    <h1>Purchase Successful!</h1>
    <p>Item: {item}</p>
    <p>Quantity: {quantity}</p>
    <p>Price: {price}</p>
"""

all_items = """ {data} """

admin = "You little hacker"

@app.get("/")
async def purchase(request: Request, response_class=HTMLResponse):
    return HTMLResponse(content=purchase_form)
    # mongo_connect()


@app.get("/admin")
async def purchase(request: Request, response_class=HTMLResponse):
    fastapi_logger.warning("someone accessed admin page")
    return HTMLResponse(content=admin)
    # mongo_connect()

@app.get("/html")
async def html(request: Request):
    context={
        "request":request,
        "data":"hi"
    }
    return  templates.TemplateResponse("main.html", context)

@app.post("/")
async def purchase_submit(request: Request, item: str = Form(...), quantity: int = Form(...), price: float = Form(...)):
    total_price = quantity * price
    data = {'item' : item, 'quantity' : quantity}
    # SEND TO DB
    x = col.insert_one(data)
    fastapi_logger.info(f'purchaes submitted- item: {item}, quantity {quantity}')

    return HTMLResponse(content=purchase_success.format(item=item, quantity=quantity, price=total_price), status_code=200)


@app.post("/allitem")
async def allitem_post(request: Request):

    data = {}
    for i in col.find():
        # print(i['item'])
        data.update({str(i["item"]):str(i["quantity"])})
    context = {
        "request": request,
        "data": data
    }
    return  templates.TemplateResponse("main.html", context)
