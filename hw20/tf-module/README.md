# AWS Terraform Module + S3 backend

Модуль приймає `vpc_id` і `list_of_open_ports`, створює Security Group (відкриває
передані порти звідусіль) і публічний EC2 з Nginx. State зберігається в S3.

## Структура
```
tf-module/
├── backend.tf            # S3 backend (bucket + key з твоїм username)
├── providers.tf          # provider aws, регіон eu-central-1
├── main.tf               # default VPC + виклик модуля
├── variables.tf          # list_of_open_ports
├── outputs.tf            # IP та URL Nginx
└── modules/
    └── web/
        ├── main.tf       # SG (dynamic ingress) + EC2 + nginx (user_data)
        ├── variables.tf  # vpc_id, list_of_open_ports, name, instance_type
        └── outputs.tf    # instance_public_ip
```

## Як модуль працює
- `dynamic "ingress"` пробігає по `list_of_open_ports` і робить окреме правило на кожен порт.
- EC2 ставиться в першу підмережу переданої VPC з `associate_public_ip_address = true`.
- `user_data` при першому запуску ставить і вмикає nginx.

## Backend
state не локально, а в S3:
- bucket: `terraform-state-danit-devops`
- key:    `anthonysborozenets/terraform.tfstate`
- region: `eu-central-1`

## Запуск
```bash
terraform init      # ініціалізує S3 backend — state поїде у бакет
terraform plan
terraform apply     # yes
```

Після apply дивись outputs:
```
instance_public_ip = "X.X.X.X"
nginx_url          = "http://X.X.X.X"
```

## Перевірка (скрін №4)
Зачекай ~1 хв після apply (nginx ставиться при завантаженні) і відкрий `http://X.X.X.X`
у браузері — має бути сторінка "Nginx is running on ...".

## State у бакеті (скрін №5)
AWS Console → S3 → bucket `terraform-state-danit-devops` →
папка `anthonysborozenets/` → файл `terraform.tfstate`.

## Видалення
```bash
terraform destroy   # yes
```
