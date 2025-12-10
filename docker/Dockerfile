# Build Stage
FROM alpine:3.19 AS builder

# Version variables
ENV NGINX_VERSION=1.24.0
ENV MODSEC_VERSION=v3.0.12
ENV MODSEC_NGINX_VERSION=v1.0.3
ENV OWASP_CRS_VERSION=v4.0.0

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    curl \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    libmaxminddb-dev \
    lmdb-dev \
    yajl-dev \
    automake \
    autoconf \
    libtool

WORKDIR /build

# 1. Clone & Build ModSecurity (Libmodsecurity)
RUN git clone --depth 1 -b ${MODSEC_VERSION} --recurse-submodules https://github.com/SpiderLabs/ModSecurity.git \
    && cd ModSecurity \
    && ./build.sh \
    && ./configure --with-lmdb \
    && make -j$(nproc) \
    && make install

# 2. Clone ModSecurity-nginx Connector
RUN git clone --depth 1 -b ${MODSEC_NGINX_VERSION} https://github.com/SpiderLabs/ModSecurity-nginx.git

# 3. Download & Build NGINX
RUN curl -fSL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -o nginx.tar.gz \
    && tar -zxC /build -f nginx.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-compat \
    --with-file-aio \
    --with-http_v2_module \
    --add-dynamic-module=../ModSecurity-nginx \
    && make -j$(nproc) \
    && make install

# 4. Download OWASP CRS
RUN git clone --depth 1 -b ${OWASP_CRS_VERSION} https://github.com/coreruleset/coreruleset.git /usr/local/owasp-crs

# Final Stage
FROM alpine:3.19

# Install runtime dependencies
RUN apk add --no-cache \
    openssl \
    pcre \
    zlib \
    libxml2 \
    libxslt \
    gd \
    geoip \
    libmaxminddb \
    lmdb \
    yajl \
    libstdc++ \
    tzdata \
    curl

# Create nginx user/group
RUN addgroup -S nginx && adduser -S -D -H -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

# Copy compiled artifacts
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib/nginx/modules /usr/lib/nginx/modules
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/local/modsecurity /usr/local/modsecurity
COPY --from=builder /usr/local/owasp-crs /etc/nginx/modsecurity/owasp-crs

# Setup directories
RUN mkdir -p /var/log/nginx \
    && mkdir -p /var/cache/nginx/client_temp \
    && mkdir -p /var/cache/nginx/proxy_temp \
    && mkdir -p /var/cache/nginx/fastcgi_temp \
    && mkdir -p /var/cache/nginx/uwsgi_temp \
    && mkdir -p /var/cache/nginx/scgi_temp \
    && mkdir -p /etc/nginx/modsecurity \
    && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx \
    && chown -R nginx:nginx /etc/nginx

# Setup healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
