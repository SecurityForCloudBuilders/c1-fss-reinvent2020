#!/bin/bash

for i in * ; do aws s3 cp $i s3://${SCANNING_BUCKET}/$i ; done
