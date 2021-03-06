FROM nvidia/cuda:8.0-devel-ubuntu16.04 

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDNN_VERSION 6.0.20 
RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         ca-certificates \
         libjpeg-dev \
         libpng-dev \
         libcudnn6=$CUDNN_VERSION-1+cuda8.0 libcudnn6-dev=$CUDNN_VERSION-1+cuda8.0
RUN  rm -rf /var/lib/apt/lists/*

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-4.2.12-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda
RUN rm ~/miniconda.sh
RUN /opt/conda/bin/conda install conda-build && \
    /opt/conda/bin/conda create -y --name pytorch python=2.7.12 numpy pyyaml scipy ipython mkl&& \
    /opt/conda/bin/conda clean -ya 
ENV PATH /opt/conda/envs/pytorch/bin:$PATH
RUN conda install -y --name pytorch  pytorch torchvision cuda80 -c pytorch
# This must be done before pip so that requirements.txt is available
WORKDIR /opt/pytorch

RUN apt-get -y update && apt-get install -y g++ gcc gfortran build-essential git libopenblas-dev
RUN conda install -y --name pytorch seaborn opencv cython

WORKDIR /tmp/
RUN git clone https://github.com/pdollar/coco
WORKDIR coco/PythonAPI
RUN python setup.py install

RUN mkdir -p /root/.local/share/anaconda/logs/docker/
RUN touch /root/.local/share/anaconda/logs/docker/anaconda_jsonserver.lo
RUN useradd -ms /bin/bash anh


ADD ./requirements.txt /tmp/requirements.txt
WORKDIR /tmp/
RUN pip install requests
RUN pip install -r requirements.txt
RUN jt -t onedork -fs 95 -altp -tfs 11 -nfs 115 -cellw 88% -T
