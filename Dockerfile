FROM centos:7

RUN yum -y install epel-release
RUN rpm -i https://bintray.com/artifact/download/erlio/vernemq/rpm/centos7/vernemq-0.12.5p2-1.el7.centos.x86_64.rpm

RUN yum -y install net-tools wget

COPY docker/run.sh /
RUN chmod +x /run.sh
COPY docker/vernemq.conf /etc/vernemq/vernemq.conf

COPY docker/vm.args /etc/vernemq/

VOLUME  /var/lib/vernemq

RUN wget https://github.com/aep/recall/releases/download/1/recall-x86_64 -q -O /bin/recall
RUN chmod +x /bin/recall

EXPOSE  1883
EXPOSE  1884
ENTRYPOINT  ["./run.sh"]

