FROM ruby:2.7

COPY src /home/runner
WORKDIR /home/runner
RUN bundle install

# For github docker action workdir will be '--workdir /github/workspace'
ENTRYPOINT ["bash", "/home/runner/entrypoint.sh"]
