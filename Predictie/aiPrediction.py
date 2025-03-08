#####################################################
# STEP 0: IMPORTS AND SETUP
#####################################################
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, classification_report

import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import TensorDataset, DataLoader

#####################################################
# STEP 1: LOAD YOUR CSV DATA
#####################################################
# Expected Columns:
#  1) wrestler1_win_rate_last_50
#  2) wrestler1_experience_years
#  3) wrestler1_technical_points_won_last_50
#  4) wrestler1_technical_points_lost_last_50
#  5) wrestler1_wins_against_wrestler2
#  6) wrestler2_win_rate_last_50
#  7) wrestler2_experience_years
#  8) wrestler2_technical_points_won_last_50
#  9) wrestler2_technical_points_lost_last_50
# 10) wrestler2_wins_against_wrestler1
# 11) winner (string: "wrestler1" or "wrestler2")

data = pd.read_csv("Wrestling_Data.csv")

# Quick sanity check: print first few rows
print("Data sample:")
print(data.head())

#####################################################
# STEP 2: CONVERT 'winner' FROM STRING TO NUMERIC
#####################################################
# We'll map "wrestler1" -> 1, "wrestler2" -> 0
data["winner"] = data["winner"].apply(lambda x: 1 if x == "wrestler1" else 0)

#####################################################
# STEP 3: SPLIT INTO FEATURES (X) AND TARGET (y)
#####################################################
X = data.drop("winner", axis=1)  # all columns except 'winner'
y = data["winner"]               # only the 'winner' column

print("\nFeature columns:", list(X.columns))
print("Label distribution:\n", y.value_counts())

#####################################################
# STEP 4: TRAIN/TEST SPLIT
#####################################################
# We'll hold out 30% of the data for testing
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.30, random_state=42
)

print(f"\nTraining samples: {len(X_train)}")
print(f"Testing samples:  {len(X_test)}")

#####################################################
# STEP 5: SCALE THE FEATURES
#####################################################
# Neural networks often perform better with scaled inputs
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

#####################################################
# STEP 6: BUILD A SIMPLE FEEDFORWARD NEURAL NETWORK
#####################################################
# We'll define a small network for binary classification

class SimpleNN(nn.Module):
    def __init__(self, input_dim):
        super(SimpleNN, self).__init__()
        
        # A small 2-hidden-layer network
        self.net = nn.Sequential(
            nn.Linear(input_dim, 16),  # hidden layer 1
            nn.ReLU(),
            nn.Linear(16, 8),         # hidden layer 2
            nn.ReLU(),
            nn.Linear(8, 1),          # output layer (1 output for binary classification)
            nn.Sigmoid()              # final activation for probability [0, 1]
        )
        
    def forward(self, x):
        return self.net(x)

# Number of input features (should match the number of columns in X)
input_dim = X_train.shape[1]
model = SimpleNN(input_dim)

#####################################################
# STEP 7: PREPARE FOR TRAINING (LOSS, OPTIMIZER)
#####################################################
criterion = nn.BCELoss()          # Binary cross-entropy for binary classification
optimizer = optim.Adam(model.parameters(), lr=0.001)

#####################################################
# STEP 8: CREATE TORCH DATASETS AND LOADERS
#####################################################
# Convert NumPy arrays to torch Tensors
X_train_tensor = torch.tensor(X_train_scaled, dtype=torch.float32)
y_train_tensor = torch.tensor(y_train.values, dtype=torch.float32).view(-1, 1)

X_test_tensor = torch.tensor(X_test_scaled, dtype=torch.float32)
y_test_tensor = torch.tensor(y_test.values, dtype=torch.float32).view(-1, 1)

# Create a Dataset and DataLoader for training
train_dataset = TensorDataset(X_train_tensor, y_train_tensor)
train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)

#####################################################
# STEP 9: TRAIN THE MODEL
#####################################################
epochs = 50  # you can increase if needed
for epoch in range(epochs):
    for batch_X, batch_y in train_loader:
        optimizer.zero_grad()
        predictions = model(batch_X)
        loss = criterion(predictions, batch_y)
        loss.backward()
        optimizer.step()
        
    # Print loss every 10 epochs for visibility
    if (epoch + 1) % 10 == 0:
        print(f"Epoch [{epoch+1}/{epochs}], Loss: {loss.item():.4f}")

#####################################################
# STEP 10: EVALUATE THE MODEL ON THE TEST SET
#####################################################
model.eval()  # put model in evaluation mode
with torch.no_grad():
    # forward pass on test data
    y_test_pred_proba = model(X_test_tensor).numpy().flatten()

# Convert probabilities to class predictions (>= 0.5 => 1, else 0)
y_test_pred = (y_test_pred_proba >= 0.5).astype(int)

# Calculate accuracy
accuracy = accuracy_score(y_test, y_test_pred)
print(f"\nTest Accuracy: {accuracy:.2f}")
print("Classification Report:")
print(classification_report(y_test, y_test_pred, digits=3))

#####################################################
# STEP 11: MAKE A PREDICTION FOR A NEW MATCH
#####################################################
# Suppose we have a new match with the following features (in the same column order!):
#  wrestler1_win_rate_last_50 = 0.58
#  wrestler1_experience_years = 5
#  wrestler1_technical_points_won_last_50 = 120
#  wrestler1_technical_points_lost_last_50 = 90
#  wrestler1_wins_against_wrestler2 = 3
#  wrestler2_win_rate_last_50 = 0.56
#  wrestler2_experience_years = 6
#  wrestler2_technical_points_won_last_50 = 110
#  wrestler2_technical_points_lost_last_50 = 100
#  wrestler2_wins_against_wrestler1 = 4

new_match = np.array([[0.33,1,60,120,0,0.35,2,65,118,1]], dtype=np.float32)

# Scale this new match with the same scaler used for training
new_match_scaled = scaler.transform(new_match)

# Convert to tensor
new_match_tensor = torch.tensor(new_match_scaled, dtype=torch.float32)

model.eval()
with torch.no_grad():
    new_pred_proba = model(new_match_tensor).item()

new_pred_class = 1 if new_pred_proba >= 0.5 else 0
winner_str = "wrestler1" if new_pred_class == 1 else "wrestler2"

print(f"\nNew match predicted probability of wrestler1 winning: {new_pred_proba:.3f}")
print(f"Predicted winner: {winner_str}")
