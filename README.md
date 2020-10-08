# letsencrypt.sh DNS hook for the [iwantmyname](https://iwantmyname.com/) DNS registrar

This repository contains a ruby-based hook for the [`letsencrypt.sh`](letsencrypt.sh: https://github.com/lukas2511/letsencrypt.sh) project (a [Let's Encrypt](https://letsencrypt.org/), shell script ACME client) that allows a user to obtain a certificate from the `Let's Encrypt`_ API via a DNS challenge. The hook will login to your iwantmyname account with provided credentials, and either add, modify, or remove DNS records, and poll until this change has propogated before allowing Let's Encrypt to confirm that changes.

Relevant Links:
* letsencrypt.sh: https://github.com/lukas2511/letsencrypt.sh
* Let's Encrypt: https://letsencrypt.org/
* iwantmyname: https://iwantmyname.com/

## Required
* git client for tool download
* ruby installed and available on the PATH
* mechanize gem installed
* json gem installed

## Installation
Download the files for installation

``` sh
  $ git clone https://github.com/lukas2511/letsencrypt.sh.git
  $ git clone https://github.com/hughdavenport/letsencrypt-iwantmyname-hook.git letsencrypt.sh/hooks/iwantmyname
  $ cp letsencrypt.sh/hooks/iwantmyname/iwantmyname-secrets-sample.rb letsencrypt.sh/hooks/iwantmyname/iwantmyname-secrets.rb
  $ vi letsencrypt.sh/hooks/iwantmyname/iwantmyname-secrets.rb
  $ chmod +x letsencrypt.sh
```

## Usage
``` bash
$ cd letsencrypt.sh
$ ./dehydrated -c -t dns-01 -d allthethings.co.nz -d www.allthethings.co.nz -k ./hooks/iwantmyname/iwantmyname-hook.rb
#
# !! WARNING !! No main config file found, using default config!
#
+ Generating account key...
+ Registering account key with letsencrypt...
Processing allthethings.co.nz with alternative names: www.allthethings.co.nz
 + Signing domains...
 + Creating new directory /Users/hughdavenport/letsencrypt.sh/certs/allthethings.co.nz ...
 + Generating private key...
 + Generating signing request...
 + Requesting challenge for allthethings.co.nz...
 + Requesting challenge for www.allthethings.co.nz...
Top domain is allthethings.co.nz
Adding TXT record for _acme-challenge, value of "Xh90Wm2GOqdqMInclDxdC95K1OGmNsGAlAcEF0psz3c"
Committing changes
olve _acme-challenge.allthethings.co.nz
Found Xh90Wm2GOqdqMInclDxdC95K1OGmNsGAlAcEF0psz3c. match.
 + Responding to challenge for allthethings.co.nz...
Top domain is allthethings.co.nz
Removing TXT record for _acme-challenge, was "Xh90Wm2GOqdqMInclDxdC95K1OGmNsGAlAcEF0psz3c"
Committing changes
 + Challenge is valid!
Splitting www.allthethings.co.nz
Top domain is allthethings.co.nz
Adding TXT record for _acme-challenge.www, value of "8q72WRdgxtcqEge0CriJqjLI0Nw7Ptk1klUg2fhwpW8"
Committing changes
Trying to resolve _acme-challenge.www.allthethings.co.nz
Found 8q72WRdgxtcqEge0CriJqjLI0Nw7Ptk1klUg2fhwpW8. match.
 + Responding to challenge for www.allthethings.co.nz...
Splitting www.allthethings.co.nz
Top domain is allthethings.co.nz
Removing TXT record for _acme-challenge.www, was "8q72WRdgxtcqEge0CriJqjLI0Nw7Ptk1klUg2fhwpW8"
Committing changes
 + Challenge is valid!
 + Requesting certificate...
 + Checking certificate...
 + Done!
 + Creating fullchain.pem...
Top domain is allthethings.co.nz
Committing changes
 + Done!
```

## Copyright

©2016 Hugh Davenport, All The Things Ltd under MIT license
