FROM centos:7
MAINTAINER Marcos Entenza <mak@redhat.com>

LABEL io.k8s.description="3 Node Redis Cluster" \
      io.k8s.display-name="Redis Cluster" \
      io.openshift.expose-services="6379:tcp" \
      io.openshift.tags="redis-cluster"

RUN groupadd -r redis && useradd -r -g redis -d /home/redis -m redis

RUN yum update -y && \
yum install -y make gcc rubygems nmap-ncat wget && yum clean all && yum clean all

RUN yum -y group install "Development Tools"

RUN yum -y install gdbm-devel libdb4-devel libffi-devel libyaml libyaml-devel ncurses-devel openssl-devel readline-devel tcl-devel


RUN mkdir -p /root/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} && \
wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz -P /root/rpmbuild/SOURCES && \
wget https://raw.githubusercontent.com/tjinjin/automate-ruby-rpm/master/ruby22x.spec -P /root/rpmbuild/SPECS && \
rpmbuild -bb /root/rpmbuild/SPECS/ruby22x.spec && \
yum -y localinstall /root/rpmbuild/RPMS/x86_64/ruby-2.2.3-1.el7.centos.x86_64.rpm

RUN gem install redis

WORKDIR /usr/local/src/

RUN curl -o redis-3.2.6.tar.gz http://download.redis.io/releases/redis-3.2.6.tar.gz && \
tar xzf redis-3.2.6.tar.gz && \
cd redis-3.2.6 && \
make MALLOC=libc

RUN for file in $(grep -r --exclude=*.h --exclude=*.o /usr/local/src/redis-3.2.6/src | awk {'print $3'}); do cp $file /usr/local/bin; done && \
cp /usr/local/src/redis-3.2.6/src/redis-trib.rb /usr/local/bin && \
cp -r /usr/local/src/redis-3.2.6/utils /usr/local/bin && \
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
