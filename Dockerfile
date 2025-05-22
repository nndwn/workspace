FROM ubuntu:latest

ENV USER_PG=postgre
ENV PWD_PG=postgre
ENV DB_PG=postgre
ENV GOSU_VERSION=1.17
ENV TZ=Asia/Jakarta
ENV DEBIAN_FRONTEND=noninteractive
ENV FNM_DIR=/usr/local/fnm

RUN apt-get update && apt-get install -y \
    postgresql \
    postgresql-contrib \
    git \
    curl \
    unzip \
    wget \
    locales \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone

RUN set -eux; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-$(dpkg --print-architecture)"; \
    chmod +x /usr/local/bin/gosu; \
    gosu nobody true;

RUN if ! getent group postgres; then groupadd -r postgres --gid=999; fi && \
    if ! getent passwd postgres; then useradd -r -g postgres --uid=999 postgres; fi

RUN mkdir -p /docker-entrypoint-initdb.d /var/lib/postgresql/data && \
    chown -R postgres:postgres /docker-entrypoint-initdb.d /var/lib/postgresql/data

RUN curl -fsSL https://fnm.vercel.app/install | bash && \
    export FNM_DIR="$HOME/.local/share/fnm" && \
    export PATH="$FNM_DIR:$PATH" && \
    eval "`fnm env`" && \
    bash -c "source $HOME/.bashrc && fnm install 22 && fnm use 22 && node -v && npm -v"

RUN groupadd -r appuser && useradd -r -g appuser appuser

COPY init-db.sh /docker-entrypoint-initdb.d/init-db.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-db.sh

RUN mkdir -p /app && chown -R appuser:appuser /app
USER appuser
WORKDIR /app

HEALTHCHECK --interval=10s --timeout=5s --retries=3 \
  CMD pg_isready -U $USER_PG -d $DB_PG || exit 1

VOLUME /var/lib/postgresql/data

ENTRYPOINT ["gosu", "postgres", "/docker-entrypoint-initdb.d/init-db.sh"]

CMD ["bash"]
