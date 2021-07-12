CREATE OR REPLACE PROCEDURE public.stp_getreservedata_totaldeposited(in_currency character varying, INOUT out_totaldeposited numeric DEFAULT 0)
 LANGUAGE plpgsql
AS $procedure$
declare 

celo_out_deposited  numeric := 0;
cusd_out_deposited  numeric := 0;
ceuro_out_deposited numeric := 0;

grand_out_deposit   numeric  :=0;

BEGIN
	-- Created DateTime 24th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --

	-- Required Tables -> tbl_user_account
	-- CORE SQL - select SUM(total_liquidity_eth) into out_totaldeposited from tbl_user_account; 
	

	
--- Celo , deposited
select total_liquidity
into celo_out_deposited
from
tbl_reserve
where coin_name = 'Celo'  -- and enabled = true 
order by block_number desc limit 1; 

----  cUSD , Deposit
select total_liquidity
into cusd_out_deposited
from
tbl_reserve
where coin_name = 'cUSD' -- and enabled = true 
order by block_number desc limit 1; 

---- cEUR , Deposit
select total_liquidity
into ceuro_out_deposited
from
tbl_reserve
where coin_name = 'cEUR' -- and enabled = true 
order by block_number desc limit 1; 

---- GrandTotal Summation ---
if in_currency = 'Celo' then 
     	grand_out_deposit := celo_out_deposited + func_getexchange_rate_cusd_to_x('Celo',cusd_out_deposited) + func_getexchange_rate_ceur_to_x('Celo',ceuro_out_deposited);
  
       
elseif in_currency = 'cUSD' then
	   grand_out_deposit := func_getexchange_rate_celo_to_x('cUSD',celo_out_deposited) + cusd_out_deposited + func_getexchange_rate_ceur_to_x('cUSD',ceuro_out_deposited);
  
		  
elseif  in_currency = 'cEUR' then 
		grand_out_deposit := func_getexchange_rate_celo_to_x('cEUR',celo_out_deposited) + func_getexchange_rate_cusd_to_x('cEUR',cusd_out_deposited) + ceuro_out_deposited;
	
	
end if;

select grand_out_deposit
into
out_totaldeposited;


END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getreservedata_totaldeposited(varchar,numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getreservedata_totaldeposited(varchar,numeric) TO public;
GRANT ALL ON PROCEDURE public.stp_getreservedata_totaldeposited(varchar,numeric) TO u5p3hgrt8h7nt4;


