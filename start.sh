jupyter-lab --allow-root --ip  0.0.0.0 --NotebookApp.token='' --notebook-dir / --NotebookApp.allow_origin=* --NotebookApp.allow_remote_access=1 & \
  python /stable-diffusion-webui/launch.py --port  3000 --listen --enable-insecure-extension-access --xformers
