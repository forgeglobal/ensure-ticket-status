FROM ruby:2.7

COPY src /usr
WORKDIR /usr/src
RUN bundle install

# For github docker action workdir will be '--workdir /github/workspace'
ENTRYPOINT ["bash", "/usr/src/entrypoint.sh"]
