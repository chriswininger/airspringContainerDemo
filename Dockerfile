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
CMD ["/usr/sbin/init"]
#---------------------------------------
# --- Intall our dependencies ---
ADD ./docker-files/repos /docker-files/repos
ADD ./docker-files/src /docker-files/src
ADD ./docker-files/node-install-script /docker-files/node-install-script
COPY /docker-files/repos /etc/yum.repos.d/
RUN yum -y install -y mongodb-org-2.6.10 mongodb-org-server-2.6.10 mongodb-org-shell-2.6.10 mongodb-org-mongos-2.6.10 mongodb-org-tools-2.6.10
RUN yum -y install gcc make
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
RUN chmod +x /docker-files/node-install-script/setup
RUN /docker-files/node-install-script/setup
RUN yum -y install nodejs npm

