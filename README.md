## Origin

files for setup are taken from: 

```
https://github.com/akridge/oracle-apex-docker-stack
```

from apex official part:

```
https://github.com/akridge/oracle-apex-docker-stack/tree/main/oracle-apex-offical
```


## Connection

* Default user: *system* or *sys*
* Default password: one defined in docker compose
* Default host: localhost
* Default database name: xe

### Apex connection

default apex url:

```
http://localhost:8181
```


```
| INFO : APEX ADMIN password has configured as 'Welcome_1'.
| INFO : Use below login credentials to first time login to APEX service:
|               Workspace: internal
|               User:      ADMIN
|               Password:  Welcome_1
```


## Scripts

create developer users:

```
CREATE USER banka IDENTIFIED BY bank;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER,UNLIMITED TABLESPACE TO bank;
```

create accounts users:

```
CREATE USER am IDENTIFIED BY am;

GRANT CREATE SESSION TO am;
```

fill data:

```
create table accounts (
  id       number primary key
 ,owner    varchar2(30)
 ,balance    number
)
;

alter table accounts
add constraint non_negative_balance_chk check (balance >= 0)
;


create sequence trxs_seq
start with 1
increment by 1
;

create table trxs (
  id              number primary key
 ,created_at       date
)
;

create table trx_items(
   id        number primary key
 , trx_id    number references trxs (id)
 , acc_id    number references accounts (id)
 , type       varchar2(1) 
 , amount     number
 , CONSTRAINT trx_type CHECK (type in ('C', 'D'))
)
;


create sequence trx_line_seq
start with 1
increment by 1
;

insert into accounts (
 id, owner, balance
)
values (
  1
  , 'am'
  , 0
)
;


insert into accounts (
 id, owner, balance
)
values (
  2
  , 'kb'
  , 100
)
;


insert into accounts (
 id, owner, balance
)
values (
  3
  , 'zg'
  , 50
)
;


commit;

```


## Database parameters


Helper selects for metadata about database and schema

Database version

```
SELECT * FROM v$version;
```
