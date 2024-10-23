FROM python:3.11-slim as dependencies

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install libpq-dev build-essential git -y --no-install-recommends \
    && apt-get -y clean \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt

COPY requirements/base.txt /requirements/
RUN pip install --no-warn-script-location --no-cache-dir --prefix=/install -r /requirements/base.txt


FROM python:3.11-slim AS runtime

ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH "${PYTHONPATH}:/${PWD}"

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install libpq-dev netcat-openbsd tzdata -y --no-install-recommends \
    && apt-get -y clean \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apt

ENV TZ America/Mexico_City
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copy dependencies
COPY --from=dependencies /install/bin /usr/local/bin
COPY --from=dependencies /install/lib /usr/local/lib

COPY app /app

WORKDIR /app

FROM runtime AS development

COPY scripts/entrypoint.sh scripts/start-receiver-dev.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/start-receiver-dev.sh" ]

FROM runtime AS production

COPY scripts/entrypoint.sh scripts/start-receiver-prod.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/start-receiver-prod.sh" ]
