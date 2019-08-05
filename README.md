# 1. Setup toolchain

## macOS

```bash
sudo xcode-select --install
sudo DevToolsSecurity -enable
brew install xz wget cmake clang-format
```

## CentOS

```shell
sudo yum install -y xz gcc wget libuuid-devel ncurses-devel readline-devel
source toolchain-clang-x86_64-Linux.sh
```

## SUSE

```shell
sudo zypper install -y xz gcc wget libuuid-devel ncurses-devel readline-devel
source toolchain-clang-x86_64-Linux.sh
```

## Ubuntu

```shell
sudo apt-get install -y make gawk gcc wget
sudo apt-get install -y xz-utils uuid-dev libncurses5-dev libreadline-dev
source toolchain-clang-x86_64-Linux.sh
```

# 2. Install thirdparty

> You got two options listed below.

## Ask package from others(Recommended)

Nowadays building the thirdparty from source code takes really a long time, you are recomended to take the corresponding `dependency-*.tar.gz` from other experienced developer or [download it in here](http://yum.oushu-tech.com/oushurepo/yumrepo/internal/linux/toolchain/). That is to say

```bash
mkdir -p /opt/
tar -xf dependency-*.tar.gz -C /opt/
source /opt/dependency-*/package/env.sh
# The asterisk stands for the tarball you need to download,
# which is the folder that you get after extracting the tarball.
# Do not exectute this command directly.

git clone https://github.com/oushu-io/libhdfs3.git
cd libhdfs3 && make
```
Note that libcurl in dependency-Darwin was built without rpath specified, you need to make sure the name is exactly `dependency-Darwin` on Mac. Of course you can use symbolic link to workaround it.

## Build thirdparty from source code(Takes around 1 hour)

```bash
mkdir -p /opt/dependency

# When the source code tarballs have no updates, it is fine to do it only once.
make download-src

export PREFIX=/opt/dependency/package     # specify the install prefix if needed
make check-target-dir
make -j8 build-hawq-dep
# The Makefile has been carefully tested for both
# target dependencies order and parallel execution.
# Feel free to specify arbitary number of jobs.

make -j8 build-lldb     # optional, only available on Linux

source $PREFIX/env.sh

git clone https://github.com/oushu-io/libhdfs3.git
cd libhdfs3 && make
```

# 3. Guideline on adding new module
> Take adding `krb5-1.15.4` for example. Surely you are supposed to be familiar with Makefile.

1. Download `krb5-1.15.4.tar.gz` from official website https://web.mit.edu/kerberos/dist/. And upload it to `REPO = yum.oushu-tech.com/oushurepo/yumrepo/internal/linux/thirdparty`.

2. Add entry in section  `Setup target module version`

	> The version name should be idential to the extracted directory name, which determines the following `SOURCE` and `BUILD` variable.

	```makefile
	kerberos5_version=krb5-1.15.4
	```

3. Add entry in section `Setup dependencies build targets`

	```makefile
	build-krb5: \
	$(VERSION_HOME)/$(kerberos5_version)
	$(VERSION_HOME)/$(kerberos5_version): $(VERSION_HOME)/$(openssl_version) \
	                                      $(VERSION_HOME)/$(bison_version)
		@echo "build $(SOURCE)" && rm -rf $(BUILD) && mkdir -p $(BUILD)
		cd $(BUILD) && \
		$(SOURCE)/src/configure --prefix=$(PREFIX) \
			--disable-pkinit \
			LDFLAGS=-L$(PREFIX)/lib \
		&& $(MAKE) && $(MAKE) install
		touch $@
	```

4. Add entry in section `Setup default build target`

	```makefile
	build-hawq-dep: build-krb5
	```

5. Add optional patch

      Edit target `patch` and check in patch file into repo.

    ```makefile
    patch:
    	cd $(SOURCE_HOME)/$(libgsasl_version) && patch -p1 -i privacy.patch
    	cd $(SOURCE_HOME)/$(libgsasl_version) && patch -p1 -i qop.patch
    ```

    

