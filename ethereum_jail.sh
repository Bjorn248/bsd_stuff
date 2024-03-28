#!/bin/sh

# just so I remember what I did, for next time...

# install dependencies
pkg install curl llvm17 cmake git vim zsh gmake

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
git checkout v5.1.2

# allow rust to find libclang
git apply /root/test.patch

# build and install
gmake install

# TODO finish this once I have it installed again
# copy binaries to /usr/local/bin
# cp ~/.

# remove dependencies
pkg delete cmake llvm17
pkg autoremove
rustup self uninstall
