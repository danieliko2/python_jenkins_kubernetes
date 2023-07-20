import main
from fastapi import FastAPI
from fastapi.testclient import TestClient
import requests

client = TestClient(main.app)

def test_main():
    response = client.get("/")
    assert response.status_code == 200
    # response = client.get("/html")
    # assert response.status_code == 200

def test_container():
    url = 'http://localhost:8000'
    response = requests.get(url)
    assert response.status_code == 200