From centos:7
MAINTAINER Chris Wininger <cwininger@airspringsoftware.com>
# ---coppied from https://hub.docker.com/_/centos/ ---
ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;
VOLUME [ "/sys/fs/cgroup" ]
VOLUME [ "/data/db" ]
CMD ["/usr/sbin/init"]
#---------------------------------------
# --- Intall our dependencies ---
ADD ./docker-files/start.sh /start.sh
ADD ./docker-files/airstep1 /airstep1
ADD ./docker-files/repos /docker-files/repos
ADD ./docker-files/src /docker-files/src
ADD ./docker-files/node-install-script /docker-files/node-install-script
ADD ./docker-files/usr/lib64 /binaries
COPY /docker-files/repos /etc/yum.repos.d/
COPY /binaries/libpgm-5.2.so.0 /usr/lib64/
COPY /libpgm-5.2.so.0.0.122 /usr/lib64/
COPY /libzmq.so.4 /usr/lib64/
COPY /libzmq.so.4.0.0 /usr/lib64/

#RUN mkdir /data
#RUN mkdir /data/db
RUN yum -y install -y mongodb-org-2.6.10 mongodb-org-server-2.6.10 mongodb-org-shell-2.6.10 mongodb-org-mongos-2.6.10 mongodb-org-tools-2.6.10 curl
RUN yum -y install gcc make
RUN net-tools-2.0-0.17.20131004git.el7.x86_64 zip unzip nc
RUN cd /docker-files/src/redis-3.0.4 && \
   make && \
   cd ./src && \
   cp redis-server redis-cli /usr/local/bin && \
   cp redis-sentinel redis-benchmark redis-check-aof redis-check-dump /usr/local/bin && \
  mkdir /etc/redis && \
  mkdir -p /var/lib/redis/6379 && \
 # sysctl -w vm.overcommit_memory=1 && \ https://github.com/openfirmware/docker-redis/issues/1
 # sysctl -w net.core.somaxconn=512 && \  https://github.com/openfirmware/docker-redis/issues/1
 # echo never > /sys/kernel/mm/transparent_hugepage/enabled && \  https://github.com/openfirmware/docker-redis/issues/1
  cp /docker-files/src/redis.conf /etc/redis/6379.confa
# run 0.10.x setup form https://rpm.nodesource.com/setup
#RUN chmod +x /docker-files/node-install-script/setup
#RUN /docker-files/node-install-script/setup
#RUN yum -y install nodejs npm
#RUN npm install -g gulp

# install node and npm using nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 6.9.2
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash \
   && source $NVM_DIR/nvm.sh \
   && nvm install $NODE_VERSION \
   && nvm alias default $NODE_VERSION \
   && nvm use default \
   && npm install -g gulp

RUN yum -y install openssh-clients
RUN yum -y install git
RUN yum -y install memcached
#RUN yum -y install zeromq zeromq-devel
RUN yum -y install glib*

# For PhantomJS (http://phantomjs.org/build.html)
RUN yum -y install gcc-c++ flex bison gperf ruby \
  openssl-devel freetype-devel fontconfig-devel libicu-devel sqlite-devel \
  libpng-devel libjpeg-devel
RUN cd /
RUN git clone https://github.com/ariya/phantomjs.git
RUN cd ./phantomjs \
	&& git checkout 2.1.1 \
   && git submodule init \
   && git submodule update \
   && python build.py \
   && ln -s /phantomjs/bin/phantomjs /usr/local/bin/phantomjs

RUN adduser memcacheUser
# Consider just specifying a branch at build and then mapping a volume onto that, currently for example the config overrides in my root os airstep will cause issuess
#  or maybe you specify a branch an volume, if not volume we will create it, it no git report there we will clone, otherwise just checkout

# After build run docker run -ti -v /home/chris/PHPStromProjects/airstep1:/airstep1 -v /home/chris/.ssh:/root/.ssh  airspring-container-demo /bin/bash
CMD [start.sh]
