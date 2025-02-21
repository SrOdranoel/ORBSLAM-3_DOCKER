#!/bin/bash

# Verificar se o NVIDIA está disponível
# if nvidia-smi | grep -q "Driver" 2>/dev/null; then
#   echo "******************************"
#   echo """Parece que você tem drivers NVIDIA instalados. Certifique-se de que o nvidia-docker está configurado corretamente e execute build_container_cuda.sh."""
#   echo "******************************"
#   while true; do
#     read -p "Deseja continuar mesmo assim? (s/n) " yn
#     case $yn in
#       [Ss]* ) break;;
#       [Nn]* ) exit;;
#       * ) echo "Por favor, responda sim (s) ou não (n).";;
#     esac
#   done
# fi

# Configurações de UI
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

xhost +local:docker

# Remover contêiner existente
docker rm -f orbslam3 &>/dev/null

# Construir a imagem a partir do Dockerfile.cpu
docker build -t orbslam3 -f Dockerfile.cpu .

# # Criar um novo contêiner a partir da imagem personalizada
# docker run -td --privileged --net=host --ipc=host \
#     --name="orbslam3" \
#     -e "DISPLAY=$DISPLAY" \
#     -e "QT_X11_NO_MITSHM=1" \
#     -v "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
#     -e "XAUTHORITY=$XAUTH" \
#     -e ROS_IP=127.0.0.1 \
#     --cap-add=SYS_PTRACE \
#     -v `pwd`/Datasets:/Datasets \
#     -v /etc/group:/etc/group:ro \
#     -v `pwd`/spinnaker-4.0.0.116-amd64:/spinnaker-4.0.0.116-amd64 \
#     orbslam3_custom bash

# Compilar o ORB_SLAM3 (se necessário)
# docker exec -it orbslam3 bash -i -c "cd /home/y/ORB_SLAM3 && sudo chmod +x build.sh && ./build.sh"

# # Configurar o ORB_SLAM3-ROS
# docker exec -it orbslam3 bash -i -c "echo 'ROS_PACKAGE_PATH=/opt/ros/noetic/share:/home/y/ORB_SLAM3/Examples/ROS'>>~/.bashrc && source ~/.bashrc && cd /home/y/ORB_SLAM3"
