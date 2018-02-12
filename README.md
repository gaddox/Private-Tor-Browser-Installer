# Private-Tor-Browser-Installer


## What is this?
The downloadTorBrowser.sh script securely and privately downloads and verifies the integrity of the latest version of Tor-Browser. It does this using a mixture of curl and gpg settings.

## Usage
Basically:
```
[ENV_VARIABLE] [ENV_VARIBLE] ./downloadTorBrowser.sh 
```
where ENV_VARIABLES are any of the internal variables listed below. You can run it without any environment variables, but it won't be as secure if you don't configure the proxy and routing settings.

To print the full mandoc, use "-h" or "--help"

## Environment Variables

Environment variables can be set by adding `ENVIRONMENT_VARIABLE=VALUE` before the script name. Like:

```
TITLE_CHANNEL="My Twitter Feed" ./twitterAtom.sh handle1 handle2
```
| Variable          | Description			              | Default			    |
|:-----------------:|:------------------------------------------------|:---------------------------:|
| DEV_TEAM_KEY      | The PGP key of the team working on the Tor-Browser. The team regularly changes keys, so a new one may need to be specified from https://www.torproject.org/docs/signing-keys.html.en |  0xD1483FA6C3C07136 |
| TOR_DIRECTORY     | The directory in which Tor should be installed. | ~/bin/              |
| USER_AGENT        | The useragent curl should use.	              |	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36 |
| PRE_PROXY         | The proxy to use before connecting to the main proxy. Follows standard Curl usage. | |
| PROXY 	    | The main proxy to connect to the download site. Follows standard Curl usage. | |
| CIPHER	    | The cipher curl should use to communicate with the Tor Project directory over TLS. | ECDHE-RSA-AES256-GCM-SHA384 |
| DNS		    | The DNS server curl should use to lookup the Tor Download links. |   |
| KEY_SERVER	    | Keyserver GPG should use to retrieve the dev key. Default is hkp://pool.sks-keyservers.net Onion alternative: hkps://jirk5u4osbsr34t5.onion via Kristian Fiskerstrand. The default is not over SSL. If you're using an SSL server with a custom certificate, you can append the option here too. | 	    
| TOR_BROWSER_LINK  | Link to the exact Tor-Browser file.     | https://dist.torproject.org/torbrowser/7.5/tor-browser-linux64-7.5_en-US.tar.xz |

| SHA256SUM_LINK    | Link to the hash sums file.	      | https://dist.torproject.org/torbrowser/7.5/sha256sums-signed-build.txt |

| EXPORT_ENV	    | File containing the PATH variable.      | /home/$USER/.bashrc         |
| DEBUG		    | If anything but 0, will run the entire process, right up to extraction and installation. Then dump all of the variables and exit. | 0 |

## CAVEATS
This utility is extremely unstable owing to Twitter's slaphappy abuse of HTML as nothing more than a foundation for divs. As well as the natural instability of the web and the erratic web developers that guard it from the javascript-unenlightened. Expect to see HTML markup in your feed. Expect to see no feed at all. 