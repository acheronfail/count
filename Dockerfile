FROM ubuntu:latest

RUN apt-get update && apt-get install -y sudo
RUN useradd -m runner && echo "runner ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/runner
USER runner

COPY ./scripts/setup-image.sh /opt/setup-image.sh
RUN /opt/setup-image.sh
