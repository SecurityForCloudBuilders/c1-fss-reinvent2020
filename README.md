# Demo re:Invent 2020

- [Demo re:Invent 2020](#demo-reinvent-2020)
  - [Demo re:Invent](#demo-reinvent)
  - [Demo Screens](#demo-screens)
  - [Preparation](#preparation)
  - [Malware Downloads](#malware-downloads)
  - [Demoing with Tags](#demoing-with-tags)
  - [Query Logs](#query-logs)
  - [Clean Up](#clean-up)

## Demo re:Invent

*CloudOne = The worlds leading security services platform for all organizations building in the cloud*

S3 scanning in AWS

1. S3 scanning design principles
   1. Simplicity
   2. Speed
   3. Files never leave the Account
   4. Easy integration into own services
2. Architecture
3. Performance
4. Demo
   1. Deployment of the stack
      1. Done via Cloud Formation Template
      2. Deployed from the C1 FSS console  
         Show:
         1. Deploy
         2. In the template, the only optional change you need to make is to define your temporary ingress bucket for all new files
      3. The template also creates a SNS topic which you can watch for the result of the file scan
      4. Show
         1. S3 Buckets
         2. SNS Topic
   2. Cloud9
      1. `. ./setup.sh`
      2. `for i in * ; do aws s3 cp $i s3://${SCANNING_BUCKET}/$i ; done`
   3. MCS
      1. `. ./setup.sh`
      2. `./tags.sh`
      3. `./postscanaction-logs.sh`
      4. `./scanner-logs.sh`
   4. Email Notifications

## Demo Screens

1. Browser
   1. Cloud One
   2. S3 filtered to `-bucket-`
   3. SNS
   4. Cloud9
   5. FSS_Scan_Send_Email
2. Images
   1. Architecture
   2. Scan Times
3. iTerm with authenticated terminal to AWS (Fontsize 20)
4. Mail filtered to `C1FSS Malware Detection`

## Preparation

Be sure to update the `setup.sh` according to your environment before doing the demo. Then run

```sh
. ./setup.sh
```

The files to be scanned should be stored in a dedicated directory, e.g. `files2scan`. Change into that directory and run

```sh
../upload.sh
```

## Malware Downloads

**!!! ATTENTION: REAL MALWARE !!!**

- [Gen:Variant.Strictor.171520](https://s3.eu-central-1.amazonaws.com/dasmalwerk/downloads/c0242d686b4c1707f9db2eb5afdd306507ceb5637d72662dff56c439330dbdf1/c0242d686b4c1707f9db2eb5afdd306507ceb5637d72662dff56c439330dbdf1.zip)

- [Adware ( 004f7c2e1 )](https://s3.eu-central-1.amazonaws.com/dasmalwerk/downloads/37ea273266aa2d28430194fca27849170d609d338abc9c6c43c4e6be1bcf51f9/37ea273266aa2d28430194fca27849170d609d338abc9c6c43c4e6be1bcf51f9.zip)

Password: `infected`

**!!! ATTENTION: REAL MALWARE !!!**

Eicar test malware

- [eicarcom2.zip](https://secure.eicar.org/eicarcom2.zip)
- [eicar.com](https://secure.eicar.org/eicar.com)

## Demoing with Tags

FSS base functionality is tagging the scanned files.

Before demoing adapt the variables `MALWARE` and `CLEAN` within the script `./tags.sh`.

```sh
./tags.sh
```

## Query Logs

Let's query the scan results. Within both scripts the query is filtered to the current day.

```sh
./postscanaction-logs.sh
```

Explain the resulting JSONs (file, findings, ...)

If you are interested on the total time spent to scan the files, we need to dig into a different log group, which you can identify with the "ScannerLambda" within its name.

```sh
./scanner-logs.sh
```

Point to the SQS ID, which links always two events. One is showing the scan result, the corresponding the scantime.

## Clean Up

```sh
./cleanup.sh
```
