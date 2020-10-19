ARG RUBY_VERSION=alpine
ARG APP_PATH=/buildroot
FROM ruby:$RUBY_VERSION as RailsDryBuilder
MAINTAINER c.schweingruber@catatec.ch
ARG APP_PATH=/buildroot
ARG projectname=railsapp

#ARG RAILS_ROOT=/app
ARG BUILD_PACKAGES="build-base curl-dev git"
ARG DEV_PACKAGES="postgresql-dev yaml-dev zlib-dev nodejs yarn"
ARG RUBY_PACKAGES="tzdata"
#ENV RAILS_ENV=production
#ENV NODE_ENV=production
#ENV BUNDLE_APP_CONFIG="$RAILS_ROOT/.bundle"
#WORKDIR $RAILS_ROOT
# install packages
RUN apk update \
    && apk upgrade \
    && apk add --update --no-cache $BUILD_PACKAGES $DEV_PACKAGES $RUBY_PACKAGES
COPY Gemfile* package.json yarn.lock ./
# install rubygem
COPY Gemfile Gemfile.lock $RAILS_ROOT/
RUN bundle config --global frozen 1 \
    && bundle install --without development:test:assets -j4 --retry 3 --path=vendor/bundle \
    # Remove unneeded files (cached *.gem, *.o, *.c)
    && rm -rf vendor/bundle/ruby/2.5.0/cache/*.gem \
    && find vendor/bundle/ruby/2.5.0/gems/ -name "*.c" -delete \
    && find vendor/bundle/ruby/2.5.0/gems/ -name "*.o" -delete
RUN yarn install --production


RUN echo "de_CH.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen de_CH.UTF-8 && \
  /usr/sbin/update-locale LANG=de_CH.UTF-8
ENV LC_ALL de_CH.UTF-8

RUN mkdir $APP_PATH
WORKDIR $APP_PATH
COPY Gemfile /$APP_PATH
RUN bundle install
RUN rails new ${projectname} -d mysql && \
    cd ${projectname} && \
    sed -i "/^gem 'tzinfo-data'/d" Gemfile && \
    sed -i "/^# Windows does not include zoneinfo/d" Gemfile 
RUN cd ${projectname}; echo "gem 'dry_crud'" >> Gemfile; gem install dry_crud; bundle install;

ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION
MAINTAINER c.schweingruber@catatec.ch
ARG APP_PATH=/buildroot
ARG projectname=railsapp


RUN echo "de_CH.UTF-8 UTF-8" > /etc/locale.gen && \
  locale-gen de_CH.UTF-8 && \
  /usr/sbin/update-locale LANG=de_CH.UTF-8
ENV LC_ALL de_CH.UTF-8
COPY --from=RailsDryBuilder /usr/local/bundle /usr/local/bundle
COPY --from=RailsDryBuilder /buildroot/${projectname} /${projectname}
ADD startup.sh /${projectname}
RUN chmod 755  /${projectname}/startup.sh
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
#ENV EXECJS_RUNTIME Disabled
EXPOSE 3000
RUN date -u > /${projectname}/BUILD_TIME
WORKDIR /${projectname}
CMD ["./startup.sh"]
