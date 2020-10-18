FROM ruby:2.7.1 as RailsDryBuilder
MAINTAINER c.schweingruber@catatec.ch
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends build-essential \
    apt-transport-https curl ca-certificates gnupg2 apt-utils && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash -  && \
  apt-get update -qq && apt-get install -y --no-install-recommends nodejs mariadb-client vim && \
  apt-get install -y yarn && \
  apt-get install -y imagemagick && \
  apt-get install -y libvips-tools && \
  apt-get install -y locales

RUN echo "de_CH.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen de_CH.UTF-8 && \
  /usr/sbin/update-locale LANG=de_CH.UTF-8
ENV LC_ALL de_CH.UTF-8

ENV APP_PATH=/buildroot
RUN mkdir $APP_PATH
WORKDIR $APP_PATH
#COPY Gemfile /$APP_PATH
#RUN bundle install
ENV projectname=railsapp
RUN rails new ${projectname} -d mysql && \
    sed -i "/^gem 'tzinfo-data'/d" Gemfile && \
    sed -i "/^# Windows does not include zoneinfo/d" Gemfile 
RUN cd ${projectname}; echo "gem 'dry_crud'" >> Gemfile; gem install dry_crud; bundle install;

FROM ruby:2.7.1
RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends build-essential \
    apt-transport-https curl ca-certificates gnupg2 apt-utils && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash -  && \
  apt-get update -qq && apt-get install -y --no-install-recommends nodejs mariadb-client vim && \
  apt-get install -y yarn && \
  apt-get install -y imagemagick && \
  apt-get install -y libvips-tools && \
  apt-get install -y locales

RUN echo "de_CH.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen de_CH.UTF-8 && \
  /usr/sbin/update-locale LANG=de_CH.UTF-8
ENV LC_ALL de_CH.UTF-8
#ARG projectname
COPY --from=RailsDryBuilder /usr/local/bundle /usr/local/bundle
COPY --from=RailsDryBuilder /app/${projectname} /${projectname}
ADD startup.sh /${projectname}
RUN chmod 755  /${projectname}/startup.sh
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
#ENV EXECJS_RUNTIME Disabled
EXPOSE 3000
RUN date -u > /${projectname}/BUILD_TIME
WORKDIR ${projectname}
CMD ["./startup.sh"]
