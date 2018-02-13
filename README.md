# Private-Tor-Browser-Installer


## What is this?
The downloadTorBrowser.sh script securely and privately downloads and verifies the integrity of the latest version of Tor-Browser. It does this using a mixture of curl and gpg settings.

## Usage
Basically:
```
[ENV_VARIABLE] [ENV_VARIABLE] ./downloadTorBrowser.sh 
```
where ENV_VARIABLES are any of the internal variables listed below. You can run it without any environment variables, but it won't be as secure if you don't configure the proxy and routing settings.

To print the full mandoc, use "-h" or "--help"

## Environment Variables

Environment variables can be set by adding `ENVIRONMENT_VARIABLE=VALUE` before the script name. Like:

```
PROXY="socks5://255.255.255.255.255:25555" ./downloadTorBrowser.sh
```
| Variable          | Description			              | Default			    |
|:-----------------:|:------------------------------------------------|:---------------------------:|
| DEV_TEAM_KEY      | The PGP key of the team working on the Tor-Browser. The team regularly changes keys, so a new one may need to be specified from https://www.torproject.org/docs/signing-keys.html.en |  0xD1483FA6C3C07136 |
| TOR_DIRECTORY     | The directory in which Tor should be installed. | ~/bin/              |
| USER_AGENT        | The useragent curl should use.	              |	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36 |
| PRE_PROXY         | The proxy to use before connecting to the main proxy. Follows standard Curl usage. | |
| PROXY 	    | The main proxy to connect to the download site. Follows standard Curl usage. | |
| CIPHER	    | The cipher curl should use to communicate with the Tor Project directory over TLS. | ECDHE-RSA-AES256-GCM-SHA384 |
| DNS		    | The DNS server curl should use to lookup the Tor Download links. | 200.252.98.162  |
| KEY_SERVER	    | Keyserver GPG should use to retrieve the dev key. Onion alternative: hkps://jirk5u4osbsr34t5.onion via Kristian Fiskerstrand. The default is not over SSL. If you're using an SSL server with a custom certificate, you can append the option here too. | hkp://pool.sks-keyservers.net  | 	    
| TOR_BROWSER_LINK  | Link to the exact Tor-Browser file.     | https://dist.torproject.org/torbrowser/7.5/tor-browser-linux64-7.5_en-US.tar.xz |
| SHA256SUM_LINK    | Link to the hash sums file.	      | https://dist.torproject.org/torbrowser/7.5/sha256sums-signed-build.txt |
| EXPORT_ENV	    | File containing the PATH variable.      | /home/$USER/.bashrc         |
| DEBUG		    | If anything but 0, will run the entire process, right up to extraction and installation, then ask if vars should be dumped to stdout. If 2, will do the aforementioned, but with set -x enabled tracing. | 0 |

## CAVEATS
Security is only as strong as you make it. If you run this with no proxies, using Google's DNS, over the clearnet, with a terrible cipher, a unique useragent, and decide to install even when you're shown that all the PGP signatures and checksum are bad, that's on you. You probably shouldn't be relying on someone else's script to do this for you either, but it's open source, small, and documented, so you can verify the integrity of it yourself. 

## Credit
Credit goes to Endwall ([Github](https://github.com/endwall2)/[GitGud](https://gitgud.io/Endwall)) for outlining and sharing the original process of downloading, checking signatures, and installing.