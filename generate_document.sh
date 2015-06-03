#!/bin/bash

apidoc -i server/app/controllers -o document/CCPF/server/API
chmod 755 document/CCPF/server/API/index.html
apidoc -i document/AirCasting/server/API -o document/AirCasting/server/API
chmod 755 document/AirCasting/server/API/index.html
apidoc -i document/SmartCitizen/server/API -o document/SmartCitizen/server/API
chmod 755 document/SmartCitizen/server/API/index.html

cd iOS
#jazzy -o ../document/CCPF/iOS/iPhone -x -workspace,HyperMediaAD.xcworkspace,-scheme,HyperMediaAD
#jazzy -o ../document/CCPF/iOS/AppleWatch -x -workspace,HyperMediaAD.xcworkspace,-scheme,HyperMediaAD\ WatchKit\ App
cd ../

cd document
python generate_db_document.py
cd ../
