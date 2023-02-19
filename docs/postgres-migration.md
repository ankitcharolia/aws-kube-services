# **on-premise to on-premise Postgres migration** 
https://dba.stackexchange.com/questions/17740/how-to-get-a-working-and-complete-postgresql-db-backup-and-test

### **export and import schema (all databases)**
```shell
pg_dumpall -U postgres -s  -c > schema_clean.sql
psql -U postgres < schema_clean.sql
```
### **export and import data only**
```shell
pg_dumpall -U postgres -a  > data.sql
psql -U postgres < data.sql
```



# **AWS RDS**
**connect to postgres: (option -1)**

psql -h db-rds-xxxxx.xxxx.eu-central-1.rds.amazonaws.com -p 5432 --username root --password

**Export Schema (from AWS RDS to local machine)**
pg_dump -h db-rds-xxx.xxx.eu-central-1.rds.amazonaws.com -p 5432 --username root --password --dbname=<DBNAME> -s -c > schema_clean.sql


**Export data only (from AWS RDS to local machine)**
pg_dump -h db-rds-xxxxx.xxxx.eu-central-1.rds.amazonaws.com -p 5432 --username root --password --dbname=<DBNAME> -a > data.sql

---

### **Reference:** https://docs.aws.amazon.com/dms/latest/sbs/chap-manageddatabases.postgresql-rds-postgresql-full-load-pd_dump.html

### **Dump AWS Database: (option-2)** 
```shell
pg_dump -h db-rds-xxxxx.xxxx.eu-central-1.rds.amazonaws.com -p 5432 -U root <DB-NAME> > cms-dev.sql
```

### **pg_dumpall exports users, roles**
```shell
pg_dumpall -h db-rds-xxxxx.xxxx.eu-central-1.rds.amazonaws.com -p 5432 -U root -f cms-dev-roles.sql --no-role-passwords -g
```

### **GCP Cloud SQL - connect with Cloud SQL Proxy (Enable Public IP for Cloud-SQL)**
```shell
psql -h 127.0.0.1 -p 5432 -U postgres -f cms-dev-roles.sql
psql -h 127.0.0.1 -p 5432 -U postgres < cms-dev.sql
```


# **Connect AWS RDS with bastion host**
### **Reference:** https://aws.amazon.com/premiumsupport/knowledge-center/rds-connect-using-bastion-host-linux/
```shell
1. Setup EC2 instance in public subnet where internet gateway is attached to 
2. attach public IP to EC2 instance
3. Connect EC2 Instance to RDS Instance (Select Bastion Host --> Actions --> Networking ---> Connect RDS Instance)
4. ssh -i "~/.ssh/acharolia.pem" -f -l ubuntu -L 5432:<private IP of RDS Instance>:5432 <Public IP of Bastion Host> sleep 1000000
5. psql -h 127.0.0.1 -p 5432 -U postgres
```


# **RECOMMENDED WAY FOR DATABASE MIGRATION BETWEEN CLOUD**
### VPN Tunnel Between AWS and GCP (https://medium.com/google-cloud/migrating-aws-rds-to-cloud-sql-using-gcp-dms-3614fda55d9e) 

