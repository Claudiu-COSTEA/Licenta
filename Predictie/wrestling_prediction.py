import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import tensorflow as tf
import pickle

# 1) Load data
df = pd.read_csv("Wrestling_Data.csv")

# 2) Encode target
df['winner_label'] = df['winner'].apply(lambda x: 1 if x == 'wrestler2' else 0)
df.drop('winner', axis=1, inplace=True)

feature_columns = [
    'wrestler1_win_rate_last_50',
    'wrestler1_experience_years',
    'wrestler1_technical_points_won_last_50',
    'wrestler1_technical_points_lost_last_50',
    'wrestler1_wins_against_wrestler2',
    'wrestler2_win_rate_last_50',
    'wrestler2_experience_years',
    'wrestler2_technical_points_won_last_50',
    'wrestler2_technical_points_lost_last_50',
    'wrestler2_wins_against_wrestler1'
]
X = df[feature_columns]
y = df['winner_label']

X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# 3) Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# 4) Create model
model = tf.keras.Sequential([
    tf.keras.layers.Dense(32, activation='relu', input_shape=(X_train_scaled.shape[1],)),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid')
])
model.compile(
    optimizer='adam',
    loss='binary_crossentropy',
    metrics=['accuracy']
)

# 5) Train model
model.fit(
    X_train_scaled, y_train,
    validation_split=0.2,
    epochs=3,
    batch_size=8,
    verbose=1
)

# 6) Evaluate quickly
loss, accuracy = model.evaluate(X_test_scaled, y_test)
print(f"Test accuracy: {accuracy:.4f}")

# 7) Save the model and scaler
model.save("my_model.h5")
print("Model saved to my_model.h5")

with open('scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)
print("Scaler saved to scaler.pkl")

# ---------------------------
# Later (or in a new script):
# ---------------------------

# 8) Load the model and scaler
loaded_model = tf.keras.models.load_model("my_model.h5")
with open("scaler.pkl", 'rb') as f:
    loaded_scaler = pickle.load(f)

# 9) Predict with loaded model
new_data = pd.DataFrame({
    'wrestler1_win_rate_last_50': [0.65],
    'wrestler1_experience_years': [7],
    'wrestler1_technical_points_won_last_50': [130],
    'wrestler1_technical_points_lost_last_50': [95],
    'wrestler1_wins_against_wrestler2': [3],
    'wrestler2_win_rate_last_50': [0.68],
    'wrestler2_experience_years': [8],
    'wrestler2_technical_points_won_last_50': [140],
    'wrestler2_technical_points_lost_last_50': [92],
    'wrestler2_wins_against_wrestler1': [5]
})

scaled_new_data = loaded_scaler.transform(new_data)
prediction = loaded_model.predict(scaled_new_data)
predicted_label = "wrestler2" if prediction[0][0] > 0.5 else "wrestler1"
print("Prediction probability:", prediction[0][0])
print("Predicted winner:", predicted_label)
