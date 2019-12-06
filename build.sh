#!/bin/bash
set -e

export PATH="/home/valdikss/mobile-modem-router/e5372/kernel/gcc-linaro-4.9.4-2017.01-x86_64_arm-linux-gnueabi/bin:$PATH"
# Set your OpenSSL path here
OPENSSL_PATH="/home/valdikss/mobile-modem-router/openssl/git/openssl"
ZLIB_PATH="/home/valdikss/mobile-modem-router/zlib/git/zlib"

mkdir -p installed/huawei/{vfp3,novfp} || true


# Balong Hi6921 V7R11 (E3372h, E5770, E5577, E5573, E8372, E8378, etc) and Hi6930 V7R2 (E3372s, E5373, E5377, E5786, etc)
# softfp, vfpv3-d16 FPU
export CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -O2 -s"
export PKG_CONFIG_PATH="$OPENSSL_PATH/installed/huawei/vfp3/lib/pkgconfig/:$ZLIB_PATH/installed/huawei/vfp3/lib/pkgconfig/"

make clean || true
./configure --host=arm-linux-gnueabi \
 --disable-ares --disable-libcurl-option \
 --enable-ipv6 \
 --prefix="$PWD/installed/huawei/vfp3" \
 --with-ssl="$OPENSSL_PATH/installed/huawei/vfp3" \
 --with-zlib="$ZLIB_PATH/installed/huawei/vfp3" \
 --with-ca-bundle=/etc/ssl/cert.pem \
 --enable-http --enable-ftp --enable-file --disable-ldap --disable-ldaps \
 --disable-rtsp --enable-proxy --disable-dict --disable-telnet --disable-tftp \
 --disable-pop3 --disable-imap --disable-smb --disable-smtp --disable-gopher \
 --enable-manual --enable-verbose --disable-ntlm-wb --disable-tls-srp \
 --enable-cookies --enable-http-auth --enable-progress-meter
make curl_LDFLAGS="-static" "$@"
make install

patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/vfp3/bin/curl

# Balong Hi6920 V7R1 (E3272, E3276, E5372, etc)
# soft, novfp
export CFLAGS="-march=armv7-a -mfloat-abi=soft -mthumb -O2 -s"
export PKG_CONFIG_PATH="$OPENSSL_PATH/installed/huawei/novfp/lib/pkgconfig/:$ZLIB_PATH/installed/huawei/novfp/lib/pkgconfig/"
make clean || true
./configure --host=arm-linux-gnueabi \
 --disable-ares --disable-libcurl-option \
 --enable-ipv6 \
 --prefix="$PWD/installed/huawei/novfp" \
 --with-ssl="$OPENSSL_PATH/installed/huawei/novfp" \
 --with-zlib="$ZLIB_PATH/installed/huawei/novfp" \
 --with-ca-bundle=/etc/ssl/cert.pem \
 --enable-http --enable-ftp --enable-file --disable-ldap --disable-ldaps \
 --disable-rtsp --enable-proxy --disable-dict --disable-telnet --disable-tftp \
 --disable-pop3 --disable-imap --disable-smb --disable-smtp --disable-gopher \
 --enable-manual --enable-verbose --disable-ntlm-wb --disable-tls-srp \
 --enable-cookies --enable-http-auth --enable-progress-meter
make curl_LDFLAGS="-static" "$@"
make install

patchelf --set-interpreter /system/lib/glibc/ld-linux.so.3 installed/huawei/novfp/bin/curl
