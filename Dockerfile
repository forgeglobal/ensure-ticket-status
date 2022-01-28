FROM ruby:2.7

COPY src /usr
WORKDIR /usr/src
RUN bundle install


ENTRYPOINT ["bash", "/src/entrypoint.sh"]