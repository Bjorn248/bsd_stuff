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
git checkout v5.1.2

# allow rust to find libclang
git apply /root/lighthouse.patch

# build and install
gmake install

cd ..

git clone https://github.com/paradigmxyz/reth.git

# create reth patch
cat << 'EOF' > /root/reth.patch
diff --git a/Makefile b/Makefile
index c8adf4ff9..b683fe381 100644
--- a/Makefile
+++ b/Makefile
@@ -45,7 +45,7 @@ help: ## Display this help.

 .PHONY: install
 install: ## Build and install the reth binary under `~/.cargo/bin`.
-       cargo install --path bin/reth --bin reth --force --locked \
+       RUSTFLAGS="-C link-arg=-lgcc -Clink-arg=-static-libgcc" cargo install --path bin/reth --bin reth --force --locked \
                --features "$(FEATURES)" \
                --profile "$(PROFILE)" \
                $(CARGO_INSTALL_EXTRA_FLAGS)
diff --git a/bin/reth/Cargo.toml b/bin/reth/Cargo.toml
index 4e138e9cd..73c999467 100644
--- a/bin/reth/Cargo.toml
+++ b/bin/reth/Cargo.toml
@@ -67,7 +67,7 @@ confy.workspace = true
 toml = { workspace = true, features = ["display"] }

 # metrics
-metrics-process = "=1.0.14"
+metrics-process = { version = "1.2.1", features = ["dummy"] }

 # test vectors generation
 proptest.workspace = true
diff --git a/crates/node-core/Cargo.toml b/crates/node-core/Cargo.toml
index 7dfaa9c44..d2115c33b 100644
--- a/crates/node-core/Cargo.toml
+++ b/crates/node-core/Cargo.toml
@@ -51,7 +51,7 @@ tokio.workspace = true
 metrics-exporter-prometheus = "0.12.1"
 once_cell.workspace = true
 metrics-util = "0.15.0"
-metrics-process = "=1.0.14"
+metrics-process = { version = "1.2.1", features = ["dummy"] }
 metrics.workspace = true
 reth-metrics.workspace = true

EOF

cd reth

git checkout v0.2.0-beta.5

git apply /root/reth.patch

gmake install

cd ..

cp ~/.cargo/bin/lighthouse /usr/local/sbin
cp ~/.cargo/bin/reth /usr/local/sbin
