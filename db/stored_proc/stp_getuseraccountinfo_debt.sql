CREATE OR REPLACE PROCEDURE public.stp_getuseraccountinfo_debt(in_address character varying, in_currency character varying, INOUT out_debt numeric DEFAULT 0)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	-- Created DateTime 25th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> tbl_user_account
	-- CORE SQL - 
	
	---- 5th July 2021 ---
	----- currency label correction -----
	-------------------------------------
	--if in_currency = 'cEUR' then 
	--	in_currency = 'cEUR';
	--end if; 
	------------------------------
	
	------------------- Code Starts Here ---------------------
	select debt into out_debt 
	from tbl_user_reserve
	where address=in_address 
	and coin_name = in_currency
	--and enabled=true
	order by block_number DESC
	limit 1; 
	------------------- Code Ends Here ---------------------
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getuseraccountinfo_debt(varchar,varchar,numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_debt(varchar,varchar,numeric) TO public;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_debt(varchar,varchar,numeric) TO u5p3hgrt8h7nt4;


