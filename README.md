# Terraform пример
## Подготовка
### Добавляем креды от облака
Для того чтобы terraform знал куда идти нужны креды. Самый простой способ это попросить у openstack провайдера `openrc.sh` файлик и запустить его
```
source openrc.sh
```

### Генерация ssh ключей
чтобы ходить к машинкам по ssh, для них нужно сгенерировать ключики
```
admin@vsfi:~/2022-terraform-example$ ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ivanh/.ssh/id_rsa): demo_rsa
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in demo_rsa
Your public key has been saved in demo_rsa.pub
```

## Развёртывание
Скачаиваем нужные модули
```
terraform init
```
Смотрим что будем делать
```
terraform plan
```
Запускаем
```
terraform apply
```