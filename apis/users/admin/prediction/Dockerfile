FROM public.ecr.aws/lambda/python:3.10

RUN pip install --no-cache-dir tensorflow-cpu pandas scikit-learn

COPY lambda_function.py ./
COPY my_model.h5 ./
COPY scaler.pkl ./

CMD ["lambda_function.lambda_handler"]


