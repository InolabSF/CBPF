#!/bin/bash

apidoc -i server/app/controllers -o document/CCPF/server/API
chmod 755 document/CCPF/server/API/index.html
apidoc -i document/AirCasting/server/API -o document/AirCasting/server/API
chmod 755 document/AirCasting/server/API/index.html
apidoc -i document/SmartCitizen/server/API -o document/SmartCitizen/server/API
chmod 755 document/SmartCitizen/server/API/index.html
#appledoc --project-name CCPF --project-company ISI-Dentsu of America,Inc. --create-html --no-create-docset --output document/CCPF/iOS/iPhone iOS/HyperMediaAD/Classes
#appledoc --project-name CCPF --project-company ISI-Dentsu of America,Inc. --create-html --no-create-docset --output document/CCPF/iOS/AppleWatch iOS/HyperMediaAD\ WatchKit\ Extension/Classes
