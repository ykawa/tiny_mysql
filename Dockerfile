FROM alpine:3.12

ARG MY_USER_ID=1000
ARG MY_GROUP_ID=1000

SHELL [ "/bin/ash", "-eo", "pipefail", "-c" ]

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY setup.sh /setup.sh
RUN /setup.sh && rm -rf /setup.sh

HEALTHCHECK --start-period=5s CMD [ "pgrep", "mysqld" ]

VOLUME [ "/var/lib/mysql" ]
ENTRYPOINT [ "/docker-entrypoint.sh" ]
EXPOSE 3306
