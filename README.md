# is217175_infra
is217175 Infra repository
***
## cloud-bastion
Подключение к **someinternalhost** через **bastion** в одну строку:
```
ssh appuser@someinternalhost -J appuser@35.214.201.43
```
где 35.214.201.43 - IP-адрес хоста **bastion**

Для простоты подключения можно определить алиас такого подключения в файле ~/.ssh/config
```
Host someinternalhost
    HostName someinternalhost
    PasswordAuthentication no
    Port 22
    PreferredAuthentications publickey
    User appuser
    IdentityFile ~/.ssh/gcp_appuser
    ProxyJump bastion

Host bastion
    HostName 35.214.201.43
    PasswordAuthentication no
    Port 22
    PreferredAuthentications publickey
    User appuser
    IdentityFile ~/.ssh/gcp_appuser
```
Теперь подключение будет происходить по команде `ssh someinternalhost`

Данные для подключения:
```
bastion_IP = 35.214.201.43
someinternalhost_IP = 10.164.0.7
```
***
## cloud-testapp
Данные для проверки:
```
testapp_IP = 35.204.172.201
testapp_port = 9292
```
Создание правила для фаервола с помощью **glcoud**:
```
$ gcloud compute firewall-rules create default-puma-server --allow=tcp:9292 --direction=INGRESS --priority=1000 --network=default --source-ranges=0.0.0.0/0 --target-tags=puma-server
```
Для того, чтобы получить виртуальную машину с уже запущенным приложением необходимо в передать в параметре *--metadata-from-file startup-script=* скрипт настройки приложения. Команда **gcloud** при это будет выглядеть так:
```
$ gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone=europe-west4-a --metadata-from-file startup-script=scripts/startup
```
Тот же результат можно получить используя параметр *--metadata startup-script-url=*. Скрипт должен находиться в хранилище. Команда **gcloud** при это будет выглядеть так:
```
$ gsutil mb gs://scripts-bucket-20202/
$ gsutils cp scripts/startup gs://scripts-bucket-20202/
$ gcloud compute instances create reddit-app --boot-disk-size=10GB --image-family ubuntu-1604-lts --image-project=ubuntu-os-cloud --machine-type=g1-small --tags puma-server --restart-on-failure --zone=europe-west4-a --scopes storage-ro --metadata startup-script-url=gs://scripts-bucket-20202/startup
```
