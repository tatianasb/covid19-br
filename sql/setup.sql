CREATE INDEX IF NOT EXISTS idx_caso_key ON caso (
	date,
	state,
	city,
	place_type
);
UPDATE caso SET city = '' WHERE place_type = 'state';  /* Remove NULLs */

CREATE INDEX IF NOT EXISTS idx_caso_full_key ON caso_full (
	date,
	state,
	city,
	place_type
);
UPDATE caso_full SET city = '' WHERE place_type = 'state';  /* Remove NULLs */

DROP VIEW IF EXISTS all_dates;
CREATE VIEW all_dates AS
	SELECT
		DISTINCT date
	FROM
		caso
	ORDER BY
		date ASC;

DROP VIEW IF EXISTS all_places;
CREATE VIEW all_places AS
	SELECT
		state,
		city,
		place_type,
		city_ibge_code,
		estimated_population_2019
	FROM
		caso_full
	GROUP BY
		state,
		city,
		place_type,
		city_ibge_code,
		estimated_population_2019;

DROP VIEW IF EXISTS place_date_matrix;
CREATE VIEW place_date_matrix AS
	SELECT
		d.date,
		p.state,
		p.city,
		p.place_type,
		p.city_ibge_code,
		p.estimated_population_2019
	FROM all_dates AS d
		JOIN all_places AS p;

DROP VIEW IF EXISTS ultimas_atualizacoes;
CREATE VIEW ultimas_atualizacoes AS
	SELECT
		MAX(date) AS last_date,
		state,
		city,
		place_type,
		MAX(order_for_place) AS last_order_for_place
	FROM caso
	GROUP BY
		state,
		city,
		place_type
	ORDER BY
		last_date,
		state,
		city;
