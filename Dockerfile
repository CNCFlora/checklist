FROM cncflora/ruby

RUN gem install bundler

RUN mkdir /root/checklist
ADD Gemfile /root/checklist/Gemfile
RUN cd /root/checklist && bundle install

EXPOSE 80
WORKDIR /root/checklist
CMD ["unicorn","-p","80"]

ADD . /root/checklist

