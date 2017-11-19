FROM lsiobase/alpine:3.6
LABEL Author cossacksman

# set version label
ARG BUILD_DATE
ARG VERSION

# environment variables
ENV HOME="/server" \
SERVER="/server/minetest" \
MINETEST_SUBGAME_PATH="/server/minetest/games"

# build variables
ARG LDFLAGS="-lintl"

# Create server directory 
RUN mkdir -p server/minetest

# install build packages
RUN \
 apk add --no-cache --virtual=build-dependencies \
	bzip2-dev \
	cmake \
	curl-dev \
	doxygen \
	g++ \
	gcc \
	gettext-dev \
	git \
	gmp-dev \
	hiredis-dev \
	icu-dev \
	irrlicht-dev \
	libjpeg-turbo-dev \
	libogg-dev \
	libpng-dev \
	libressl-dev \
	libtool \
	libvorbis-dev \
	luajit-dev \
	make \
	mesa-dev \
	openal-soft-dev \
	python-dev \
	sqlite-dev && \

apk add --no-cache --virtual=build-dependencies \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	leveldb-dev && \

# install runtime packages
 apk add --no-cache \
	curl \
	gmp \
	hiredis \
	libgcc \
	libintl \
	libstdc++ \
	luajit \
	lua-socket \
	sqlite \
	sqlite-libs && \

apk add --no-cache \
	--repository http://nl.alpinelinux.org/alpine/edge/testing \
	leveldb && \

# compile spatialindex
 git clone https://github.com/libspatialindex/libspatialindex /tmp/spatialindex && \
 cd /tmp/spatialindex && \
 cmake . \
	-DCMAKE_INSTALL_PREFIX=/usr && \
 make && \
 make install && \

# compile minetestserver
 git clone --depth 1 https://github.com/minetest/minetest.git /server/minetest && \
 cp /server/minetest/minetest.conf.example ${SERVER}/minetest.conf && \
 cd /server/minetest && \
 cmake . \
	-DBUILD_CLIENT=0 \
	-DBUILD_SERVER=1 \
	-DENABLE_CURL=1 \
	-DENABLE_LEVELDB=1 \
	-DENABLE_LUAJIT=1 \
	-DENABLE_REDIS=1 \
	-DENABLE_SOUND=0 \
	-DENABLE_SYSTEM_GMP=1 \
	-DRUN_IN_PLACE=1 && \
 make && \
 make install && \

# fetch additional game from git
 git clone --depth 1 https://github.com/minetest/minetest_game.git /server/minetest/games && \

# cleanup
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

# ports and volumes
EXPOSE 30000/udp