FROM python:3.8

ENV DEPLOYABLE true

RUN apt-get update -qq && apt-get install -y \
    libopenblas-dev \
    wget \
    git \
    make \
    vim \
    build-essential \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libblas-dev \
    liblapack-dev \
    gfortran

WORKDIR /app

COPY . /app

# Assuming that requirements.txt is in the same directory as your Dockerfile
COPY requirements.txt .

RUN pip install --upgrade pip && \
    pip install pytest nose nose2 && \
    pip install --no-cache-dir -r requirements.txt

RUN git submodule update --init --recursive && \
    make TARGET=NEHALEM && \
    python setup.py bdist_wheel && \
    pip install dist/*.whl

CMD ["nosetests"]
