echo "Building Kissb"

mkdir src
pushd src
wget https://kissb.s3.de.io.cloud.ovh.net/kissb/dev/dist-20240703.zip -O dist-20240703.zip
unzip dist-20240703.zip
popd

mkdir -p out/lib/kissb
rm -Rf out/lib/kissb
cp -Rf src/kissb-20240703 out/lib/kissb