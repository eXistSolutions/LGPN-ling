# LGPN-ling

## Dev server

http://admin.existsolutions.com:55221/exist/apps/lgpn-ling

## Prerequisites

You need to have *ant*, *git* and *nodeJS* installed.

### Install global node packages

After node is installed just run

    npm install -g gulp bower
    
## Setup

1. Clone the repository

    `git clone https://github.com/eXistSolutions/LGPN-ling.git` 

1. Install dependencies for the front-end and automation tasks (`npm` & `bower`),
    Build and copy javascripts, fonts and css into the *resources* folder (`gulp`) and
    generate the *.xar-package* inside the *build* directory

    `ant`

1. Switch to the exist Dashboard

1. Install the package `build/LGPN-ling-<version>-<commit-hash>.xar` with the Package Manager

1. Click on the *lgpn-ling* icon on the eXist Dashboard.

## Development

`gulp build` builds the resource folder with fonts, scripts and compiled styles

`gulp deploy` sends the resource folder to a local existDB

`gulp watch` will upload the build files whenever a source file changes

**NOTE:** For the deploy and watch task you may have to edit the DB credentials in `gulpfile.js`.

## Build

`ant` builds a XAR file after running `npm install`, `bower install` and `gulp` (build)

To check & install new packages where required and start gulp automation with:

`ant start`

Update all packages and start gulp automation with command:

`ant update`

To start only a gulp build automation, run command:

`ant gulp`
