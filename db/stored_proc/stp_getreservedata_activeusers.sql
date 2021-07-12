CREATE OR REPLACE PROCEDURE public.stp_getreservedata_activeusers(INOUT out_activeusers numeric DEFAULT 0)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	-- Created DateTime 24th May 2021 - Monday -- 
	-- Author: Mohammad Abdur Rahman --

	-- Required Tables -> tbl_user
	-- CORE SQL - SELECT distinct count(address) FROM tbl_user
	

	------------------- Code Starts Here ---------------------
	--- Activeusers
	select count(distinct address) into out_activeusers from tbl_user_account;   --- where enabled=True;

------------------- Code Ends Here ---------------------
END;
$procedure$
;

-- Permissions

ALTER PROCEDURE public.stp_getreservedata_activeusers(numeric) OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON PROCEDURE public.stp_getreservedata_activeusers(numeric) TO public;
GRANT ALL ON PROCEDURE public.stp_getreservedata_activeusers(numeric) TO u5p3hgrt8h7nt4;


