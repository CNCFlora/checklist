FROM cncflora/ruby

RUN apt-get install supervisor -y
RUN gem install small-ops -v 0.0.30
RUN mkdir /var/log/supervisord 

RUN gem install bundler

RUN mkdir /root/checklist
ADD Gemfile /root/checklist/Gemfile
RUN cd /root/checklist && bundle install

ADD supervisord.conf /etc/supervisor/conf.d/proxy.conf

ADD . /root/checklist

ENV ENV production
ENV RACK_ENV production

EXPOSE 8080
EXPOSE 9001

CMD ["supervisord"]

