[![Build Status](https://travis-ci.com/Otus-DevOps-2019-11/is217175_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2019-11/is217175_infra)
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
***
## terraform-2
1. С помощью *packer* было дополнительно создано два образа, по одному для базы данных и приложения.
2. Используя полученные образы и файлы предыдущего задания разделил конфигурацию инфраструктуры на файлы *app.tf* и *db.tf*, описывающие конфигурацию каждого сервиса, а также *vpc.tf* для правил фаервола, общих для всех сервисов.
3. Из полученных конфигураций создал три модуля *app*, *db* и *vpc*, а сама конфигурация теперь вынесена в две директории: *prod* и *stage*. Различия только в правилах фаервола для подключения по *ssh*.
4. Отдельно создан файл *storage-bucket.tf* для создания хранилища.
    В конфигураций *prod* и *stage* был добавлен новый файл *backend.tf*. Теперь файл состояния terraform.tfstate хранится в созданном хранилище.
5. В модули app и db добавлены провижинеры. Они запускаются в зависимости от переменной *deploy*. После разворачивания инфраструктуры приложение готово и соединение с базой установлено.
---
## ansible-1
Для работы с динамическим *inventory* немного изменил описание инфраструктуры *terraform* - в модулях *app* и *db* при создании ВМ добавляется метка (labels) *ansible_group* c названием группы (*app* или *db*). Таким образом, независимо от количества ВМ в проекте провижин осуществляется согласно назначенным меткам во всех группах.

В настройках *ansible.cfg* прописан скрипт, формирующий динамический *inventory* - [inventory.py](ansible/inventory.py):
```
...
inventory = inventory.py
...
```
Результат:

```sh
$ ansible all -m ping
34.90.1.218 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}

34.90.215.146 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    },
    "changed": false,
    "ping": "pong"
}
```
---
## ansible-2
1. Изменена конфигурация *packer* - провижин заменен на использование *ansible-плейбуков* [packer_app.yml](ansible/packer_app.yml) и [packer_db.yml](ansible/packer_db.yml).
2. Финальная настройка базы и приложения так же выполняются с помощью *ansible-плейбуков* [app.yml](ansible/app.yml), [db.yml](ansible/db.yml) и [deploy.yml](ansible/deploy.yml), объедененных в один [site.yml](ansible/site.yml).
3. *Динамический inventory* заменен на плагин *gcp_compute*. В настройках [ansible.cfg](ansible/ansible.cfg):
```
...
inventory = inventory.gcp.yml
enable_plugins = gcp_compute
...
```
Плагин настраивается в файле [inventory.gcp.yml](ansible/inventoty.gcp.yml)
```
plugin: gcp_compute
zones:
  - europe-west4-b
projects:
  - infra-123456
service_account_file: infra-123456-sa.json
auth_kind: serviceaccount
scopes:
 - 'https://www.googleapis.com/auth/cloud-platform'
 - 'https://www.googleapis.com/auth/compute.readonly'
keyed_groups:
  - key: labels.ansible_group
    separator: ''
hostnames:
  - name
compose:
  ansible_host: networkInterfaces[0].accessConfigs[0].natIP
```
Для назначения хостов в группы использованы метки (метка *ansible_group*), определенные в предыдущем задании в конфигурации *terraform*.
```
$ ansible-inventory --graph
@all:
  |--@app:
  |  |--reddit-app
  |--@db:
  |  |--reddit-db
  |--@ungrouped:
```
---
## ansible-3
1. Созданы роли *app* и *db*. Плейбуки и файлы предыдущего задания использованы для создания ролей.
2. Для использования нескольких окружений в директории *environments* созданы поддиректории для каждого из окружений (*prod* и *stage*). Переменные определены через *group_vars* для каждого из окружений отдельно.
3. Плейбуки переписаны для использования ролей

    Таким образом можно легко запускать наборы сценариев для разных окружений с разными переменными:
    ```
    ansible-playbook playbooks/site.yml -i environments/stage/inventory.gcp.yml
    ```

4. С помощью *ansible-galaxy* установил новую роль для установки и настройки *nginx*. Ссылка на роль в community-репозитории указана в файле requirements.yml:
    ```
    ansible-galaxy install -r environments/stage/requirements.yml
    ```
5. Новый сценарий, который добавляет новых пользователей на виртуальные машины, использует файл *credentials.yml*. В нем указаны имена и пароли новых пользователей. Такие чувствительные данные были зашифрованы *ansible-vault*:
    ```
    ansible-vault encrypt environments/stage/credentials.yml
    ```
6. В оба окружения добавил динамический inventory с помощью плагина *gcp_compute*.
7. Обновил конфигурацию .travis.yml для прохождения дополнительных тестов.
---
## Ansible-4
1. Установлен *vagrant* и написан *Vagrantfile* для разворачивания окружения для тестирования. Провижин осуществляется с помощью сценариев ansible.
2. Роли *app* и *db* доработаны. Добавлены теги, некоторые переменные параметризованы.
3. Дополнительно подключена роль *nginx* для проксирования приложения
4. *Packer* использует для провижина роли.
5. Написаны тесты для роли *db*. Роль тестируется с помощью *molecule* в локальном окружении с тестами* testinfra*
6. Роль db вынесена в отдельный репозторий [devops_db_role](https://github.com/is217175/devops_db_role), который подключен к TravisCI, а тесты проходят в окружении GCP. Уведомления о сборках приходят в *slack*
