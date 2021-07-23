import os
import json
from json import JSONEncoder

from pydantic import BaseModel
from fastapi import FastAPI
from typing import Optional, List
import httpx

ENDPOINT = os.environ.get('ENDPOINT')

class Entity(BaseModel):
    name: str
    type: Optional[str]
    value: str

class Item(BaseModel):
    name: str
    type: str
    value: Optional[str]
    items: List[Entity]

app = FastAPI()

@app.get("/")
async def info():
    return {'version': 1, 'name': 'wechat broker'}

@app.post("/")
async def index(item: Item):
    message = f"""
    ### {item.name}
    `{item.type}`"""
    for i in item.items:
        message += f'\n- {i.name}: {i.value}'

    payload = {"msgtype":"markdown","markdown":{"content": message}}

    if ENDPOINT:
        async with httpx.AsyncClient() as client:
            r = await client.post(ENDPOINT, json=payload)
            return r.text
    else:
        return payload




