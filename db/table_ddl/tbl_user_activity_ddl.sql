-- public.tbl_user_activity definition

-- Drop table

-- DROP TABLE tbl_user_activity;

CREATE TABLE tbl_user_activity (
	id_user_activity uuid NOT NULL DEFAULT uuid_generate_v1(),
	address varchar(40) NOT NULL,
	coin_name varchar(8) NOT NULL,
	activity_type varchar(16) NOT NULL,
	amount numeric NOT NULL,
	amount_of_debt_repaid numeric NULL,
	liquidation_price_base numeric NOT NULL DEFAULT 0,
	health_factor numeric NOT NULL,
	tx_hash varchar(64) NOT NULL,
	tx_timestamp timestamp NOT NULL,
	block_number int8 NOT NULL,
	agent_id varchar(8) NULL,
	tag varchar(8) NULL,
	ip inet NULL,
	record_comment varchar(32) NULL,
	update_datetime timestamptz NULL,
	creation_datetime timestamptz NULL DEFAULT now(),
	enabled bool NULL DEFAULT true,
	CONSTRAINT tbl_user_activity_pkey PRIMARY KEY (id_user_activity),
	CONSTRAINT tbl_user_activity_tx_timestamp_tx_hash_coin_name_activity_t_key UNIQUE (tx_timestamp, tx_hash, coin_name, activity_type)
);
CREATE INDEX tbl_user_activity_address_idx ON public.tbl_user_activity USING btree (address);

-- Permissions

ALTER TABLE public.tbl_user_activity OWNER TO u5p3hgrt8h7nt4;
GRANT ALL ON TABLE public.tbl_user_activity TO u5p3hgrt8h7nt4;
