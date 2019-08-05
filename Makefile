#-------------------------------------------------------------------------------
# Setup toolchain
#-------------------------------------------------------------------------------
PREFIX ?= /opt/dependency/package
CC ?= clang
CXX ?= clang++
CMAKE ?= cmake

ifeq ($(shell uname), Darwin)
NPROC ?= $(shell sysctl -n hw.ncpu)
endif
ifeq ($(shell uname), Linux)
NPROC ?= $(shell nproc)
endif
NPROC ?= 4

$(info Platform: $(shell uname))
$(info CC: $(shell $(CC) --version))
$(info CXX: $(shell $(CXX) --version))
$(info MAKE: $(shell $(MAKE) --version))
$(info CMAKE: $(shell $(CMAKE) --version))
$(info NPROC: $(NPROC))

ifeq ($(shell uname),Darwin)
export MACOSX_DEPLOYMENT_TARGET := 10.12
LD_LIB_PATH_NAME=DYLD_FALLBACK_LIBRARY_PATH
CC = clang
CXX = clang++
else
LD_LIB_PATH_NAME=LD_LIBRARY_PATH
endif

export PATH := $(PREFIX)/bin:$(PREFIX)/sbin:$(PATH)
export $(LD_LIB_PATH_NAME):=$(PREFIX)/lib:$($(LD_LIB_PATH_NAME))

export CPPFLAGS := -I$(PREFIX)/include $(CPPFLAGS)
export LDFLAGS := -L$(PREFIX)/lib $(LDFLAGS)
export CFLAGS := $(CFLAGS) -w -O3     # Disable diagnostics for speedup
export CXXFLAGS := $(CXXFLAGS) -w -O3

unexport M4
unexport BISON_PKGDATADIR
unexport PERL5LIB

SOURCE_HOME := $(shell sh -c pwd)/src
BUILD_HOME := $(shell sh -c pwd)/build
PATCH_HOME := $(shell sh -c pwd)/patch
VERSION_HOME := $(PREFIX)/version

SOURCE = $(SOURCE_HOME)/$(notdir $@)
BUILD = $(BUILD_HOME)/$(notdir $@)



#-------------------------------------------------------------------------------
# Setup default build target
#-------------------------------------------------------------------------------
all: help

check-target-dir:
	@echo "check target directory "$(PREFIX)
	@if [ ! -d "$(PREFIX)" ]; then mkdir -p $(PREFIX); fi
	@if [ ! -d "$(PREFIX)/bin" ]; then mkdir -p $(PREFIX)/bin; fi
	@if [ ! -d "$(PREFIX)/lib" ]; then mkdir -p $(PREFIX)/lib; fi
	@if [ ! -d "$(PREFIX)/lib64" ]; then ln -s lib $(PREFIX)/lib64; fi
	@if [ ! -d "$(VERSION_HOME)" ]; then mkdir -p $(VERSION_HOME); fi
	@if [ ! -d "$(SOURCE_HOME)" ]; then mkdir -p $(SOURCE_HOME); fi
	@if [ ! -d "$(BUILD_HOME)" ]; then mkdir -p $(BUILD_HOME); fi

cleanup:
	@rm -rf $(PREFIX)/*

REPO = yumazure.oushu-tech.com:12000/oushurepo/yumrepo/internal/linux/thirdparty
download-src:
	@wget -nc --progress=bar:force --recursive --no-parent --accept *.tar.*,*.tgz http://$(REPO)/
	make extract-src

extract-src: check-target-dir
	cd $(REPO) && \
	for file in `ls *`; \
	do \
		echo "Extracting $$file ..."; \
		tar xf "$$file" -C $(SOURCE_HOME); \
	done
	make patch-src

build-hornet-dep: check-target-dir \
	build-lcov build-cpplint \
	build-cogapp build-thrift build-protobuf build-sofa-pbrpc \
	build-glog build-googletest build-jsoncpp \
	build-libiconv build-rocksdb build-zookeeper \
	build-aws-sdk-cpp \
	build-gperftools build-uuid build-pcre2 build-orc build-stxxl
	make env

build-hawq-dep: check-target-dir \
	build-hornet-dep \
	build-zlib build-bzip2 \
	build-jsonc build-perl-json \
	build-curl build-sed build-python \
	build-apr build-gperf build-dbgen \
	build-libyaml build-libevent build-libedit \
	build-openldap build-libyarn
	make env

build-apache-hawq-dep: check-target-dir \
	build-zlib build-bzip2 build-snappy \
	build-thrift \
	build-jsonc build-perl-json \
	build-curl build-sed build-python \
	build-apr build-gperf build-dbgen \
	build-libyaml build-libxml2 build-libevent build-libedit \
	build-openldap build-krb5 build-libgsasl build-uuid
	make env



#-------------------------------------------------------------------------------
# Setup target module version
#-------------------------------------------------------------------------------
pcre2_version=pcre2-10.34
m4_version=m4-1.4.18
autoconf_version=autoconf-2.69
automake_version=automake-1.15
libtool_version=libtool-2.4.6

stxxl_version=stxxl-1.4.1
boost_version=boost_1_56_0
gflags_version=gflags-2.2.1
glog_version=glog-0.3.5
googletest_version=googletest-release-1.10.0

lz4_version=lz4-1.7.5
zlib_version=zlib-1.2.11
zstd_version=zstd-1.4.4
bzip2_version=bzip2-1.0.6
snappy_version=snappy-1.1.7

bison_version=bison-2.7.1
flex_version=flex-2.6.4

cogapp_version=cogapp-2.5.1
thrift_version=thrift-0.10.0
protobuf_version=protobuf-3.6.1
sofa_pbrpc_version=sofa-pbrpc-1.1.3

jsonc_version=json-c-0.12
jsoncpp_version=jsoncpp-1.7.7
perl_json_version=JSON-2.97001

gettext_version=gettext-0.19.8.1
libiconv_version=libiconv-1.15
rocksdb_version=rocksdb-5.12.4
gperftools_version=gperftools-2.7
zookeeper_version=zookeeper-Capi-3.5.3

sed_version=sed-4.5
curl_version=curl-7.62.0
perl_version=perl-5.28.0
python_version=Python-2.7.15
python_six_version=six-1.12.0

ifeq ($(shell uname), Darwin)
uuid_version=uuid-1.6.2
endif
ifeq ($(shell uname), Linux)
uuid_version=util-linux-2.34
endif
openssl_version=openssl-1.0.2p
kerberos5_version=krb5-1.15.4
cyrus_sasl_version=cyrus-sasl-2.1.26
openldap_version=openldap-2.4.46
pcre2_version=pcre2-10.34

apr_version=apr-1.6.5
gperf_version=gperf-3.1
dbgen_version=dbgen-2.4.0
libxml2_version=libxml2-2.9.8
libyaml_version=yaml-0.2.1
libevent_version=libevent-2.1.8-stable
libedit_version=libedit-20191231-3.1
libgsasl_version=libgsasl-1.8.0
libyarn_version=libyarn-1.0.0

swig_version=swig-4.0.1
lldb_version=lldb-8.0.1.src
lcov_version=lcov-1.13
cpplint_version=cpplint-1.3.0

cmake_version=cmake-3.15.3
gcc_version=gcc-9.2.0

orc_version=orc-1.6.3-patch6
aws_sdk_cpp_version=aws-sdk-cpp-1.8.76



#-------------------------------------------------------------------------------
# Setup dependencies build targets
#-------------------------------------------------------------------------------
patch-src:
	cd $(SOURCE_HOME)/$(lcov_version) && patch -p1 -i a5dd9529f9232b8d901a4d6eb9ae54cae179e5b3.patch
	cd $(SOURCE_HOME)/$(libgsasl_version) && patch -p1 -i privacy.patch
	cd $(SOURCE_HOME)/$(libgsasl_version) && patch -p1 -i qop.patch
	cd $(SOURCE_HOME)/$(sofa_pbrpc_version) && patch -p2 -i thread_group_impl.h.patch
	cd $(SOURCE_HOME)/$(sofa_pbrpc_version) && patch -p1 -i aarch64.patch
	cd $(SOURCE_HOME)/$(sofa_pbrpc_version) && patch -p1 -i spin_lock.h.patch
	cd $(SOURCE_HOME)/$(perl_version) && patch -p1 -i macos_install_name.patch
	rm -rf $(SOURCE_HOME)/$(orc_version)
	mv $(SOURCE_HOME)/$(orc_version:-patch6=) $(SOURCE_HOME)/$(orc_version)
	cd $(SOURCE_HOME)/$(orc_version) && patch -p1 -i $(PATCH_HOME)/$(orc_version:-patch6=)/oushu.patch
ifeq ($(shell uname), Darwin)
	# Fix perl env in lcov
	grep -rl '\#!/usr/bin/perl' $(SOURCE_HOME)/$(lcov_version)/bin/ | xargs /usr/bin/sed -i "" 's|/usr/bin/perl -w|/usr/bin/env perl|'

	# Fix vasnprintf in macOS
	find $(SOURCE_HOME) -name vasnprintf.c | xargs /usr/bin/sed -i "" 's/((defined _WIN32 || defined __WIN32__) && ! defined __CYGWIN__))/(defined __APPLE__ \&\& defined __MACH__) || ((defined _WIN32 || defined __WIN32__) \&\& ! defined __CYGWIN__))/'

	# Apple clang version 12.0.0
	/usr/bin/sed -iorig '195s/:.*/: -w/' $(SOURCE_HOME)/$(boost_version)/tools/build/src/engine/build.jam
	/usr/bin/sed -iorig '212s/"clang.*"/"clang -w"/' $(SOURCE_HOME)/$(boost_version)/tools/build/src/engine/build.sh

	# Discard building existed dependency
	touch $(VERSION_HOME)/$(gperf_version)
	touch $(VERSION_HOME)/$(lldb_version)
endif
ifeq ($(shell uname), Linux)
	cd $(SOURCE_HOME)/$(sofa_pbrpc_version) && sed -i '9,14c \ static const std::string viz_min_js ="";' ./src/sofa/pbrpc/viz_min_js.h
	# Fix perl env in lcov
	grep -rl '\#!/usr/bin/perl' $(SOURCE_HOME)/$(lcov_version)/bin/ | xargs sed -i 's|/usr/bin/perl -w|/usr/bin/env perl|'
endif

build-pcre2: \
$(VERSION_HOME)/$(pcre2_version)
$(VERSION_HOME)/$(pcre2_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) --enable-jit\
	&& $(MAKE) install
	touch $@

build-m4: \
$(VERSION_HOME)/$(m4_version)
$(VERSION_HOME)/$(m4_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-autoconf: \
$(VERSION_HOME)/$(autoconf_version)
$(VERSION_HOME)/$(autoconf_version): $(VERSION_HOME)/$(m4_version) \
                                     $(VERSION_HOME)/$(perl_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-automake: \
$(VERSION_HOME)/$(automake_version)
$(VERSION_HOME)/$(automake_version): $(VERSION_HOME)/$(autoconf_version) \
                                     $(VERSION_HOME)/$(perl_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-libtool: \
$(VERSION_HOME)/$(libtool_version)
$(VERSION_HOME)/$(libtool_version): $(VERSION_HOME)/$(sed_version) \
                                    $(VERSION_HOME)/$(m4_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-stxxl: \
$(VERSION_HOME)/$(stxxl_version)
$(VERSION_HOME)/$(stxxl_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && $(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
	                                  -DCMAKE_BUILD_TYPE=Release \
	                                  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
	                                  -DUSE_GNU_PARALLEL=OFF
	$(MAKE) install -C $(BUILD)
	touch $@

build-boost: \
$(VERSION_HOME)/$(boost_version)
$(VERSION_HOME)/$(boost_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	./bootstrap.sh --with-toolset=$(notdir $(CC)) && \
	./b2 --prefix=$(PREFIX) \
		--build-dir=$(BUILD) \
		--with-system --with-date_time link=static \
		toolset=$(notdir $(CC)) cxxflags="$(CXXFLAGS)" linkflags="$(LDFLAGS)" \
		-j$(NPROC) install
	touch $@

build-gflags: \
$(VERSION_HOME)/$(gflags_version)
$(VERSION_HOME)/$(gflags_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DCMAKE_PREFIX_PATH=$(PREFIX) \
		-DBUILD_SHARED_LIBS=ON \
	&& $(MAKE) install
	touch $@

build-glog: \
$(VERSION_HOME)/$(glog_version)
$(VERSION_HOME)/$(glog_version): $(VERSION_HOME)/$(gflags_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--enable-static=no \
	&& $(MAKE) install
	touch $@

build-googletest: \
$(VERSION_HOME)/$(googletest_version)
$(VERSION_HOME)/$(googletest_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	rm -rf $(PREFIX)/include/gtest $(PREFIX)/include/gmock
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DCMAKE_PREFIX_PATH=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-lz4: \
$(VERSION_HOME)/$(lz4_version)
$(VERSION_HOME)/$(lz4_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && $(MAKE) clean
	cd $(SOURCE) && \
	$(MAKE) install PREFIX=$(PREFIX)
	touch $@

build-zlib: \
$(VERSION_HOME)/$(zlib_version)
$(VERSION_HOME)/$(zlib_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-zstd: \
$(VERSION_HOME)/$(zstd_version)
$(VERSION_HOME)/$(zstd_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && $(MAKE) PREFIX=$(PREFIX) install
	touch $@

build-bzip2: \
$(VERSION_HOME)/$(bzip2_version)
$(VERSION_HOME)/$(bzip2_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	$(MAKE) install PREFIX=$(PREFIX) CC=$(CC) CFLAGS=-fPIC
	touch $@

build-snappy: \
$(VERSION_HOME)/$(snappy_version)
$(VERSION_HOME)/$(snappy_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DCMAKE_PREFIX_PATH=$(PREFIX) \
		-DSNAPPY_BUILD_TESTS=off \
		-DBUILD_SHARED_LIBS=on \
	&& $(MAKE) install
	touch $@

build-bison: \
$(VERSION_HOME)/$(bison_version)
$(VERSION_HOME)/$(bison_version): $(VERSION_HOME)/$(m4_version) \
                                  $(VERSION_HOME)/$(flex_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-flex: \
$(VERSION_HOME)/$(flex_version)
$(VERSION_HOME)/$(flex_version): $(VERSION_HOME)/$(m4_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		CC_FOR_BUILD=$(CC) \
	&& $(MAKE) install
	touch $@

build-cogapp: \
$(VERSION_HOME)/$(cogapp_version)
$(VERSION_HOME)/$(cogapp_version): $(VERSION_HOME)/$(python_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && $(PREFIX)/bin/python setup.py install
	touch $@

build-thrift: \
$(VERSION_HOME)/$(thrift_version)
$(VERSION_HOME)/$(thrift_version): $(VERSION_HOME)/$(autoconf_version) \
                                   $(VERSION_HOME)/$(automake_version) \
                                   $(VERSION_HOME)/$(libtool_version) \
                                   $(VERSION_HOME)/$(boost_version) \
                                   $(VERSION_HOME)/$(bison_version) \
                                   $(VERSION_HOME)/$(flex_version) \
                                   $(VERSION_HOME)/$(openssl_version) 
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cp pkg.m4 $(SOURCE)/aclocal
	cd $(SOURCE) && \
	./bootstrap.sh && ./configure --prefix=$(PREFIX) \
		--with-openssl=$(PREFIX) \
		--disable-static --disable-tests --disable-plugin \
		--with-libevent=no \
	&& $(MAKE) install -C $(SOURCE)/lib/cpp/ \
	&& $(MAKE) install -C $(SOURCE)/compiler/cpp
	touch $@

build-protobuf: \
$(VERSION_HOME)/$(protobuf_version)
$(VERSION_HOME)/$(protobuf_version): $(VERSION_HOME)/$(autoconf_version) \
                                     $(VERSION_HOME)/$(automake_version) \
                                     $(VERSION_HOME)/$(libtool_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && ./autogen.sh
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--enable-static=no \
		CC_FOR_BUILD=$(CC) \
		CXX_FOR_BUILD=$(CXX) \
	&& $(MAKE) install
	touch $@

build-sofa-pbrpc: \
$(VERSION_HOME)/$(sofa_pbrpc_version)
$(VERSION_HOME)/$(sofa_pbrpc_version): $(VERSION_HOME)/$(zlib_version) \
                                       $(VERSION_HOME)/$(snappy_version) \
                                       $(VERSION_HOME)/$(boost_version) \
                                       $(VERSION_HOME)/$(protobuf_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DCMAKE_PREFIX_PATH=$(PREFIX) \
		-DCMAKE_VERBOSE_MAKEFILE=OFF \
	&& $(MAKE) install
	touch $@

build-jsonc: \
$(VERSION_HOME)/$(jsonc_version)
$(VERSION_HOME)/$(jsonc_version): $(VERSION_HOME)/$(autoconf_version) \
                                  $(VERSION_HOME)/$(automake_version) \
                                  $(VERSION_HOME)/$(libtool_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	./autogen.sh && ./configure -prefix=$(PREFIX) \
	&& $(MAKE) && $(MAKE) install
	touch $@

build-jsoncpp: \
$(VERSION_HOME)/$(jsoncpp_version)
$(VERSION_HOME)/$(jsoncpp_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DCMAKE_PREFIX_PATH=$(PREFIX) \
		-DBUILD_SHARED_LIBS=ON \
		-DBUILD_STATIC_LIBS=OFF \
	&& $(MAKE) install
	touch $@

build-perl-json: \
$(VERSION_HOME)/$(perl_json_version)
$(VERSION_HOME)/$(perl_json_version): $(VERSION_HOME)/$(perl_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	$(PREFIX)/bin/perl Makefile.PL \
	&& $(MAKE) install
	touch $@

build-gettext: \
$(VERSION_HOME)/$(gettext_version)
$(VERSION_HOME)/$(gettext_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) && $(MAKE) install
	touch $@

build-libiconv: \
$(VERSION_HOME)/$(libiconv_version)
$(VERSION_HOME)/$(libiconv_version): $(VERSION_HOME)/$(gettext_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) && $(MAKE) install
	touch $@

ifeq ($(shell uname -m), x86_64)
USE_SSE=USE_SSE=1
endif
ifeq ($(notdir $(CXX)), g++)
USE_RTTI=1
else
USE_RTTI=0
endif
build-rocksdb: \
$(VERSION_HOME)/$(rocksdb_version)
$(VERSION_HOME)/$(rocksdb_version): $(VERSION_HOME)/$(lz4_version) \
                                    $(VERSION_HOME)/$(zlib_version) \
                                    $(VERSION_HOME)/$(bzip2_version) \
                                    $(VERSION_HOME)/$(snappy_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	$(MAKE) clean -C $(SOURCE)
	cd $(SOURCE) && \
		EXTRA_CXXFLAGS='$(CPPFLAGS) $(CXXFLAGS) -DLZ4 -DBZIP2 -DZLIB -DSNAPPY' \
		EXTRA_LDFLAGS='$(LDFLAGS) -llz4 -lbz2 -lz -lsnappy' \
		$(USE_SSE) PORTABLE=1 \
		USE_RTTI=$(USE_RTTI) \
	$(MAKE) shared_lib \
	&& $(MAKE) install-shared PORTABLE=1 INSTALL_PATH=$(PREFIX)
	touch $@

build-gperftools: \
$(VERSION_HOME)/$(gperftools_version)
$(VERSION_HOME)/$(gperftools_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
		LIBS=-lpthread $(SOURCE)/configure --prefix=$(PREFIX) --enable-static=false
	cd $(BUILD) && sed 's/-lstdc++//' Makefile > Makefile.tmp && mv Makefile.tmp Makefile
	cd $(BUILD) && $(MAKE) && $(MAKE) install
	touch $@

build-zookeeper: \
$(VERSION_HOME)/$(zookeeper_version)
$(VERSION_HOME)/$(zookeeper_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) && $(MAKE) install
	touch $@

build-sed: \
$(VERSION_HOME)/$(sed_version)
$(VERSION_HOME)/$(sed_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	CFLAGS="$(CFLAGS) -std=gnu99 -fno-builtin" $(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-curl: \
$(VERSION_HOME)/$(curl_version)
$(VERSION_HOME)/$(curl_version): $(VERSION_HOME)/$(openssl_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--with-ssl=$(PREFIX) \
		--without-libidn2 \
	&& $(MAKE) install-exec \
	&& $(MAKE) install -C $(BUILD)/include
	touch $@

build-perl: \
$(VERSION_HOME)/$(perl_version)
$(VERSION_HOME)/$(perl_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	$(MAKE) distclean -C $(SOURCE) || true
	cd $(SOURCE) && \
	$(SOURCE)/Configure -Dprefix=$(PREFIX) \
		-des \
		-Dcccdlflags=-fPIC -Duseshrplib -Dusethreads \
		-Dman1dir=none -Dman3dir=none \
		-Dcc=$(CC) -Dlibs='-lpthread -lm -ldl' \
	&& $(MAKE) -j1 install
	touch $@

ifeq ($(shell uname), Linux)
python_unicode=ucs4
else
python_unicode=ucs2
endif
build-python: \
$(VERSION_HOME)/$(python_version)
$(VERSION_HOME)/$(python_version): $(VERSION_HOME)/$(zlib_version) \
                                   $(VERSION_HOME)/$(openssl_version) \
                                   $(VERSION_HOME)/$(uuid_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--enable-shared \
		--enable-unicode=$(python_unicode) \
		CFLAGS="-fPIC" \
	&& $(MAKE) && $(MAKE) install
	$(MAKE) build-python-six
	touch $@

build-python-six: \
$(VERSION_HOME)/$(python_six_version)
$(VERSION_HOME)/$(python_six_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && $(PREFIX)/bin/python setup.py install
	touch $@

build-uuid: \
$(VERSION_HOME)/$(uuid_version)
$(VERSION_HOME)/$(uuid_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	$(SOURCE)/configure --disable-all-programs --enable-libuuid --prefix=$(PREFIX) \
	&& $(MAKE) && $(MAKE) install
	touch $@

build-openssl: \
$(VERSION_HOME)/$(openssl_version)
$(VERSION_HOME)/$(openssl_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	KERNEL_BITS=64 $(SOURCE)/config --prefix=$(PREFIX) -shared \
	&& $(MAKE) && $(MAKE) install_sw
	touch $@

build-cyrus-sasl: \
$(VERSION_HOME)/$(cyrus_sasl_version)
$(VERSION_HOME)/$(cyrus_sasl_version): $(VERSION_HOME)/$(openssl_version)
ifneq ($(shell uname),Darwin)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--with-openssl=$(PREFIX) \
		--enable-otp=no \
	&& $(MAKE) -j1 install          # There is parallel build issues in cyrus-sasl
endif
	touch $@

build-krb5: \
$(VERSION_HOME)/$(kerberos5_version)
$(VERSION_HOME)/$(kerberos5_version): $(VERSION_HOME)/$(openssl_version) \
                                      $(VERSION_HOME)/$(bison_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/src/configure --prefix=$(PREFIX) \
		--disable-pkinit \
	&& $(MAKE) && $(MAKE) install
	touch $@

build-openldap: \
$(VERSION_HOME)/$(openldap_version)
$(VERSION_HOME)/$(openldap_version): $(VERSION_HOME)/$(openssl_version) \
                                     $(VERSION_HOME)/$(cyrus_sasl_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--enable-slapd=no \
	&& $(MAKE) \
	&& $(MAKE) install -C $(BUILD)/include \
	&& $(MAKE) install -C $(BUILD)/libraries \
	&& $(MAKE) install -C $(BUILD)/clients \
	&& $(MAKE) install -C $(BUILD)/servers
	touch $@

build-pcre2: \
$(VERSION_HOME)/$(pcre2_version)
$(VERSION_HOME)/$(pcre2_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) --enable-jit\
	&& $(MAKE) install
	touch $@

build-apr: \
$(VERSION_HOME)/$(apr_version)
$(VERSION_HOME)/$(apr_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) && $(MAKE) install
	touch $@

build-gperf: \
$(VERSION_HOME)/$(gperf_version)
$(VERSION_HOME)/$(gperf_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-dbgen: \
$(VERSION_HOME)/$(dbgen_version)
$(VERSION_HOME)/$(dbgen_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && $(MAKE)
	cp -r $(SOURCE)/dbgen $(PREFIX)/bin
	cp -r $(SOURCE)/dists.dss $(PREFIX)/bin
	touch $@

build-libxml2: \
$(VERSION_HOME)/$(libxml2_version)
$(VERSION_HOME)/$(libxml2_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--without-lzma \
		--without-python \
		--enable-static=no \
	&& $(MAKE) install-exec \
	&& $(MAKE) install -C $(BUILD)/include
	ln -s libxml2/libxml $(PREFIX)/include/libxml
	touch $@

build-libyaml: \
$(VERSION_HOME)/$(libyaml_version)
$(VERSION_HOME)/$(libyaml_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-libedit: \
$(VERSION_HOME)/$(libedit_version)
$(VERSION_HOME)/$(libedit_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-libevent: \
$(VERSION_HOME)/$(libevent_version)
$(VERSION_HOME)/$(libevent_version): $(VERSION_HOME)/$(openssl_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-libgsasl: \
$(VERSION_HOME)/$(libgsasl_version)
$(VERSION_HOME)/$(libgsasl_version): $(VERSION_HOME)/$(kerberos5_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(SOURCE)/configure --prefix=$(PREFIX) \
		--with-gssapi-impl=mit \
		LIBS=-lcrypto \
		CFLAGS="$(CFLAGS) -fPIC" \
	&& $(MAKE) install
	touch $@

build-libyarn: \
$(VERSION_HOME)/$(libyarn_version)
$(VERSION_HOME)/$(libyarn_version): $(VERSION_HOME)/$(protobuf_version) \
                                    $(VERSION_HOME)/$(kerberos5_version) \
                                    $(VERSION_HOME)/$(libgsasl_version) \
                                    $(VERSION_HOME)/$(libxml2_version) \
                                    $(VERSION_HOME)/$(googletest_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DCMAKE_PREFIX_PATH=$(PREFIX) \
	&& $(MAKE) install
	touch $@

build-swig: \
$(VERSION_HOME)/$(swig_version)
$(VERSION_HOME)/$(swig_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && $(SOURCE)/configure --prefix=$(PREFIX) --without-pcre
	$(MAKE) -C $(BUILD)
	$(MAKE) -C $(BUILD) install
	touch $@

build-lldb: \
$(VERSION_HOME)/$(lldb_version)
$(VERSION_HOME)/$(lldb_version): $(VERSION_HOME)/$(libedit_version) \
                                 $(VERSION_HOME)/$(python_version) \
                                 $(VERSION_HOME)/$(swig_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_PREFIX_PATH=$(PREFIX) \
		-DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
		-DCMAKE_CXX_STANDARD_LIBRARIES="-ltinfo" \
	&& $(MAKE) install
	touch $@

build-cmake: \
$(VERSION_HOME)/$(cmake_version)
$(VERSION_HOME)/$(cmake_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && $(SOURCE)/bootstrap --parallel=$(NPROC) --prefix=$(PREFIX) \
		-- -DCMAKE_BUILD_TYPE:STRING=Release
	$(MAKE) -C $(BUILD)
	$(MAKE) -C $(BUILD) install
	touch $@

build-gcc: \
$(VERSION_HOME)/$(gcc_version)
$(VERSION_HOME)/$(gcc_version):
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && ./contrib/download_prerequisites
	cd $(BUILD) && $(SOURCE)/configure --disable-multilib --enable-languages=c,c++ --prefix=$(PREFIX)
	$(MAKE) -C $(BUILD)
	$(MAKE) -C $(BUILD) install
	touch $@

build-lcov: \
$(VERSION_HOME)/$(lcov_version)
$(VERSION_HOME)/$(lcov_version): $(VERSION_HOME)/$(perl_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(SOURCE) && \
	$(MAKE) install PREFIX=$(PREFIX)
ifeq ($(findstring clang, $(shell $(CC) --version)), clang)
	cp gcov $(PREFIX)/bin/gcov
	chmod a+x $(PREFIX)/bin/gcov
endif
	touch $@

build-cpplint: \
$(VERSION_HOME)/$(cpplint_version)
$(VERSION_HOME)/$(cpplint_version):
	cp $(SOURCE)/cpplint.py $(PREFIX)/bin/cpplint.py
	touch $@

build-orc: \
$(VERSION_HOME)/$(orc_version)
$(VERSION_HOME)/$(orc_version): $(VERSION_HOME)/$(protobuf_version) \
                                $(VERSION_HOME)/$(googletest_version) \
                                $(VERSION_HOME)/$(snappy_version) \
                                $(VERSION_HOME)/$(zstd_version) \
                                $(VERSION_HOME)/$(zlib_version) \
                                $(VERSION_HOME)/$(lz4_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) -DCMAKE_INSTALL_PREFIX=$(PREFIX) \
		-DBUILD_JAVA=OFF \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
		-DPROTOBUF_HOME=$(PREFIX) \
		-DGTEST_HOME=$(PREFIX) \
		-DSNAPPY_HOME=$(PREFIX) \
		-DZSTD_HOME=$(PREFIX) \
		-DZLIB_HOME=$(PREFIX) \
		-DLZ4_HOME=$(PREFIX) \
		-DSTOP_BUILD_ON_WARNING=OFF -DBUILD_CPP_TESTS=OFF
	# LD_PRELOAD for missing pthread linking in protoc-gen-hrpc
	export LD_PRELOAD=/lib64/libpthread.so.0 && \
	$(MAKE) -C $(BUILD) install
	touch $@

build-aws-sdk-cpp: \
$(VERSION_HOME)/$(aws_sdk_cpp_version)
$(VERSION_HOME)/$(aws_sdk_cpp_version): \
                                        $(VERSION_HOME)/$(openssl_version) \
                                        $(VERSION_HOME)/$(curl_version) \
                                        $(VERSION_HOME)/$(zlib_version)
	@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
	# Fix non-portatable cpuid.c's __builtin_cpu_supports requirement.
	sed -i.orig 's/set(AWS_C_COMMON_TAG "v0.4.42")/set(AWS_C_COMMON_TAG "v0.4.46")/' $(SOURCE)/third-party/CMakeLists.txt
	cd $(BUILD) && \
	$(CMAKE) $(SOURCE) \
		-DCMAKE_POSITION_INDEPENDENT_CODE=ON \
		-DCMAKE_INSTALL_PREFIX=$(PREFIX)
	$(MAKE) -C $(BUILD)/aws-cpp-sdk-s3 install
	$(MAKE) -C $(BUILD)/aws-cpp-sdk-core install
	$(MAKE) -C $(BUILD)/aws-cpp-sdk-identity-management install
	touch $@



#-------------------------------------------------------------------------------
# Usage
#-------------------------------------------------------------------------------
help:
	@echo "----------------------------------------------------------"
	@printf "Usage:\n"
	@printf "\t Build all dependencies: \n"
	@printf "\t\tmake build-hawq-dep\n"
	@printf "\n"
	@printf "\t Build individual dependency: \n"
	@printf "\t\tmake build-<module name>\n"
	@printf "\n"
	@printf "\t Modules: \n"
	@printf "\t\t$(MODULE_NAMES)\n"
	@printf "\n"
	@printf "\t Cleanup target directory: \n"
	@printf "\t\tmake cleanup\n"
	@printf "\n"
	@echo "----------------------------------------------------------"

PERL_VERSION=$(perl_version:perl-%=%)
ifeq ($(shell uname), Darwin)
PERL_TARGET=darwin-thread-multi-2level
else
PERL_TARGET=$(shell uname -m)-linux-thread-multi
endif
env:
	@printf "\n"
	@printf "Add the following lines into .bash_profile OR source $(PREFIX)/env.sh\n"
	@printf "\n"
	@echo '#!/bin/sh' > $(PREFIX)/env.sh
	@echo 'export PKG_PATH="$$( cd "$$( dirname "$${BASH_SOURCE[0]-$$0}" )" && pwd )"' >> $(PREFIX)/env.sh
	@echo 'export CMAKE_PREFIX_PATH=$$PKG_PATH' >> $(PREFIX)/env.sh
	@echo 'export PATH=$$PKG_PATH/bin:$$PKG_PATH/sbin:$$PATH' >> $(PREFIX)/env.sh
	@echo 'export CPATH=$$PKG_PATH/include:$$CPATH' >> $(PREFIX)/env.sh
	@echo 'export LIBRARY_PATH=$$PKG_PATH/lib:$$LIBRARY_PATH' >> $(PREFIX)/env.sh
	@echo 'export JAVA_LIBRARY_PATH=$$PKG_PATH/lib:$$JAVA_LIBRARY_PATH' >> $(PREFIX)/env.sh
	@echo 'export $(LD_LIB_PATH_NAME)=$$PKG_PATH/lib:$$$(LD_LIB_PATH_NAME)' >> $(PREFIX)/env.sh
	@echo 'export CPPFLAGS="-I$$PKG_PATH/include $$CPPFLAGS"' >> $(PREFIX)/env.sh
	@echo 'export LDFLAGS="-L$$PKG_PATH/lib $$LDFLAGS"' >> $(PREFIX)/env.sh
	@echo 'export M4=`which m4`' >> $(PREFIX)/env.sh
	@echo 'export BISON_PKGDATADIR=$$PKG_PATH/share/bison/' >> $(PREFIX)/env.sh
	@echo 'export PERL5LIB=$$PKG_PATH/lib/perl5/$(PERL_VERSION)' >> $(PREFIX)/env.sh
	@echo 'export PERL5LIB=$$PKG_PATH/lib/perl5/$(PERL_VERSION)/$(PERL_TARGET):$$PERL5LIB' >> $(PREFIX)/env.sh
	@echo 'export PERL5LIB=$$PKG_PATH/lib/perl5/site_perl/$(PERL_VERSION):$$PERL5LIB' >> $(PREFIX)/env.sh
	@echo 'export PERL5LIB=$$PKG_PATH/lib/perl5/site_perl/$(PERL_VERSION)/$(PERL_TARGET):$$PERL5LIB' >> $(PREFIX)/env.sh
	@echo 'export CPATH=$$PKG_PATH/include/apr-1:$$CPATH' >> $(PREFIX)/env.sh
	@echo 'export $(LD_LIB_PATH_NAME)=$$PKG_PATH/lib/perl5/$(PERL_VERSION)/$(PERL_TARGET)/CORE:$$$(LD_LIB_PATH_NAME)' >> $(PREFIX)/env.sh
	@cat $(PREFIX)/env.sh
