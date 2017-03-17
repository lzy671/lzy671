#!/bin/bash
# Copyright By Aurore
# 2017.02.08

if [ $(id -u) != "0" ]; then
    echo "You Must Run This Script As ROOT!"
    exit 1
fi

while [ -z ${RegistrationID} ]; do
    read -p "Please Input The Registration ID: " RegistrationID
done

read -p "Please Input Config Dir (Default: /root) : " ConfigDir
if [ -z ${ConfigDir} ]; then
    ConfigDir=/root
fi

read -p "Please Input VPS IP (Default: 0.0.0.0) : " MojoHost
if [ -z ${MojoHost} ]; then
    MojoHost=0.0.0.0
fi

read -p "Please Input Webqq Listen Port (Default: 5000) : " OpenqqPort
if [ -z ${OpenqqPort} ]; then
    OpenqqPort=5000
fi

read -p "Please Input Weixin Listen Port (Default: 3000) : " OpenwxPort
if [ -z ${OpenwxPort} ]; then
    OpenwxPort=3000
fi

yum update
yum -y groupinstall "Development Tools"
yum -y install \
    perl \
    openssl-devel \
    curl \
	cpan \
    make \
    unzip

curl -kL https://cpanmin.us | perl - App::cpanminus
curl -L https://cpanmin.us | perl - -M https://cpan.metacpan.org -n Mojolicious	

cpanm Encode::Locale IO::Socket::SSL Mojolicious

curl -o Mojo-Webqq.zip \
    -L https://github.com/sjdy521/Mojo-Webqq/archive/master.zip
unzip Mojo-Webqq.zip
cd Mojo-Webqq-master
cpanm .
cd ..
rm -rf Mojo-Webqq.zip \
    Mojo-Webqq-master

curl -o Mojo-Weixin.zip \
    -L https://github.com/sjdy521/Mojo-Weixin/archive/master.zip
unzip Mojo-Weixin.zip
cd Mojo-Weixin-master
cpanm .
cd ..
rm -rf Mojo-Weixin.zip \
    Mojo-Weixin-master

cat > ${ConfigDir}/Webqq.pl << EOF
use Mojo::Webqq;

my \$client = Mojo::Webqq -> new(log_encoding=>"utf-8");

\$client -> load("ShowMsg");

\$client -> load(
    "GCM",
    data => {
        api_url => 'https://gcm-http.googleapis.com/gcm/send',
        api_key => 'AIzaSyB18io0hduB_3uHxKD3XaebPCecug27ht8',
        registration_ids => ["${RegistrationID}"],
});
\$client -> load(
    "Openqq",
    data => {
        listen => [{
            host => "${MojoHost}",
            port => ${OpenqqPort}
        },
    ],}
);

\$client -> run();
EOF

cat > ${ConfigDir}/Weixin.pl << EOF
use Mojo::Weixin;

my \$client = Mojo::Weixin -> new(log_encoding=>"utf-8");

\$client -> load("ShowMsg");

\$client -> load(
    "GCM",
    data => {
        api_url => 'https://gcm-http.googleapis.com/gcm/send',
        api_key => 'AIzaSyB18io0hduB_3uHxKD3XaebPCecug27ht8',
        registration_ids => ["${RegistrationID}"],
});
\$client -> load(
    "Openwx",
    data => {
        listen => [{
            host => "${MojoHost}",
            port => ${OpenwxPort}
        },
    ],}
);

\$client -> run();
EOF
