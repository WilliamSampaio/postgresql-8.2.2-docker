FROM gebi/debian-vintage:lenny

COPY sources.list /etc/apt/
ADD postgresql-8.2.2.tar.gz .

RUN apt-get update

RUN apt-get install -y --allow-unauthenticated --no-install-recommends \
    locales

RUN echo 'pt_BR.UTF-8 UTF-8' >> /etc/locale.gen; \
    locale-gen; \
    locale -a | grep 'pt_BR.utf8'

ENV LANG pt_BR.utf8

RUN apt-get install -y --allow-unauthenticated \
    build-essential \
    libreadline-dev \
    zlib1g-dev \
    iputils-ping

RUN groupadd -r postgres --gid=999; \
    useradd -r -g postgres --uid=999 --home-dir=/usr/local/pgsql --shell=$(which bash) postgres;

RUN cd postgresql-8.2.2 \
    && ./configure \
    && make \
    && make install


RUN mkdir /usr/local/pgsql/data
RUN chown postgres /usr/local/pgsql/data

USER postgres
ENV PATH    $PATH:/usr/local/pgsql/bin
ENV PGDATA  /usr/local/pgsql/data

RUN initdb

COPY --chown=postgres:postgres conf/pg_hba.conf        ${PGDATA}
COPY --chown=postgres:postgres conf/postgresql.conf    ${PGDATA}

EXPOSE 5432
CMD ["postgres"]
