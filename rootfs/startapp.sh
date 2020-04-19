#!/bin/bash

export DISPLAY=:0

wineserver -k
wine "C:\Program Files\NewsLeecher\newsLeecher.exe"
