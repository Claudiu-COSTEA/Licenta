import tensorflow as tf
import pickle
import json
import pandas as pd

# Load model and scaler once, at cold start
model = tf.keras.models.load_model("my_model.h5")
with open("scaler.pkl", "rb") as f:
    scaler = pickle.load(f)

def lambda_handler(event, context):
    try:
        if isinstance(event.get("body"), str):
            data = json.loads(event["body"])
        else:
            data = event.get("body", event)

        df = pd.DataFrame([data])
        X = scaler.transform(df)
        prob = float(model.predict(X)[0][0])
        winner = "wrestler2" if prob > 0.5 else "wrestler1"

        return {
            "statusCode": 200,
            "body": json.dumps({
                "prediction_probability": prob,
                "predicted_winner": winner
            }),
            "headers": {"Content-Type": "application/json"}
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
