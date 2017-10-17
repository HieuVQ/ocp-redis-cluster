FROM centos:7
MAINTAINER Ricardo Santos <rc.ricardosantos@outlook.com>

LABEL io.k8s.description="3 Node Redis Cluster" \
      io.k8s.display-name="Redis Cluster" \
      io.openshift.expose-services="6379:tcp" \
      io.openshift.tags="redis-cluster"

RUN groupadd -r redis && useradd -r -g redis -d /home/redis -m redis

RUN yum update -y && \
yum install -y make gcc nmap-ncat libc6-dev tcl wget psmisc && yum clean all

WORKDIR /tmp

COPY src/ruby-2.2.3-1.el7.centos.x86_64.rpm/ /tmp/

RUN yum -y localinstall /tmp/ruby-2.2.3-1.el7.centos.x86_64.rpm

WORKDIR /usr/local/src/

RUN curl -o redis-stable.tar.gz http://download.redis.io/redis-stable.tar.gz && \
tar xzf redis-stable.tar.gz && \
cd redis-stable && \
make MALLOC=libc && \
gem install redis

RUN for file in $(grep -r --exclude=*.h --exclude=*.o /usr/local/src/redis-stable/src | awk {'print $3'}); do cp $file /usr/local/bin; done && \
cp /usr/local/src/redis-stable/src/redis-trib.rb /usr/local/bin && \
cp -r /usr/local/src/redis-stable/utils /usr/local/bin && \
rm -rf /usr/local/src/redis*


COPY src/*.sh /usr/local/bin/
COPY src/redis-trib.rb /usr/local/bin/

RUN mkdir /data && chown redis:redis /data && \
chown -R redis:redis /usr/local && \
chmod -R 777 /usr/local && \
chmod +x /usr/local/bin/cluster-init.sh /usr/local/bin/redis-trib.rb

VOLUME /data
WORKDIR /data

RUN mkdir /redis
COPY src/redis.conf /redis/redis.conf
RUN chown -R redis:redis /redis && \
chmod -R 777 /redis

USER redis

EXPOSE 6379 16379

CMD [ "redis-server", "/redis/redis.conf" ]
