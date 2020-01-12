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
***
## packer-basea
1. Создан шаблон [ubuntu16.json](packer/ubuntu16.json) для создания образа виртуальной машины. Переменные определяются в файле [variables.json](packer/variables.json.example). Для провижининга написаны два bash-скрипта [install_ruby.sh](packer/scripts/install_ruby.sh) и [install_mongodb.sh](packer/scripts/install_mongodb.sh). Образ собрался и, как ожидалось, успешно стартовала виртуальная машина построенная на нем.

2. Создан шаблон [immutable.json](packer/immutable.json). Этот шаблон отличается от предыдущего тем, что создается образ с уже запущенным приложением. При этом для веб-сервера **puma** готов systemd юнит-файл.

3. Написан скрипт [create-reddit-vm.sh](config-scripts/create-reddit-vm.sh) для запуска виртуальной машины на основе созданного образа.
***
## terraform-1
1. Создан файл [main.tf](terraform/main.tf). Он описывает создание виртуальных машин из образа *reddit-base*, добавляет правило для фаервола, разрешающее входящее подключение на порту *9292*, и провижинеры, которые после запуска ВМ настраивают приложение. Провиженеры подключаются по ssh используя параметры описанные в блоке *connection*.

    В метаданные виртуальные машины автоматически добавляется публичный ssh-ключ для пользователя *appuser*.
2. Создан [output.tf](terraform/output.tf), где описал выходную переменную - IP-адрес созданной виртуальной машины.
3. В файле *variables.tf* определил входные переменные, такие как проект, регион, путь к публичному ключу, образ для ВМ, путь к приватному ключу и зону.

    В файле [terraform.tfvars](terraform/terraform.tfvars.example) присвоил значения, описанным выше переменным.

4. Выполнил задание со <span style="color:red">*</span>. Добавил в метаданные проекта публичные ключи для нескольких пользователей:
    ```
    resource "google_compute_project_metadata_item" "default" {
    key   = "ssh-keys"
    value = <<-EOT
        appuser1:${file(var.public_key_path)}
        appuser2:${file(var.public_key_path)}
        appuser3:${file(var.public_key_path)}
    EOT
    }
    ```
5. Выполнил задание с <span style="color:red">**</span>. Изменил ресурс для создания виртуальной машины, добавив в него параметр `count`. В нем указано количество создаваемых виртуальных машин.

    В файле [lb.tf](terraform/lb.tf) описал создание http- балансировщика, который направляет подключения в группу из созданных виртуальных машин. В выходные переменные добавил IP-адрес балансировщика, а в входные - количество создаваемых виртуальных машин, входной порт для балансировщика.
