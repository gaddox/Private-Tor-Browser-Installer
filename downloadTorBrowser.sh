#!/usr/bin/env bash
# Gaddox | February 12th, 2018

## Error handling, so we don't fail silently
set -e -o pipefail

## Reuse queries for simplicity
query_response () {
    if [[ "$ANSWER" == [Yy] ]]; then
	:; 
    else
	exit 1
    fi
}

## If DEBUG != 0, dump all vars
dump () {
    echo "PROG_NAME: $PROG_NAME"
    echo "USER: $USER"
    echo "TEMPDIR: $TEMPDIR"
    echo "HASH_ALL: $HASH_ALL"
    echo "HASH_ALL_ASC: $HASH_ALL_ASC"
    echo "BROWSER: $BROWSER"
    echo "BROWSER_ASC: $BROWSER_ASC"
    echo "SHA_SUM: $SHA_SUM"
    echo "FILE_NAME: $FILE_NAME"
    echo "SIG: $SIG"
    echo "DEV_TEAM_KEY: $DEV_TEAM_KEY"
    echo "TOR_DIRECTORY: $TOR_DIRECTORY"
    echo "USER_AGENT: $USER_AGENT"
    echo "PRE-PROXY: $PRE_PROXY"
    echo "PROXY: $PROXY"
    echo "CIPHER: $CIPHER"
    echo "DNS: $DNS"
    echo "KEY_SERVER: $KEY_SERVER"
    echo "TOR_BROWSER_LINK $TOR_BROWSER_LINK"
    echo "SHA256SUM_LINL: $SHA256SUM_LINK"
    echo "EXPORT_ENV: $EXPORT_ENV"
    echo "ARES_FLAG: $ARES_FLAG"
    echo "PRE_PROXY_FLAG: $PRE_PROXY_FLAG"
    echo "PROXY_FLAG: $PROXY_FLAG"
    echo "CIPHER_FLAG: $CIPHER_FLAG"
    echo "CURL_COMMAND_BASE: $CURL_COMMAND_BASE"
    echo "REPORT_FLAG: $REPORT_FLAG"
    echo "GPG_KEY: $GPG_KEY"
    echo "GPG_HASH: $GPG_HASH"
    echo "MATCH: $MATCH"
    echo "SHA_HASH: $SHA_HASH"
    echo "GPG_BROWSER: $GPG_BROWSER"
    echo "DEBUG: $DEBUG"
    exit 2
}

## Display this if any arguments are passed
help_dialog (){

cat <<EOF
DownloadTorBrowser          General Commands Manual         DownloadTorBrowser

SYNOPSIS
     [ENV_VARIABLE] [ENV_VARIBLE] ./downloadTorBrowser.sh 

DESCRIPTION
     The downloadTorBrowser.sh script securely and privately downloads and 
     verifies the integrity of the latest version of Tor-Browser. It does this
     using a mixture of curl and gpg settings. 

     Options:
     -h
     --help
          Display this help text. Not exactly. Anything passed to the script
	  besides environment variables will trigger this.

     For curl, the full system involves using the ECDHE-RSA-AES256-GCM-SHA384
     cipher for libcurls compiled with OpenSSL, and the equivalent ecdhe_rsa_
     aes_256_gcm_sha_384 for those compiled with NSS, to download the files
     from the TorProject's https://dist.torproject.org over TLS. If libcurl
     was compiled with c-ares, OpenNIC's Brazil DNS server is used instead of
     the ISP/Google default. If proxies are specified, the first hop is 
     started from "pre-proxy" and then to "proxy" and then to the TorProject
     site. The useragent is also spoofed to the most common one. All together
     curl then downloads the hash sums file, it's corresponding PGP key, and
     the latest amd64 en-US Tor-Browser, and it's corresponding PGP key.

     After, GPG downloads the Tor-Browser Team's GPG key from the SKS-Servers
     pool, over the equivalent of HTTPS. If Tor is running on the local
     an onion-routed keyserver can be specified to be used instead. However,
     DNS requests are not routed through Tor for key downloads. Then, GPG
     verifies the signature of the hash sums and the browser. sha256sum also
     verifies the SHA256 checksum of the Tor-Browser. 

     If the user deems the results acceptable, continuing unpacks the tar
     bundle into ~/bin/ and appends the directoy of "start-tor-browser" to
     the .bashrc path. 

ENVIRONMENT
     DEV_TEAM_KEY	The PGP key of the team working on the Tor-Browser.
     			The team regularly changes keys, so a new one may
			need to be specified from https://www.torproject.
			org/docs/signing-keys.html.en

     TOR_DIRECTORY	The directory in which Tor should be installed.
     			Default is ~/bin/

     USER_AGENT		The useragent curl should use. Default is 
     			Mozilla/5.0 (Windows NT 10.0; Win64; x64)
			AppleWebKit/537.36 (KHTML, like Gecko) 
			Chrome/63.0.3239.132 Safari/537.36

     PRE_PROXY		The proxy to use before connecting to the main 
     			proxy. Follows standard Curl usage.

     PROXY		The main proxy to connect to the download site.
     			Follows standard Curl usage.

     CIPHER		The cipher curl should use to communicate with the
     			Tor Project directory over TLS. Default is
			ECDHE-RSA-AES256-GCM-SHA384 for OpenSSL

     DNS		The DNS server curl should use to lookup the Tor
     			Download links.

     KEY_SERVER		Keyserver GPG should use to retrieve the dev key.
     			Default is hkp://pool.sks-keyservers.net
			Onion alternative: hkps://jirk5u4osbsr34t5.onion 
			Via Kristian Fiskerstrand
			The default is not over SSL. If you're using an
			SSL server with a custom certificate, you can
			append the option here too.

     TOR_BROWSER_LINK	Link to the exact Tor-Browser file. Default is
     			https://dist.torproject.org/torbrowser/7.5/tor-
			browser-linux64-7.5_en-US.tar.xz

     SHA256SUM_LINK	Link to the hash sums file. Default is https://
     			dist.torproject.org/torbrowser/7.5/sha256sums-
			signed-build.txt
     
     EXPORT_ENV  	File containing the PATH variable. Default is
     			/home/$USER/.bashrc

     DEBUG		If anything but 0, will run the entire process, 
     			right up to extraction and installation. Then 
			dump all of the variables and exit.

EXAMPLES
     To download and install the Tor-Browser with no proxies or custom DNS:
     
	  $ ./downloadTorBrowser.sh

     To download and install the Tor-browser with both proxies:

     	  $ PRE_PROXY="socks5://255.255.255.255:25555" PROXY="socks4://255.
	    255.255.255.255:25555" ./downloadTorBrowser.sh

CAVEATS
     Security is only as strong as you make it. If you run this with no
     proxies, using Google's DNS, over the clearnet, with a terrible 
     cipher, a unique useragent, and decide to install even when you're
     shown that all the PGP signatures and checksum are bad, that's on you.
     You probably shouldn't be relying on someone else's script to do this
     for you either, but it's open source, small, and documented, so you
     can verify the integrity of it yourself.  

AUTHOR
     Gaddox
           
                               February 12, 2018                               
EOF

exit 0
}

## Main
main () {

    ### Shouldn't be touched unless errors occur
    local readonly PROG_NAME="$(basename $0)";
    local readonly USER="$(whoami)";
    ## Make a tempdir to work in, in /tmp/ and bind it to script
    ## If the script exits for any reason, the temp directory and all of its contents are deleted
    local readonly TEMPDIR=$(mktemp -d "/tmp/$PROG_NAME.XXXXXXX");
    trap 'rm -dRf "$TEMPDIR"' EXIT;
    ## Temp Files to hold multiline variables, it's easier this way
    local readonly HASH_ALL=$(mktemp "$TEMPDIR/HASH_ALL.XXXXXXX");
    local readonly HASH_ALL_ASC=$(mktemp "$TEMPDIR/HASH_ASC.XXXXXXX");
    local readonly BROWSER=$(mktemp "$TEMPDIR/BROWSER.XXXXXXX");
    local readonly BROWSER_ASC=$(mktemp "$TEMPDIR/BROWSER_ASC.XXXXXXX");
    local readonly SHA_SUM=$(mktemp "$TEMPDIR/SHA_SUM.XXXXXXX");
    local readonly FILE_NAME=$(mktemp "$TEMPDIR/FILE_NAME.XXXXXXX");
    local readonly SIG='"Tor Browser Developers (signing key) <torbrowser@torproject.org>"'

    ### All user-defineable vars, defaults are in quotes
    local readonly DEBUG=${DEBUG:=0};
    local readonly DEV_TEAM_KEY=${DEV_TEAM_KEY:='0xD1483FA6C3C07136'};
    local readonly TOR_DIRECTORY=${TOR_DIRECTORY:="/home/$USER/bin/"};
    local readonly USER_AGENT=${USER_AGENT:='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36'};
    local readonly PRE_PROXY=${PRE_PROXY:-}; 
    local readonly PROXY=${PROXY:-};
    local readonly CIPHER=${CIPHER:-};
    ## OpenNIC in Brazil
    local readonly DNS=${DNS:='200.252.98.162'}; 
    ## Tor Alternative: hkp://jirk5u4osbsr34t5.onion via Kristian Fiskerstrand
    local readonly KEY_SERVER=${KEY_SERVER:='hkp://pool.sks-keyservers.net'};
    local readonly TOR_BROWSER_LINK=${TOR_BROWSER_LINK:='https://dist.torproject.org/torbrowser/7.5/tor-browser-linux64-7.5_en-US.tar.xz'};
    local readonly SHA256SUM_LINK=${SHA256SUM_LINK:='https://dist.torproject.org/torbrowser/7.5/sha256sums-signed-build.txt'};
    local readonly EXPORT_ENV=${EXPORT_ENV:="/home/$USER/.bashrc"};
    
    ## If it already exists, continue, else make it
    mkdir -p "$TOR_DIRECTORY"

    ## Check for c-ares lib, not definitive because it can exist and libcurl still not
    ## be compiled with it. Most aren't.
    if [[ "$(ldconfig -p | grep libcares)" != "" ]]; then
	local ARES_FLAG=1;
    else
	local ARES_FLAG=0;
	read -p "Curl was not compiled with c-ares. This will disallow using custom DNS servers. Continue? [Y/n]: " ANSWER
        query_response "$ANSWER"
    fi

    ## Check for OpenSSL or NSS libs
    if [[ "$(ldconfig -p | grep libxmlsec1-openssl)" != "" ]]; then
	local CIPHER_FLAG=1;
	local CIPHER=${CIPHER:="ECDHE-RSA-AES256-GCM-SHA384"};
    elif [[ "$(ldconfig -p | grep libnss3)" != "" ]]; then
	local CIPHER_FLAG=1;
        local CIPHER=${CIPHER:="ecdhe_rsa_aes_256_gcm_sha_384"};
    else
	## You can still use a custom cipher here even if the two checks fail
	read -p "No OpenSSL or NSS detected. Your cipher will be unknown. Continue? [Y/n]: " ANSWER
	query_response "$ANSWER"

    fi

    ## Check for Pre-proxy
    if [[ -z "$PRE_PROXY" ]]; then
	local PRE_PROXY_FLAG=0;
	read -p "No pre-proxy detected. Continue? [Y/n]: " ANSWER
	query_response "$ANSWER"
    else
	local PRE_PROXY_FLAG=1;

    fi

    ## Check for main proxy
    if [[ -z "$PROXY" ]]; then
	local PROXY_FLAG=0;
	read -p "No proxy detected. Continue? [Y/n]: " ANSWER
	query_response "$ANSWER"
    else
	local PROXY_FLAG=1;

    fi

    ## Check if keyserver is an .onion address. Not definitive, can have ".onion" string, but not
    ## be real onion link. 
    if [[ ! "$KEY_SERVER" =~ ".onion" ]]; then
	read -p "Not using an onion hidden key server. Continue? [Y/n]: " ANSWER
	query_response "$ANSWER"
    fi
    
    ## Base curl command that builds using flgs defined above
    ## Cert-status verifies certificate
    ## No-keepalive sends all requests on separate connections
    ## Max-redirs denies redirects
    ## Proto only allows connections through https 
    local CURL_COMMAND_BASE='curl --cert-status --no-keepalive --user-agent '"\"$USER_AGENT\""' --max-redirs 0 --no-sessionid --proto =https'

    ## Build the command
    if [[ $ARES_FLAG -eq 1 ]]; then
	CURL_COMMAND_BASE+=" --dns-servers ""$DNS"
    fi
    
    if [[ $CIPHER_FLAG -eq 1 ]]; then
	CURL_COMMAND_BASE+=" --ciphers ""$CIPHER"
    fi

    if [[ $PRE_PROXY_FLAG -eq 1 ]]; then
	CURL_COMMAND_BASE+=" --preproxy ""$PRE_PROXY"
    fi
    
    if [[ $PROXY_FLAG -eq 1 ]]; then
	CURL_COMMAND_BASE+=" --proxy ""$PROXY"
    fi

    ## Set command read only, otherwise if tampered exit script. Only a fail-safe because we're using
    ## eval and that could cause security problems
    local readonly CURL_COMMAND_BASE=${CURL_COMMAND_BASE:="exit;"};
    eval "$CURL_COMMAND_BASE ""$TOR_BROWSER_LINK" > "$BROWSER"
    eval "$CURL_COMMAND_BASE ""$TOR_BROWSER_LINK"".asc" > "$BROWSER_ASC"
    eval "$CURL_COMMAND_BASE ""$SHA256SUM_LINK" > "$HASH_ALL"
    eval "$CURL_COMMAND_BASE ""$SHA256SUM_LINK"".asc" > "$HASH_ALL_ASC"

    ## Puts all of the outputs to GPG and sha256sum commands into a variable so we can
    ## shorten it to only the meaningful bits, but still have the full output if the user
    ## wants to see them. MATCH is just replacing the original filename in the sums file
    ## with the name of the temp file tor-browser was downloaded to, because sha256sum
    ## checks against that. FILE_NAME is the end of the Tor-Browser link, so we know
    ## which line to modify. 2>&1 because GPG doesn't output everything to stdout.
    ## Most of GPG's output goes to stderr which can be decieving.
    local GPG_KEY="$(gpg --keyserver $KEY_SERVER --recv-key $DEV_TEAM_KEY 2>&1)"
    local GPG_HASH="$(gpg --verify $HASH_ALL_ASC $HASH_ALL  2>&1)"
    local FILE_NAME=$( sed 's/.*\///g' <( echo "$TOR_BROWSER_LINK" ) )
    local MATCH=$(grep "$FILE_NAME" "$HASH_ALL" | sed "s~ $FILE_NAME~$BROWSER~")
    local SHA_HASH=$(sed "s~$BROWSER~sha: Tor-Browser~" <( sha256sum -c <( echo "$MATCH" )))
    local GPG_BROWSER="$(gpg --verify $BROWSER_ASC $BROWSER 2>&1)"

    ## Sed is a hack to imitate read line, because this is simpler
    ## Reads each line, of each output from above, then checks if it contains "$SIG"
    ## Which is just a standrad string all of the outputs have, that also contains
    ## the meaningful pass/fail message.
    sed "s/gpg:/gpg:/g" <( echo "$GPG_KEY" ) | grep "$SIG"
    sed "s/gpg:/gpg:/g" <( echo "$GPG_HASH" ) | grep "$SIG"
    sed "s/gpg:/gpg:/g" <( echo "$GPG_BROWSER" ) | grep "$SIG"
    echo "$SHA_HASH"
    
    ## If you want the full report, you specify R in the prompt and we print the full messages
    ## back at you and re-run the prompt agian.
    local REPORT_FLAG=1;
    while [[ $REPORT_FLAG -eq 1 ]]; do
	read -p "Print full report (R) Continue with install (C) Exit (E): " ANSWER
	if [[ "$ANSWER" == [Rr] ]]; then
	    sed "s/gpg:/gpg:/g" <( echo "$GPG_KEY" )
	    sed "s/gpg:/gpg:/g" <( echo "$GPG_HASH" )
	    sed "s/gpg:/gpg:/g" <( echo "$GPG_BROWSER" )
	elif [[ "$ANSWER" == [Cc] ]]; then
	    REPORT_FLAG=0;
	    :;
	else
	    exit 0
	fi
    done

    ## If you've turned debugging on, we'll dump all of the vars instead of unpacking
    if [[ "$DEBUG" -ne 0 ]]; then
	dump
	exit 2;
    fi
    
    ## Unpack the Tor-Browser tar file to the specified directory
    tar -xC "$TOR_DIRECTORY" -vf "$BROWSER"

    ## Inline replace the path with the Tor-Browser directory, may cause issue on non-GNU seds
    sed -i 's|^PATH=.*|PATH='"$TOR_DIRECTORY""tor-browser_en-US/Browser:$PATH"'|g' "$EXPORT_ENV"

}

## If anything is inputted besides ENV_VARIABLES, we throw the help text
if [[ ! -z "$1" ]]; then
	help_dialog;
	exit 0;
fi

## Main
main

## Make the inline path change reload the file so it works in the current shell
source "$EXPORT_ENV"
