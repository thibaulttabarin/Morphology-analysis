FROM ubuntu:20.04

# Label
LABEL org.opencontainers.image.title="fish morphological trait extraction"
LABEL org.opencontainers.image.authors=" T. Tabarin"
LABEL org.opencontainers.image.source="https://github.com/hdr-bgnn/Morphology-analysis"

# Install some basic utilities
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    wget \
 && rm -rf /var/lib/apt/lists/*

# Create a working directory
RUN mkdir /app
WORKDIR /app

# Create a non-root user and switch to it
RUN adduser --disabled-password --gecos '' --shell /bin/bash user \
 && chown -R user:user /app
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-user
USER user

# All users can use /home/user as their home directory
ENV HOME=/home/user
RUN chmod 777 /home/user

# Set up the Conda environment
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH=/home/user/miniconda/bin:$PATH
COPY Scripts/morphology_env.yml /app/environment.yml
RUN curl -sLo ~/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh \
 && chmod +x ~/miniconda.sh \
 && ~/miniconda.sh -b -p ~/miniconda \
 && rm ~/miniconda.sh \
 && conda env update -n base -f /app/environment.yml \
 && rm /app/environment.yml \
 && conda clean -ya

WORKDIR /pipeline

# Setup pipeline specific scripts
ENV PATH="/pipeline:${PATH}"

ADD Scripts/Traits_class.py /pipeline/Traits_class.py
ADD Scripts/Morphology_main.py /pipeline/Morphology_main.py

# Set the default command to a usage statement
CMD echo "Usage Morphology: Morphology_main.py  <input_file> <metadata.json> <measure.json> <landmark.json> <presence.json> <image_lm.png>\n"\

