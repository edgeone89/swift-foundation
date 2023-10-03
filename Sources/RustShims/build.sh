#!/bin/bash
echo "working dir:"
pwd

echo "cpu arch:"
echo $2

echo "os:"
echo $3

export PATH=$PATH:/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin

export CARGO_HOME=/mnt/ext/etc/.cargo
PATH=$PATH:$CARGO_HOME/bin

export RUSTUP_HOME=/mnt/ext/etc/.rustup
PATH=$PATH:$RUSTUP_HOME

export RUST_SRC_PATH=/mnt/ext/etc/projects/rust_projects/rust/src
PATH=$PATH:$RUST_SRC_PATH

rustup override set nightly
rustup target add $2-$3

cargo -Z unstable-options -C $1 build --release --target $2-$3

cp $1/target/$2-$3/release/*.a $1/
