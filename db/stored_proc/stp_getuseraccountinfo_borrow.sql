CREATE OR REPLACE PROCEDURE public.stp_getuseraccountinfo_borrow(in_address character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	-- Created DateTime 26th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --
	
	-- Function - Find the maximum value of supplied activityType=[deposit, withdraw, borrow, repay] on a address
	
	-- Required Tables -> tbl_user_account
	-- CORE SQL - 
	

	------------------- Code Starts Here ---------------------
	select coin_name,borrowed,borrow_rate
	from tbl_user_reserve
	where address=in_address 
	--and enabled=true
	order by block_number DESC;
	------------------- Code Ends Here ---------------------
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getuseraccountinfo_borrow(varchar) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_borrow(varchar) TO public;
GRANT ALL ON PROCEDURE public.stp_getuseraccountinfo_borrow(varchar) TO u5p3hgrt8h7nt4;


