#!/usr/bin/env python
# *-# -*- coding: utf-8 -*-

import os
import os.path
import sys
from subprocess import call

# get all file list recursively
def getFileList(targetDir):

    # get file and dir in current directory
    def getFileAndDir(targetDir):
        files = []
        dirs = []

        tmp = os.listdir(targetDir)

        for i in range(len(tmp)):
            if os.path.isdir(targetDir + '/' +tmp[i]):
                dirs.append(targetDir + '/' + tmp[i])
            else:
                # ignore DS_store
                if ".DS_Store" != tmp[i]:
                    files.append(targetDir + '/' + tmp[i])

        return dirs, files

    dirs, files = getFileAndDir(targetDir)
    while (dirs != []):
        # check last item and remove it
        addDir, addFiles = getFileAndDir(dirs.pop())
        dirs = dirs + addDir
        files = files + addFiles
    return files


files = getFileList('.')
for file in files:
    name, extension = os.path.splitext(file)
    if extension != ".md":
        continue
    os.system("gfm2html " + file + " " + name + ".html")
    os.system("chmod 755 " + file.replace(".md", ".html"))
