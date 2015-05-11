#!/bin/bash

apidoc -i server/app/controllers -o document/CCPF/server/API
apidoc -i document/AirCasting/server/API -o document/AirCasting/server/API
apidoc -i document/SmartCitizen/server/API -o document/SmartCitizen/server/API
#appledoc --project-name CCPF --project-company ISI-Dentsu of America,Inc. --create-html --no-create-docset --output document/CCPF/iOS/iPhone iOS/HyperMediaAD/Classes
#appledoc --project-name CCPF --project-company ISI-Dentsu of America,Inc. --create-html --no-create-docset --output document/CCPF/iOS/AppleWatch iOS/HyperMediaAD\ WatchKit\ Extension/Classes
