CREATE OR REPLACE PROCEDURE public.stp_getreservedata_total_activeuser_deposited_borrowed(in_currency character varying, INOUT out_activeuser numeric DEFAULT 0, INOUT out_deposited numeric DEFAULT 0, INOUT out_totalborrowed numeric DEFAULT 0)
 LANGUAGE plpgsql
AS $procedure$
declare

celo_out_deposited  numeric := 0;
cusd_out_deposited  numeric := 0;
ceuro_out_deposited numeric := 0;

grand_out_deposit   numeric  :=0;
grand_out_borrow    numeric  :=0;


--- 6th July 2021 -- Tuesday 
celo_borrowed_stable  numeric :=0;
cusd_borrowed_stable  numeric :=0;
ceuro_borrowed_stable numeric :=0;

celo_borrowed_variable  numeric :=0;
cusd_borrowed_variable  numeric :=0;
ceuro_borrowed_variable numeric :=0;




BEGIN
	-- Created DateTime 25th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables ->
	-- CORE SQL - 
	
------------------ Code Starts Here ---------------------

--- Get the total number of users ---
SELECT Count(distinct address)
into
out_activeuser
FROM tbl_user_account;
--where enabled = true; -- Commented for speedup



select total_liquidity,total_borrows_stable,total_borrows_variable
into   celo_out_deposited,celo_borrowed_stable,celo_borrowed_variable
from
tbl_reserve
where coin_name = 'Celo'  -- and enabled = true 
order by block_number desc limit 1; 

----  cUSD , Deposit, Borrow ----
select total_liquidity,total_borrows_stable,total_borrows_variable
into   cusd_out_deposited,cusd_borrowed_stable,cusd_borrowed_variable
from
tbl_reserve
where coin_name = 'cUSD' -- and enabled = true 
order by block_number desc limit 1; 

---- cEUR , Deposit, Borrow ----
select total_liquidity,total_borrows_stable,total_borrows_variable
into   ceuro_out_deposited,ceuro_borrowed_stable,ceuro_borrowed_variable
from
tbl_reserve
where coin_name = 'cEUR' -- and enabled = true 
order by block_number desc limit 1; 

--- tbl_reserve

---- GrandTotal Summation ---
if in_currency = 'Celo' then 
     	grand_out_deposit := celo_out_deposited + func_getexchange_rate_cusd_to_x('Celo',cusd_out_deposited) + func_getexchange_rate_ceur_to_x('Celo',ceuro_out_deposited);
	    
     	grand_out_borrow  := celo_borrowed_stable  + celo_borrowed_variable + 
					 		 func_getexchange_rate_cusd_to_x('Celo',cusd_borrowed_stable  + cusd_borrowed_variable) +
					 		 func_getexchange_rate_ceur_to_x('Celo',ceuro_borrowed_stable  + ceuro_borrowed_variable);
     
     
     
elseif in_currency = 'cUSD' then
	        grand_out_deposit := func_getexchange_rate_celo_to_x('cUSD',celo_out_deposited) + cusd_out_deposited + func_getexchange_rate_ceur_to_x('cUSD',ceuro_out_deposited) ;
    
		    grand_out_borrow  := cusd_borrowed_stable  + cusd_borrowed_variable + 
                              func_getexchange_rate_celo_to_x('cUSD',celo_borrowed_stable  + celo_borrowed_variable) +
                              func_getexchange_rate_ceur_to_x('cUSD',ceuro_borrowed_stable  + ceuro_borrowed_variable);
					 		    
					 		    
	       
elseif  in_currency = 'cEUR' then 
		     grand_out_deposit := func_getexchange_rate_celo_to_x('cEUR',celo_out_deposited) + func_getexchange_rate_cusd_to_x('cEUR',cusd_out_deposited) + ceuro_out_deposited;
				 		 
		    grand_out_borrow  := ceuro_borrowed_stable  + ceuro_borrowed_variable + 
                               func_getexchange_rate_cusd_to_x('cEUR',cusd_borrowed_stable  + cusd_borrowed_variable) +
                               func_getexchange_rate_celo_to_x('cEUR',celo_borrowed_stable  + celo_borrowed_variable);
                              
		    
		    
end if;


select grand_out_deposit , grand_out_borrow
into
out_deposited , out_totalborrowed;

   ------------------- Code Ends Here ---------------------

END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getreservedata_total_activeuser_deposited_borrowed(varchar,numeric,numeric,numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getreservedata_total_activeuser_deposited_borrowed(varchar,numeric,numeric,numeric) TO public;
GRANT ALL ON PROCEDURE public.stp_getreservedata_total_activeuser_deposited_borrowed(varchar,numeric,numeric,numeric) TO u5p3hgrt8h7nt4;


