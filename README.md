# Дипломная работа Кузнецова Александра
Курс **"Системный администратор"** (sys-1_fsys)
Исходное задание на работу находится [тут](https://github.com/netology-code/sys-diplom/blob/main/README.md).

На текущий момент выполнена конфигурация с минимальными требованиями к проекту. Дополнительные требования не выполнялись.

## Структура репозитория
Репозиторий содержит две директории и скрипт
- **Terraform**. Содержит все необходимые файлы для создания инфраструктуры в Yandex Cloud.
- **Ansible**. Содержит плейбуки и роли, необходимые для конфигурирования созданной инфраструктуры.
- **start.sh** . Скрипт, позволяющий "в один клик" создать и сконфигурировать инфраструктуру с локальной машины.

## Комментарии по выбранным способам решения задач
1. **Инфраструктура**.

    * Исходя из требований размещения различных серверов в приватных и публичных подсетях, мною было принято решение сгруппировать их в две логические группы - имеющие публичный IP и нет. Такое разграничение экономит пул публичных адресов (и возможную доп.оплату за превышение лимитов провайдеру) и повышает безопасность внутренней приватной сети, закрывая ее от внешнего мира.
    При этом доступ в интернет для серверов из приватной группы все же нужен - для установки необходимых пакетов ПО. Яндекс предоставляет в консоли управления возможность создания NAT-доступа в интернет для подсетей. Но данная функция [находится в стадии "Preview"](https://cloud.yandex.ru/docs/vpc/operations/enable-nat) (нужен отдельный запрос в техподдержку для предоставления услуги), и, самое главное, этот функционал отсутствует при создании инфраструктуры с помощью Terraform.
    Так как хотелось максимальной автоматизации, я решил сделать NAT доступ вручную. Чтобы не создавать лишних сущностей, задействовал для этого **bastion**-хост. Он будет выполнять как роль шлюза для доступа извне ко внутренним ресурсам, так и шлюзом для доступа приватных серверов во внешний мир. При этом запросы **из** внешнего мира на вебсерверы будут идти как положено - через балансер.
    
    * Имя пользователя, от которого в дальнейшейм происходит подключение по SSH к ресурсам облака, [жестко зафиксировано](https://cloud.yandex.ru/docs/compute/concepts/vm-metadata) и зависит от образа устанавливаемой ОС на серверах. Исходя из этого переменная имени пользователя не может быть произвольной и при изменении ОС должна уточняться.
    
    * Физически подсетей три:
        - Публичная сеть (1). В ней находятся балансер, **bastion**-хост, сервер с Grafana и сервер с Kibana.
        - Приватная сеть (2). В ней находится один веб-сервер и сервера с Prometheus, Elasticsearch, Logstash. Последние физически находятся на одной машине.
        - Приватная сеть (3). В ней находится один веб-сервер. Эта сеть появилась исходя из требования размещения вебсерверов в различных зонах.
    
    * Функционал Security Groups также [находится в стадии Preview](https://cloud.yandex.ru/docs/vpc/operations/security-group-create), однако я получил к нему доступ через запрос в техподдержку и, главное, его функционал доступен для Terraform. Правила описаны в отдельном файле. Суть их сводится к тому, что внутри облака разрешен весь трафик, а также всем машинам облака разрешено инициировать запросы во вне. Для входящего трафика из внешнего мира открыты только порты 22, 80, 3000(Grafana) и 5601(Kibana), на соответствующих серверах публичной подсети.
    
2. **Конфигурирование**.

    * Серверы в приватной подсети напрямую недоступны для конфигурирования извне, т.е. для локальной машины находящейся за пределами облака. Поэтому конфигурирование происходит в два этапа - сначала конфигурируется **bastion**-хост, затем с него запускается конфигурирование всех остальных серверов (во всех подсетях). При этом натыкаемся на ограничение, что SSH-ключи задаются на этапе создания инфраструктуры (при работе Terraform). Поэтому мной было принято следующее решение - использовать ключи с локальной машины (созданные специально для облака) и потом, с помощью этих ключей подключаться к **bastion**-хост, переносить их на него и далее уже он будет подключаться к остальным серверам внутри облака. Схема не очень красивая, но запускать еще и Terraform два раза (второй раз с **bastion**-хост), мне показалось еще хуже. После развертывания и конфигурирования ключи доступа к **bastion**-хост можно и поменять.

    * Все конфигурирование происходит через роли, применяемые для различных серверов.
    
    * Так как запуск **Ansible** производится дважды, из двух разных мест и с двумя разными задачами, то и плейбуков тоже два - один для конфигурирования **bastion**-хост, второй для конфигурирования остальной инфраструктуры уже с **bastion**-хост.

3. **Автоматическое развертывание**.

    * [Скрипт](https://github.com/izhatomic/NG/blob/master/start.sh) автоматизирует задачи создания инфраструктуры и её конфигурирования. Фактически он генерирует отдельные ключи для облака, запускает Terraform, который передает эти ключи все машинам в облаке. Затем копирует их на **bastion**-хост и запускает первый плейбук Ansible, который помимо конфигурирования самого **bastion**-хост, скачивает на него этот репозиторий и запускает второй плейбук, конфигурирующий все остальные машины внутри облака.

    * Запуск **Ansible** в скрипте производится с дополнительным указанием переменной (IP адрес **bastion**-хост), так как нужный IP-адрес становится известным только в процессе работы скрипта.
    
Подобное построение проекта показалось мне наилучшим, с точки зрения максимальной автоматизации всех действий. Фактически, в таком виде установка и конфигурирование происходит однократным запуском Terraform и Ansible в ручном режиме, либо "в один клик" при запуске скрипта.

## Что можно сделать лучше
1. Оформление.

    * Файлы в директории Terraform никак не сгрупированы, что сказывается на "читаемости" проекта. Переделаю в ближайшее время.
    
    * Можно и нужно добавить некоторые комментарии в исходники, чтобы потом проще было ориентироваться.
 
2. Архитектура проекта.

    * Многие параметры конфигураций Terraform и Ansible надо вынести в отдельные переменные, чтобы они стали более гибкими и настраивались из одного места.
    
    * Сервер с Grafana и сервер с Kibana можно также спрятать в приватную подсеть, предоставив к ним доступ через проброс портов в **bastion**-хост (простое решение), либо использовав для этого **nginx** (который в этом случае также можно использовать чтобы терминировать HTTPS).
    
