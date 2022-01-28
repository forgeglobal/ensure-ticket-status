FROM ruby:2.7

RUN ls ~
COPY src /usr
WORKDIR /usr/src
RUN bundle install

RUN pwd
# For github docker action workdir will be '--workdir /github/workspace'
ENTRYPOINT ["bash", "~/entrypoint.sh"]
