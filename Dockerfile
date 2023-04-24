FROM python:alpine3.17
WORKDIR /app
COPY newshopapp/requirements.txt .
RUN pip3 install -r requirements.txt
COPY newshopapp .
EXPOSE 8000
CMD python3 -m uvicorn main:app --reload --proxy-headers --host 0.0.0.0 --port 8000
# CMD [ "python", "main.py" ]