#!/bin/sh

# just so I remember what I did, for next time...

# install dependencies
pkg install curl llvm cmake git vim zsh gmake compiler-rt py39-supervisor

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# clone lighthouse
git clone https://github.com/sigp/lighthouse.git

# edit Makefile
cat << 'EOF' > /root/lighthouse.patch
diff --git a/Makefile b/Makefile
index 6b6418cb8..fb7a5b19f 100644
--- a/Makefile
+++ b/Makefile
@@ -48,7 +48,7 @@ CARGO_INSTALL_EXTRA_FLAGS?=
 #
 # Binaries will most likely be found in `./target/release`
 install:
-       cargo install --path lighthouse --force --locked \
+       LIBCLANG_PATH="/usr/local/llvm17/lib" cargo install --path lighthouse --force --locked \
                --features "$(FEATURES)" \
                --profile "$(PROFILE)" \
                $(CARGO_INSTALL_EXTRA_FLAGS)
EOF

cd lighthouse
# checkout the tag we want to build
git checkout v5.3.0

# allow rust to find libclang
git apply /root/lighthouse.patch

# build and install
gmake install

cd ..

pkg install curl llvm cmake git vim zsh gmake compiler-rt py39-supervisor

git clone git@github.com:ethereum/go-ethereum.git

cd go-ethereum

git checkout v1.14.8

gmake all

cd ..

cp ~/.cargo/bin/lighthouse /usr/local/sbin/lighthouse
cp build/bin/geth /usr/local/sbin/geth
