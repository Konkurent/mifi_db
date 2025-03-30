-- Заание 1
SELECT maker, vehicle.model
FROM vehicle
         JOIN motorcycle ON vehicle.model = motorcycle.model
WHERE horsepower > 150
  AND price < 20000
  AND motorcycle.type = 'Sport'
ORDER BY horsepower DESC;

-- Задание 2
WITH union_table AS (SELECT v.maker, c.model, c.horsepower, c.engine_capacity, v.type as vehicle_type 
                     FROM car AS c
                              JOIN vehicle AS v ON c.model = v.model
                     WHERE horsepower > 150
                       AND engine_capacity < 3
                       AND price < 35000
                       AND v.type = 'Car'
                     UNION ALL
                     SELECT v.maker, m.model, m.horsepower, m.engine_capacity, v.type as vehicle_type
                     FROM motorcycle AS m
                              JOIN vehicle AS v ON m.model = v.model
                     WHERE horsepower > 150
                       AND engine_capacity < 1.5
                       AND price < 20000
                       AND v.type = 'Motorcycle'
                     UNION ALL
                     SELECT v.maker, b.model, NULL AS horsepower, NULL AS engine_capacity, v.type as vehicle_type
                     FROM bicycle AS b
                              JOIN vehicle AS v ON b.model = v.model
                     WHERE gear_count > 18
                       AND price < 4000
                       AND v.type = 'Bicycle'
                     ORDER BY horsepower DESC)
                    --  Объединяю собираю данные по условиям для каждого типа + объединяю данные в 1 структуру
SELECT *
FROM union_table
ORDER BY horsepower DESC NULLS LAST;
-- Вывожу данные с сортировкой по всем значениям