#Couchdb

FROM ubuntu:14.04 

RUN apt-get update -y
RUN apt-get install couchdb wget -y

RUN sed -i -e 's/;bind_address = 127.0.0.1/bind_address = 0.0.0.0/' /etc/couchdb/local.ini
RUN mkdir /var/run/couchdb  #   ???

#VOLUME ["/var/lib/couchdb"]

EXPOSE 5984

ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh

CMD ["/root/start.sh"]
