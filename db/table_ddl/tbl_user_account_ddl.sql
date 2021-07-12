-- public.tbl_user_account definition

-- Drop table

-- DROP TABLE tbl_user_account;

CREATE TABLE tbl_user_account (
	id_user_account uuid NOT NULL DEFAULT uuid_generate_v1(),
	address varchar(40) NOT NULL,
	total_liquidity_eth numeric NULL,
	total_collateral_eth numeric NULL,
	total_borrows_eth numeric NULL,
	total_fees_eth numeric NULL,
	available_borrows_eth numeric NULL,
	current_liquidation_threshold numeric NULL,
	ltv numeric NULL,
	health_factor numeric NOT NULL,
	block_number int8 NOT NULL,
	agent_id varchar(8) NULL,
	tag varchar(8) NULL,
	ip inet NULL,
	record_comment varchar(32) NULL,
	update_datetime timestamptz NULL,
	creation_datetime timestamptz NULL DEFAULT now(),
	enabled bool NULL DEFAULT true,
	CONSTRAINT tbl_user_account_address_block_number_key UNIQUE (address, block_number),
	CONSTRAINT tbl_user_account_pkey PRIMARY KEY (id_user_account)
);
CREATE INDEX tbl_user_account_address_idx ON public.tbl_user_account USING btree (address);

-- Permissions

ALTER TABLE public.tbl_user_account OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON TABLE public.tbl_user_account TO u5p3hgrt8h7nt4;
