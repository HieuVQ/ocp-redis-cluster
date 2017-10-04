FROM centos:7
MAINTAINER Marcos Entenza <mak@redhat.com>

LABEL io.k8s.description="3 Node Redis Cluster" \
      io.k8s.display-name="Redis Cluster" \
      io.openshift.expose-services="6379:tcp" \
      io.openshift.tags="redis-cluster"

RUN groupadd -r redis && useradd -r -g redis -d /home/redis -m redis

RUN yum update -y && \
yum install -y make gcc nmap-ncat libc6-dev tcl && yum clean all

WORKDIR /tmp/

RUN curl http://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.2.tar.gz -o /tmp/ruby-2.4.2.tar.gz && \
echo "ba5ba60e5f1aa21b4ef8e9bf35b9ddb57286cb546aac4b5a28c71f459467e507 /tmp/ruby-2.4.2.tar.gz" > /tmp/ruby-2.4.2-sha256sum && \
sha256sum -c /tmp/ruby-2.4.2-sha256sum && \
tar xf /tmp/ruby-2.4.2.tar.gz && \
/tmp/ruby-2.4.2/configure && \
make && \
make install && \
rm -rf /tmp/*

#RUN echo "151.101.64.70 rubygems.org">> /etc/hosts && \
RUN gem install redis

WORKDIR /usr/local/src/

RUN curl -o redis-stable.tar.gz http://download.redis.io/redis-stable.tar.gz && \
tar xzf redis-stable.tar.gz && \
cd redis-stable && \
make MALLOC=libc

RUN for file in $(grep -r --exclude=*.h --exclude=*.o /usr/local/src/redis-stable/src | awk {'print $3'}); do cp $file /usr/local/bin; done && \
cp /usr/local/src/redis-stable/src/redis-trib.rb /usr/local/bin && \
cp -r /usr/local/src/redis-stable/utils /usr/local/bin && \
rm -rf /usr/local/src/redis*

COPY src/redis.conf /usr/local/etc/redis.conf
COPY src/*.sh /usr/local/bin/
COPY src/redis-trib.rb /usr/local/bin/


RUN mkdir /data && chown redis:redis /data && \
chown -R redis:redis /usr/local/bin/ && \
chown -R redis:redis /usr/local/etc/ && \
chmod +x /usr/local/bin/cluster-init.sh /usr/local/bin/redis-trib.rb

VOLUME /data
WORKDIR /data

USER redis

EXPOSE 6379 16379

CMD [ "redis-server", "/usr/local/etc/redis.conf" ]
