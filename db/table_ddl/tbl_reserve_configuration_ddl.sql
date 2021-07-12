-- public.tbl_reserve_configuration definition

-- Drop table

-- DROP TABLE tbl_reserve_configuration;

CREATE TABLE tbl_reserve_configuration (
	id_reserve_configuration uuid NOT NULL DEFAULT uuid_generate_v1(),
	coin_name varchar(8) NOT NULL,
	ltv numeric NOT NULL,
	liquidation_threshold numeric NOT NULL,
	liquidation_discount numeric NOT NULL,
	interest_rate_strategy_address varchar(40) NOT NULL,
	usage_as_collateral_enabled bool NULL,
	borrowing_enabled bool NULL,
	stable_borrow_rate_enabled bool NULL,
	block_number int8 NULL,
	agent_id varchar(8) NULL,
	tag varchar(8) NULL,
	ip inet NULL,
	record_comment varchar(32) NULL,
	update_datetime timestamptz NULL,
	creation_datetime timestamptz NULL DEFAULT now(),
	enabled bool NULL DEFAULT true,
	CONSTRAINT tbl_reserve_configuration_coin_name_block_number_key UNIQUE (coin_name, block_number),
	CONSTRAINT tbl_reserve_configuration_pkey PRIMARY KEY (id_reserve_configuration)
);

-- Permissions

ALTER TABLE public.tbl_reserve_configuration OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON TABLE public.tbl_reserve_configuration TO u5p3hgrt8h7nt4;
