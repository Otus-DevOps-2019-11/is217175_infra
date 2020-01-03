# is217175_infra
is217175 Infra repository

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
