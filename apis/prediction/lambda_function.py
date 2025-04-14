import json
import numpy as np
import pandas as pd
import pickle
import tensorflow as tf
from tensorflow.keras.models import load_model

model = load_model("./my_model.h5")
with open("./scaler.pkl", "rb") as f:
    scaler = pickle.load(f)

def lambda_handler(event, context):
    # 1) Parse input
    body = event.get('body')
    if body is None:
        body = event
    if isinstance(body, str):
        body = json.loads(body)

    # 2) Convert to DataFrame & scale
    df_input = pd.DataFrame([body])
    scaled_input = scaler.transform(df_input)

    # 3) Predict
    prediction = model.predict(scaled_input)
    prob = float(prediction[0][0])
    predicted_winner = "wrestler2" if prob > 0.5 else "wrestler1"

    return {
        "statusCode": 200,
        "body": json.dumps({
            "prediction_probability": prob,
            "predicted_winner": predicted_winner
        }),
        "headers": {"Content-Type": "application/json"}
    }
