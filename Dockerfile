FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# To assure python logging works properly
ENV PYTHONUNBUFFERED=1

# Install python3 and pip
RUN apt update && apt install -y python3 wget python-is-python3
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

# Install jupyterlab
RUN pip install jupyterlab==4.0.7 && pip cache purge

# Install AUTOMATIC1111
RUN apt update && apt install --no-install-recommends -y git
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
WORKDIR /stable-diffusion-webui
RUN \
    apt update && \
    apt install --no-install-recommends -y \
    libglib2.0-0 libglu1-mesa-dev google-perftools && \
    pip install \
        torch==2.0.1+cu118 \
        torchvision==0.15.2+cu118 \
        --extra-index-url https://download.pytorch.org/whl/cu118 && \
    venv_dir=- ./webui.sh -f --exit --skip-torch-cuda-test && \
    pip install xformers==0.0.20 && \
    pip cache purge

# Install TensorRT extension for AUTOMATIC1111 and configure the UI of AUTOMATIC1111
RUN git clone https://github.com/NVIDIA/Stable-Diffusion-WebUI-TensorRT /stable-diffusion-webui/extensions/Stable-Diffusion-WebUI-TensorRT
RUN pip install tensorrt==8.6.1.post1 && pip cache purge

COPY config.json /stable-diffusion-webui/config.json
COPY start.sh /stable-diffusion-webui/start.sh
RUN chmod +x /stable-diffusion-webui/start.sh

# Install deforum + controlnet
RUN git -C /stable-diffusion-webui/extensions clone https://github.com/deforum-art/sd-webui-deforum.git
RUN git -C /stable-diffusion-webui/extensions clone https://github.com/Mikubill/sd-webui-controlnet.git
RUN git -C ./stable-diffusion-webui/extensions clone https://github.com/AUTOMATIC1111/stable-diffusion-webui-tensorrt.git

# Launch jupyterlab & a1111
CMD ["/stable-diffusion-webui/start.sh"]
