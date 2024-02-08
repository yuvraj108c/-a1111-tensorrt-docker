FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND noninteractive
ENV SHELL=/bin/bash
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt update -y && \
    apt install -y --no-install-recommends \
    libglib2.0-0 libglu1-mesa-dev google-perftools

# Install python3 and pip
RUN apt update && apt install -y python3 wget python-is-python3 git
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

# Install jupyterlab
RUN pip install jupyterlab==4.0.7 && pip cache purge

# Install Automatic1111's WebUI (11 oct 2023 version)
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
    cd stable-diffusion-webui && \
    git checkout dbb10fbd8c2dd4f3ca83a1d2e15e188799074ce4 && \
    pip install \
        torch==2.0.1+cu118 \
        torchvision==0.15.2+cu118 \
        --extra-index-url https://download.pytorch.org/whl/cu118 && \
    venv_dir=- ./webui.sh -f --exit --skip-torch-cuda-test && \
    pip install xformers==0.0.20 && \
    pip cache purge

COPY config.json /stable-diffusion-webui/config.json
WORKDIR /stable-diffusion-webui

# Install DeForum
RUN cd /stable-diffusion-webui && \
    git clone https://github.com/deforum-art/sd-webui-deforum extensions/deforum && \
    cd extensions/deforum && \
    pip install -r requirements.txt && \
    pip cache purge

# Install ControlNet
RUN cd /stable-diffusion-webui && \
    git clone https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet && \
    cd extensions/sd-webui-controlnet && \
    pip install -r requirements.txt && \
    pip cache purge

# Install TensorRT
RUN cd /stable-diffusion-webui && \
    git clone https://github.com/NVIDIA/Stable-Diffusion-WebUI-TensorRT extensions/tensorrt && \
    cd extensions/tensorrt && git checkout 9e9b21f8b9c2534845025a712602e2801519eefa && \
    pip install onnx polygraphy==0.49.0 onnxruntime==1.16.1 && \
    pip install onnx-graphsurgeon --extra-index-url https://pypi.ngc.nvidia.com && \
    pip install --pre --extra-index-url https://pypi.nvidia.com tensorrt==9.0.1.post11.dev4 --no-cache-dir && \
    pip cache purge

# Download models
RUN wget https://huggingface.co/jzli/DreamShaper-8/resolve/main/dreamshaper_8.safetensors -O /stable-diffusion-webui/models/Stable-diffusion/dreamshaper_8.safetensors
    #   && \
    # wget -P /stable-diffusion-webui/models/Stable-diffusion "https://huggingface.co/yuvraj108c/sd-models/resolve/main/deliberate.safetensors" && \
    # mkdir /stable-diffusion-webui/models/Unet-trt && \
    # wget -P /stable-diffusion-webui/models/Unet-trt "https://huggingface.co/yuvraj108c/nvidia-sd-trt-models-rtx-4090/resolve/main/deliberate_10ec4b29_cc89_sample%3D1x4x56x56%2B2x4x64x64%2B2x4x96x96-timesteps%3D1%2B2%2B2-encoder_hidden_states%3D1x77x768%2B2x77x768%2B2x154x768.trt" && \
    # wget -P /stable-diffusion-webui/models/Unet-trt "https://huggingface.co/yuvraj108c/nvidia-sd-trt-models-rtx-4090/resolve/main/dreamshaper_8_9d40847d_cc89_sample%3D1x4x56x56%2B2x4x64x64%2B2x4x96x96-timesteps%3D1%2B2%2B2-encoder_hidden_states%3D1x77x768%2B2x77x768%2B2x154x768.trt" && \
    # wget -P /stable-diffusion-webui/models/Unet-trt https://huggingface.co/yuvraj108c/nvidia-sd-trt-models-rtx-4090/resolve/main/model.json

# Start script
COPY start.sh /stable-diffusion-webui/start.sh
RUN chmod +x /stable-diffusion-webui/start.sh

# Launch jupyterlab & a1111
CMD ["/stable-diffusion-webui/start.sh"]