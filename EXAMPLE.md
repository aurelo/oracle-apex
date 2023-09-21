Connect as sys user @ xepdb1 pluggable database.

----

Create 4 users - one application user and three account users

Application user:

```
create user bank identified by bank;
grant create session, create table, create view, create procedure, create sequence, create trigger,unlimited tablespace to bank;
```


----

Create 3 application users representing CEO's

*   Apple CEO: Tim Cook
*   Microsoft CEO: Satya Nadella
*   Amazon CEO: Jeff Bezos (Andy Jass current CEO)
*   Google CEO: Sundar Pichai


```
create user tim identified by tim;
create user satya identified by satya;
create user jeff identified by jeff;
create user sundar identified by sundar;
grant create session to tim, satya, sundar, jeff;
```


----

Connect as **bank** and create application objects (tables, sequences, procedure):


```
create table accounts (
  id         number primary key
 ,owner      varchar2(30) not null
 ,balance    number
 ,constraint non_negative_balance_chk check (balance >= 0)
)
;

create public synonym accounts for bank.accounts;
grant select on accounts to tim, satya, sundar, jeff;
```


Insert starting balances for every account:

```
insert into accounts (
 id, owner, balance
)
values (
  1
  , 'tim'
  , 100
)
;


insert into accounts (
 id, owner, balance
)
values (
  2
  , 'satya'
  , 100
)
;


insert into accounts (
 id, owner, balance
)
values (
  3
  , 'jeff'
  , 50
)
;

insert into accounts (
 id, owner, balance
)
values (
  4
  , 'sundar'
  , 50
)
;


commit;

```


----

Create transaction tables

```
create table trxs (
  id              number primary key
 ,created_at      date
)
;
create public synonym trxs for bank.trxs;

create sequence trxs_seq
start with 1
increment by 1
;

```

transaction lines:

```
create table trx_lines(
   id         number primary key
 , trx_id     number references trxs (id)
 , acc_id     number references accounts (id)
 , type       varchar2(1) 
 , amount     number
 , constraint trx_type check (type in ('C', 'D'))
)
;


create public synonym trx_lines for bank.trx_lines;

grant select on trx_lines to tim, satya, jeff;

create sequence trx_lines_seq
start with 1
increment by 1
;

```

----

Create procedure to transfer money

```
create or replace procedure transfer(
  p_to_account      in       accounts.owner%type
 ,p_amount          in       number
)
as
    v_credit_account_id     accounts.id%type;
    v_debit_account_id      accounts.id%type;

    v_trx_id                number;
  begin
    update accounts a
    set    a.balance = a.balance - p_amount
    where  upper(a.owner) = upper(user)
    returning a.id
    into      v_credit_account_id
    ;

    update accounts a
    set    a.balance = a.balance + p_amount
    where  upper(a.owner) = upper(p_to_account)
    returning a.id
    into      v_debit_account_id
    ;

    insert into trxs (
      id
     ,created_at
    )
    values (
      trxs_seq.nextval
     ,sysdate
    )
    returning id
    into      v_trx_id
    ;

     insert into trx_lines (
              id
            , trx_id    
            , acc_id    
            , type      
            , amount    
            )
            values (
             trx_lines_seq.nextval
            ,v_trx_id
            ,v_credit_account_id
            ,'C'
            , p_amount
            );


     insert into trx_lines (
              id
            , trx_id    
            , acc_id    
            , type      
            , amount    
            )
            values (
             trx_lines_seq.nextval
            ,v_trx_id
            ,v_debit_account_id
            ,'D'
            , p_amount
            );
end;
```

```
create public synonym transfer for bank.transfer;
grant execute on transfer to tim, satya, sundar, jeff;
```


-----
-----

connect to database container:

```
docker exec -it auto-xe-reg bash
```

connect to sqlplus

```
sqlplus / as sysdba
```


shutdown and startup database
```
shutdown immediate;
startup;
```