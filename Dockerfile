FROM centos:7

RUN yum -y install epel-release
RUN yum -y install net-tools wget unzip mosquitto

RUN wget https://github.com/aep/recall/releases/download/1/recall-x86_64 -q -O /bin/recall
RUN chmod +x /bin/recall

COPY docker/run.sh /
RUN chmod +x /run.sh

EXPOSE  1883
ENTRYPOINT  ["/run.sh"]
