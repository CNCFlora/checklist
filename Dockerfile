FROM cncflora/ruby

RUN gem install bundler

RUN mkdir /root/checklist
ADD Gemfile /root/checklist/Gemfile
RUN cd /root/checklist && bundle install

ADD supervisord.conf /etc/supervisor/conf.d/proxy.conf

EXPOSE 8080
EXPOSE 9001

ADD . /root/checklist

