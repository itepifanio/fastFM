FROM python:3.8

ENV DEPLOYABLE true
ENV PATH="/root/miniconda/bin:${PATH}"
ARG PATH="/root/miniconda/bin:${PATH}"

RUN apt-get update -qq && apt-get install -y libopenblas-dev wget git make vim

RUN wget https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /root/miniconda && \
    hash -r && \
    conda config --set always_yes yes --set changeps1 no && \
    conda update -q conda && \
    conda info -a && \
    conda create -q -n test-environment python=3.8 cython numpy pandas scipy scikit-learn nose2 pytest

RUN echo "source activate test-environment" > ~/.bashrc

WORKDIR /app

COPY . /app

RUN git submodule update --init --recursive && \
    /bin/bash -c ". activate test-environment; make TARGET=NEHALEM" && \
    /bin/bash -c ". activate test-environment; python setup.py bdist_wheel" && \
    /bin/bash -c ". activate test-environment; pip install dist/*.whl"

CMD ["nosetests"]
