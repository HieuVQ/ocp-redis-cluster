FROM centos:7
MAINTAINER Marcos Entenza <mak@redhat.com>

LABEL io.k8s.description="3 Node Redis Cluster" \
      io.k8s.display-name="Redis Cluster" \
      io.openshift.expose-services="6379:tcp" \
      io.openshift.tags="redis-cluster"

RUN groupadd -r redis && useradd -r -g redis -d /home/redis -m redis

RUN yum update -y && \
yum install -y gcc nmap-ncat libc6-dev tcl && yum clean all

RUN yum install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel sqlite-devel -y && yum clean all

WORKDIR /tmp/

RUN  curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
curl -L get.rvm.io | bash -s stable && \
source /etc/profile.d/rvm.sh && \
rvm reload && \
rvm requirements run && \
rvm install 2.2.4 && \
rvm use 2.2.4 --default && \
ruby --version


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
