# Polydelphia 2018 Election Site

## Build Site

```
bundle exec jekyll build
```

## Build GCE Image

```
./deploy/build/build.sh
```

## Deploy GCE VM

```
cd deploy && terraform apply -auto-approve
```
