FROM elixir:1.8.1
MAINTAINER Chris McGrath <chris@chrismcg.com>

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2019-04-06.1 \
  APP_ROOT=/opt/app \
  UID=1000 \
  GID=1000 \
  # Set this so that CTRL+G works properly
  TERM=xterm

# create default user with same UID/GID as on host
# so can create files without problems
RUN \
  useradd -u "${UID}" -G root -m default && \
  mkdir -p "${APP_ROOT}" && \
  chown -R "${UID}:${GID}" "${APP_ROOT}"

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

USER default

RUN mix local.hex --force && mix local.rebar --force

COPY --chown=default:default mix.* "${APP_ROOT}/"
WORKDIR "${APP_ROOT}"
RUN mix deps.get && mix deps.compile

COPY --chown=default:default assets/package.json assets/yarn.lock "${APP_ROOT}/assets/"
WORKDIR "${APP_ROOT}/assets"
RUN ls -la "${APP_ROOT}/assets" && yarn install

COPY --chown=default:default . "${APP_ROOT}"

WORKDIR "${APP_ROOT}"
CMD ["mix", "phx.server"]
