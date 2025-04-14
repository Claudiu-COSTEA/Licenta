# Use the official AWS base image for Python 3.9
FROM public.ecr.aws/lambda/python:3.9

# Install dependencies
RUN pip install --no-cache-dir tensorflow pandas scikit-learn

# Copy your Lambda handler, model, and scaler
COPY lambda_function.py ./
COPY my_model.h5 .
COPY scaler.pkl .

# Define the Lambda handler function
CMD ["lambda_function.lambda_handler"]
