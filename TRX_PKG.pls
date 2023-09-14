create or replace package trx_pkg
as
  procedure transfer(
    p_to       in     varchar2  default null
   ,p_amount   in     number    default 0
  );
end;