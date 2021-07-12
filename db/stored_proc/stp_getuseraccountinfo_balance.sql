CREATE OR REPLACE PROCEDURE public.stp_getuseraccountinfo_balance(in_address character varying, in_currency character varying, INOUT out_balancecusd numeric DEFAULT 0, INOUT out_balancecelo numeric DEFAULT 0, INOUT out_balanceceuro numeric DEFAULT 0, INOUT out_balancegrandtotal numeric DEFAULT 0)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	-- Created DateTime 25th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> 
	-- CORE SQL - 
	
	
	 ------------------- Code Starts Here ---------------------
	   select (deposited - debt) into out_balancecelo 
	   from tbl_user_reserve 
	   where address=in_address
	   and coin_name = 'Celo'
	   and enabled=true
	   order by block_number DESC
	   limit 1; 
  	------------------- Code Ends Here ---------------------

	  ------------------- Code Starts Here ---------------------
	   select (deposited - debt) into out_balanceceuro
	   from tbl_user_reserve 
	   where address=in_address
	   and coin_name = 'cEUR'
	   and enabled=true
	   order by block_number DESC
	   limit 1; 
 	------------------- Code Ends Here ---------------------

	  
	------------------- Code Starts Here ---------------------
	   select (deposited - debt) into out_balancecusd
	   from tbl_user_reserve 
	   where address=in_address
	   and coin_name = 'cUSD'
	   and enabled=true
	   order by block_number desc 
	   limit 1; 
	------------------- Code Ends Here ---------------------
	  
	 ---- Grand Total currency conversion ----------------
	  
	 --- out_balancegrandtotal := out_balancecelo  + out_balanceceuro + out_balancecusd;
	 
	 if in_currency = 'cUSD' then
	 	out_balancegrandtotal := func_getexchange_rate_celo_to_x('cUSD',out_balancecelo)  + func_getexchange_rate_ceur_to_x('cUSD',out_balanceceuro) + out_balancecusd;

	 elseif in_currency = 'cEUR' then
	 	out_balancegrandtotal := func_getexchange_rate_celo_to_x('cEUR',out_balancecelo)  + out_balanceceuro + func_getexchange_rate_cusd_to_x('cEUR',out_balancecusd);
	 
	 elseif in_currency = 'Celo' then
	 	 	out_balancegrandtotal := out_balancecelo  + func_getexchange_rate_ceuro_to_x('Celo',out_balanceceuro) + func_getexchange_rate_cusd_to_x('Celo',out_balancecusd);
	 end if;
	

	
	
	  
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getuseraccountinfo_balance(varchar,varchar,numeric,numeric,numeric,numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_balance(varchar,varchar,numeric,numeric,numeric,numeric) TO public;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_balance(varchar,varchar,numeric,numeric,numeric,numeric) TO u5p3hgrt8h7nt4;


