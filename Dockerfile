FROM elixir:1.7.4
MAINTAINER Chris McGrath <chris@chrismcg.com>

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2018-12-16 \
  # Set this so that CTRL+G works properly
  TERM=xterm

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
  tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  yarn \
  inotify-tools

RUN mix local.hex --force && mix local.rebar --force

COPY mix.* /opt/app/
WORKDIR /opt/app
RUN mix deps.get && mix deps.compile

COPY assets/package.json assets/yarn.lock /opt/app/assets/
WORKDIR /opt/app/assets
RUN yarn install

COPY . /opt/app/

WORKDIR /opt/app
CMD ["iex", "-S", "mix", "phx.server"]
