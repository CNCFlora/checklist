FROM cncflora/ruby

RUN gem install bundler

RUN mkdir /root/checklist
ADD Gemfile /root/checklist/Gemfile
RUN cd /root/checklist && bundle install
ADD . /root/checklist

ENV ENV production
ENV RACK_ENV production
ADD start.sh /root/start.sh
RUN chmod +x /root/start.sh

EXPOSE 8080

CMD ["/root/start.sh"]

