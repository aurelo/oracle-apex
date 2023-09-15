create or replace package body trx_pkg
as
-------------------------------------------------------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-------------------------------------------------------------------------------
  function new_transaction
  return   trxs.id%type
  is
    v_trx_id   trxs.id%type;
  begin
    insert into trxs (
     id
    ,created_at
    )
    values (
     trxs_seq.nextval
    ,sysdate
    )
    returning id
    into v_trx_id
    ;
    
    return v_trx_id;
  end;
-------------------------------------------------------------------------------
-- PUBLIC PROCEDURES AND FUNCTIONS
-------------------------------------------------------------------------------
  procedure transfer(
    p_to       in     varchar2  default null
   ,p_amount   in     number    default 0
  )
  is
     cursor cur_credit_acc
     is
     select   *
     from     accounts a
     where    upper(a.owner) = upper(user)
     ;
     v_credit_acc_rec    accounts%rowtype;
     
     cursor cur_debit_acc
     is
     select   *
     from     accounts a
     where    upper(a.owner) = upper(p_to)
     ;
      
     v_debit_acc_rec     accounts%rowtype;
     
     v_trx_id            trxs.id%type;
  begin
     dbms_output.put_line('Current user: '||user||' pays to: '||p_to||' amount: '||p_amount);
  
     open cur_credit_acc;
     
     fetch cur_credit_acc
     into  v_credit_acc_rec;
     
     close cur_credit_acc;
     
     
     if p_amount > v_credit_acc_rec.balance 
     then
        RAISE_APPLICATION_ERROR(-20000, 'Not enough balance! Required '||p_amount||' available: '||v_credit_acc_rec.balance);
     elsif p_amount <= 0
     then
        RAISE_APPLICATION_ERROR(-20000, 'Amount: '||p_amount||' is not greater then zero!');
     end if;
  
     dbms_output.put_line('Current user: '||user||' with account id: '||v_credit_acc_rec.id||' amount: '||v_credit_acc_rec.balance);
     
     open cur_debit_acc;
     
     fetch cur_debit_acc
     into  v_debit_acc_rec;
     
     close cur_debit_acc;
     
     v_trx_id := new_transaction;
     
     insert into trx_items (
              id
            , trx_id    
            , acc_id    
            , type      
            , amount    
            )
            values (
              trx_line_seq.nextval
            ,v_trx_id
            ,v_credit_acc_rec.id
            ,'C'
            , p_amount
            );
     
     update accounts 
     set    balance = balance - p_amount
     where  id = v_credit_acc_rec.id
     ;
            
     insert into trx_items (
              id
            , trx_id    
            , acc_id    
            , type      
            , amount    
            )
            values (
              trx_line_seq.nextval
            ,v_trx_id
            ,v_debit_acc_rec.id
            ,'D'
            , p_amount
            );
            
     update accounts 
     set    balance = balance + p_amount
     where  id = v_debit_acc_rec.id
     ;
  end;
-------------------------------------------------------------------------------
  procedure transfer2(
    p_to       in     varchar2  default null
   ,p_amount   in     number    default 0
  )
  is
    v_credit_account_id     accounts.id%type;
    v_debit_account_id      accounts.id%type;
    
    v_trx_id                number;
  begin
    update accounts a
    set    a.balance = a.balance - p_amount
    where  a.owner = user
    returning a.id
    into      v_credit_account_id
    ;
    
    update accounts a
    set    a.balance = a.balance + p_amount
    where  a.owner = p_to
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
    
     insert into trx_items (
              id
            , trx_id    
            , acc_id    
            , type      
            , amount    
            )
            values (
             trx_line_seq.nextval
            ,v_trx_id
            ,v_credit_account_id
            ,'C'
            , p_amount
            );
    
    
     insert into trx_items (
              id
            , trx_id    
            , acc_id    
            , type      
            , amount    
            )
            values (
             trx_line_seq.nextval
            ,v_trx_id
            ,v_debit_account_id
            ,'D'
            , p_amount
            );
    
  end;
-------------------------------------------------------------------------------
  procedure test
  is
  begin
     dbms_output.put_line('Called by user: '||user);
  end;

end;