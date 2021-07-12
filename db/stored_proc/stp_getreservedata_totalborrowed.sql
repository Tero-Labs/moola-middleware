CREATE OR REPLACE PROCEDURE public.stp_getreservedata_totalborrowed(in_currency character varying, INOUT out_totalborrowed numeric DEFAULT 0)
 LANGUAGE plpgsql
AS $procedure$
declare 
--- 6th July 2021 -- Tuesday 
celo_borrowed_variable  numeric :=0;
cusd_borrowed_variable  numeric :=0;
ceuro_borrowed_variable numeric :=0;

celo_borrowed_stable  numeric :=0;
cusd_borrowed_stable  numeric :=0;
ceuro_borrowed_stable numeric :=0;

grand_out_borrow   numeric :=0;

BEGIN
	-- Created DateTime 24th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --

	-- Required Tables -> tbl_user_account
	-- CORE SQL - select SUM(total_borrows_eth) into out_totalborrowed from tbl_user_account; 

	------------- New version -- 2nd July 2021 -- Friday -------------
	
	--- Celo , borrowed 
select total_borrows_stable,total_borrows_variable
into   celo_borrowed_stable,celo_borrowed_variable
from
tbl_reserve
where coin_name = 'Celo'  -- and enabled = true 
order by block_number desc limit 1; 

----  cUSD , Borrow ----
select total_borrows_stable,total_borrows_variable
into   cusd_borrowed_stable,cusd_borrowed_variable 
from
tbl_reserve
where coin_name = 'cUSD' -- and enabled = true 
order by block_number desc limit 1; 

---- cEUR , Borrow ----
select total_borrows_stable,total_borrows_variable
into   ceuro_borrowed_stable,ceuro_borrowed_variable
from
tbl_reserve
where coin_name = 'cEUR' -- and enabled = true 
order by block_number desc limit 1; 

---- GrandTotal Summation ---
if in_currency = 'Celo' then 

		grand_out_borrow  := celo_borrowed_stable  + celo_borrowed_variable + 
					 		 func_getexchange_rate_cusd_to_x('Celo',cusd_borrowed_stable  + cusd_borrowed_variable) +
					 		 func_getexchange_rate_ceur_to_x('Celo',ceuro_borrowed_stable  + ceuro_borrowed_variable);
		
 elseif in_currency = 'cUSD' then
	
		--grand_out_borrow  := cusd_borrowed_stable  + cusd_borrowed_variable + 
		--			 		 func_getexchange_rate_cusd_to_x('cUSD',cusd_borrowed_stable  + cusd_borrowed_variable) +
		--			 		 func_getexchange_rate_ceur_to_x('cUSD',ceuro_borrowed_stable  + ceuro_borrowed_variable);
					 		
		grand_out_borrow  := cusd_borrowed_stable  + cusd_borrowed_variable + 
                             func_getexchange_rate_celo_to_x('cUSD',celo_borrowed_stable  + celo_borrowed_variable) +
                             func_getexchange_rate_ceur_to_x('cUSD',ceuro_borrowed_stable  + ceuro_borrowed_variable);
					 		    			 		
					 		
	
	
	
elseif  in_currency = 'cEUR' then 
    
		--grand_out_borrow  := ceuro_borrowed_stable  + ceuro_borrowed_variable + 
		--			 		 func_getexchange_rate_cusd_to_x('cEUR',cusd_borrowed_stable  + cusd_borrowed_variable) +
		--			 		 func_getexchange_rate_ceur_to_x('cEUR',ceuro_borrowed_stable  + ceuro_borrowed_variable);	
					 		
		grand_out_borrow  := ceuro_borrowed_stable  + ceuro_borrowed_variable + 
                             func_getexchange_rate_cusd_to_x('cEUR',cusd_borrowed_stable  + cusd_borrowed_variable) +
        	                 func_getexchange_rate_celo_to_x('cEUR',celo_borrowed_stable  + celo_borrowed_variable);
                              
	
	
end if;


select grand_out_borrow
into
out_totalborrowed;


------------------- Code Ends Here ---------------------
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getreservedata_totalborrowed(varchar,numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getreservedata_totalborrowed(varchar,numeric) TO public;
GRANT ALL ON PROCEDURE public.stp_getreservedata_totalborrowed(varchar,numeric) TO u5p3hgrt8h7nt4;

