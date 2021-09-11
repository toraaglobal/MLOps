FROM huggingface/transformers-pytorch-cpu:latest

COPY app.py /app
COPY ./models/ /app/models/
COPY ./dvcfiles/ /app/dvcfiles/
WORKDIR /app

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY


# aws credentials configuration
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY


# install requirements
RUN pip install "dvc[s3]"   # since s3 is the remote storage
RUN pip install -r requirements.txt

# initialise dvc
RUN dvc init --no-scm

# configuring remote server in dvc
RUN dvc remote add -d model-store s3://toraaglobal/

RUN cat .dvc/config

# pulling the trained model
RUN dvc pull dvcfiles/trained_model.dvc

ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# running the application
EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]