CREATE OR REPLACE PROCEDURE public.stp_getuseraccountinfo_max(in_address character varying, in_activity_type character varying, in_currency character varying, INOUT out_maxamount numeric DEFAULT 0)
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
	--	in_currency = 'ceuro';
	--end if; 
	------------------------------

	------------------- Code Starts Here ---------------------
	--- ??? MAX in all transaction or among the last ???
	select MAX(amount) into out_maxamount 
	from tbl_user_activity 
	where address=in_address::VARCHAR(40) 
	and activity_type=in_activity_type 
	and coin_name = in_currency;
	--and enabled=True; 
	------------------- Code Ends Here ---------------------
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getuseraccountinfo_max(varchar,varchar,varchar,numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_max(varchar,varchar,varchar,numeric) TO public;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_max(varchar,varchar,varchar,numeric) TO u5p3hgrt8h7nt4;

