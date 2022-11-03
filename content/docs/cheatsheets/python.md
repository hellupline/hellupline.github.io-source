---
title: 'python'

---


## poetry

### install and use

```bash
python3 -m pip install --upgrade --user poetry
poetry add boto3
poetry shell
```


### lock and lambda-layer

```bash
poetry export --format requirements.txt --output ./layer/requirements.txt
python3 -m pip install \
   --force-reinstall \
   --no-compile \
   --no-deps \
   --target './layer/python' \
   --requirement './layer/requirements.txt'
```


#### pip docker

```bash
poetry export --format requirements.txt --output ./layer/requirements.txt
docker run \
    --name python-pip \
    --rm \
    --interactive=true \
    --tty=true \
    --volume "${PWD}:/application" \
    --workdir '/application' \
    python:3.10 \
    python3 -m pip install \
      --force-reinstall \
      --no-compile \
      --no-deps \
      --target '/application' \
      --requirement '/application/requirements.txt'
```
