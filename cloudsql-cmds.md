cloud-sql-proxy dev-md-gcp:us-east1:demo-mysql --port 9470

Listening on 127.0.0.1:9470
The proxy has started successfully and is ready for new connections!

gcloud sql users create appuser \
  --instance=demo-mysql \
  --password='AppUser@12345'

  gcloud sql users list \
  --instance=demo-mysql

mysql \
  -h 127.0.0.1 \
  -P 9470 \
  -u appuser \
  -p \
  --get-server-public-key

AppUser@12345

SELECT VERSION();

CREATE DATABASE demoapp;

GRANT ALL PRIVILEGES ON demoapp.* TO 'appuser'@'%';

SHOW GRANTS FOR 'appuser'@'%';

USE demoapp;

CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(100)
);

INSERT INTO employees (name, role)
VALUES ('Shashikiran', 'DevOps Engineer');

SELECT * FROM employees;


### usinh public ip instead of proxy

curl -4 ifconfig.me

35.240.156.164

Cloud SQL → demo-mysql → Connections → Networking

add cloudshell IP

mysql   -h 34.23.71.84   -u appuser   -p