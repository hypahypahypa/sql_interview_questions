CREATE TABLE calls (				-- создание таблицы 'calls'
	created_on timestamp NOT NULL,
	request_id int NOT NULL,
	call_duration int NOT NULL,
	id int UNIQUE NOT NULL
);

SELECT * FROM calls; -- проверка созданной таблицы 'calls'

INSERT INTO calls (created_on, request_id, call_duration, id) -- вставка данных в таблицу 'calls'
	VALUES ('2020-03-01 04:08:04', 2, 3, 1);

INSERT INTO calls (created_on, request_id, call_duration, id)
	VALUES ('2020-03-01 05:28:47', 1, 28, 2);

INSERT INTO calls (created_on, request_id, call_duration, id)
	VALUES ('2020-03-01 07:27:36', 2, 22, 3);

INSERT INTO calls (created_on, request_id, call_duration, id)
	VALUES ('2020-03-01 13:18:21', 1, 12, 4);

INSERT INTO calls (created_on, request_id, call_duration, id)
	VALUES ('2020-03-01 15:08:08', 2, 13, 5);

INSERT INTO calls (created_on, request_id, call_duration, id)
	VALUES ('2020-03-01 16:27:23', 1, 19, 6);

INSERT INTO calls (created_on, request_id, call_duration, id)
	VALUES ('2020-03-01 17:38:01', 3, 15, 7);

INSERT INTO calls (created_on, request_id, call_duration, id)
	VALUES ('2020-03-01 17:56:39', 2, 25, 8);

SELECT * FROM calls; -- проверка вставленных данных в таблицу 'calls'

-- ЗАДАНИЕ № 1 Звонки в час пик
-- На основании имеющихся данных определите количество клиентов, 
-- которые звонили более 3 раз с 15 до 18 часов.
SELECT
	count(*)
FROM
	(SELECT
		c.request_id,
		count(request_id)
	FROM
		calls c
	WHERE
		(created_on BETWEEN '2020-03-01 15:00' AND '2020-03-01 18:00')
	GROUP BY
		c.request_id
	HAVING
		count(request_id) >= 3
	) uq;
	
-- ЗАДАНИЕ №2. Продолжительность первичных звонков.
-- Redfin помогает клиентам находить агентов. У каждого клиента уникальный request_id, 
-- каждый request_id сделал несколько звонков. Для каждого request_id первый звонок является «начальным звонком», 
-- а все последующие - «вторичными звонками». 
-- Какова средняя продолжительность звонка для всех начальных звонков?
SELECT
	ROUND(SUM(ft.call_duration::decimal)/COUNT(ft.call_duration),2)
FROM
	(
	 SELECT *
	 FROM
		(SELECT				-- подзапрос для вычисления id первого звонка
			c.request_id r_id, -- переименовывание столбца в r_id, чтобы потом не было проблем неопределенности
			MIN(c.id) min_id   -- переименовывание столбца в min_id, чтобы потом не было проблем неопределенности
		FROM
			calls c
		GROUP BY
			c.request_id
			) fc			-- fc - first_calls
	 JOIN					-- добавление call_duration по ключу id и ключу первого звонка
		calls c2			-- получаем таблицу с первыми звонками и их длительностью
		ON fc.min_id = c2.id
	) ft;					-- ft - final_table
	

-- создание нескольких таблиц (orders, cities, partners) для задания №3
	
CREATE TABLE orders (
	id int PRIMARY KEY,
	customer_id int,
	courier_id int,
	seiler_id int NOT NULL REFERENCES partners (id),	-- в исходных данных столбец именно se'i'ler, а не se'l'ler
	order_timestamp_utc timestamp,
	amount decimal,
	city_id int NOT NULL REFERENCES cities (id)
	);
	
CREATE TABLE  cities (
	id int PRIMARY KEY,
	name VARCHAR(255),
	timezone VARCHAR(255)
	);
CREATE TABLE partners (
	id int PRIMARY KEY,
	name VARCHAR(255),
	category VARCHAR(255)
	);

SELECT * FROM orders;		-- проверка созданных таблиц
SELECT * FROM cities;
SELECT * FROM partners;

INSERT INTO 
	orders (id, customer_id, courier_id, seiler_id, order_timestamp_utc, amount, city_id)
VALUES
	(1, 102, 224, 79, '2019-03-11 23:27:00', 155.73, 47), -- 1
	(2, 104, 224, 75, '2019-04-11 04:24:00', 216.6, 44),  -- 2
	(3, 100, 239, 79, '2019-03-11 21:17:00', 168.69, 47), -- 3
	(4, 101, 205, 79, '2019-03-11 02:34:00', 210.84, 43), -- 4
	(5, 103, 218, 71, '2019-04-11 00:15:00', 212.6, 47),  -- 5
	(6, 102, 201, 77, '2019-03-11 18:22:00', 220.83, 47), -- 6
	(7, 103, 205, 79, '2019-04-11 11:15:00', 94.86, 49),  -- 7
	(8, 101, 246, 77, '2019-03-11 04:12:00', 86.15, 49),  -- 8
	(9, 101, 218, 79, '2019-03-11 08:59:00', 75.52, 43),  -- 9
	(10, 103, 211, 77, '2019-03-11 00:22:00', 15.85, 49); -- 10
	
INSERT INTO
	cities (id, name, timezone)
VALUES
	(43, 'Boston', 'EST'),
	(44, 'Seattle', 'PST'),
	(47, 'Denver', 'MST'),
	(49, 'Chicago', 'CST');

INSERT INTO
	partners (id, name, category)
VALUES
	(71, 'Papa John’s', 'Pizza'),
	(75, 'Domino’s Pizza', 'Pizza'),
	(77, 'Pizza Hut', 'Pizza'),
	(79, 'Papa Murphy’s', 'Pizza');

-- ЗАДАНИЕ № 3. Партнеры пиццы
-- Какие партнеры имеют в своем названии слово «Pizza» и находятся в Чикаго? Какова средняя сумма заказа? 
-- Выведите имя партнера и среднюю сумму заказа в сортировке по Имени партнера.

SELECT
	p.name,
	AVG(o.amount::decimal)
FROM
	orders o
	JOIN
		partners p
	ON o.seiler_id = p.id  -- опять же, в исходных данных seIler, а не seLler
	JOIN
		cities c
	ON o.city_id = c.id
WHERE
	p.name LIKE '%Pizza%' AND
	c.name = 'Chicago'
GROUP BY
	p.name
ORDER BY
	p.name;
