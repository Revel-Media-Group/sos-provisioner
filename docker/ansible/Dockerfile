FROM alpine:latest

# update and upgrade the alpine docker contaianer
RUN apk update
RUN apk add --upgrade apk-tools
RUN apk upgrade --available

# install all the utilities we'd ever want for debugging
RUN apk add ansible python3 just zsh starship tmux shadow openssh sshpass

# copy global profile
COPY ./zshrc /etc/zsh/zshrc

# change shell to zsh (better developer experience)
RUN chsh -s /bin/zsh

# make the WORKDIR for the project
RUN mkdir /root/sos-provisioner
WORKDIR /root/sos-provisioner


CMD tail -f /dev/null
