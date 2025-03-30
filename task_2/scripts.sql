-- Задание 1
WITH avg_pos AS (SELECT c.name, c.class, AVG(r.position) AS average_position, COUNT(r.race) AS race_count
                 FROM cars as c
                          JOIN results as r ON c.name = r.car
                 GROUP BY c.name, c.class),
                --  Считаю среднюю позицию для каждого автомобиля + марки
     min_avg_pos AS (SELECT class, MIN(average_position) AS pos
                     FROM avg_pos
                     GROUP BY class)
                    --  Считаю минамальное вреднее в разрезе каждого класса
SELECT avg_pos.name, avg_pos.class, avg_pos.average_position, avg_pos.race_count
FROM avg_pos
         JOIN min_avg_pos ON avg_pos.class = min_avg_pos.class AND avg_pos.average_position = min_avg_pos.pos
ORDER BY avg_pos.average_position;

-- Задание 2
WITH avg_pos AS (SELECT c.name, c.class, AVG(r.position) AS average_position, COUNT(r.race) AS race_count
                 FROM cars as c
                          JOIN results as r ON c.name = r.car
                 GROUP BY c.name)
--  Считаю среднюю позицию для каждого автомобиля
SELECT ap.name, ap.class, ap.average_position, ap.race_count, cl.country
FROM avg_pos ap
         JOIN classes AS cl ON ap.class = cl.class
WHERE ap.average_position = (SELECT MIN(average_position) FROM avg_pos) 
-- Вытягиваю машины с минимальным средним
ORDER BY ap.name
LIMIT 1;

-- Задание 3
WITH avg_class_pos AS (SELECT c.class, AVG(r.position) AS avg
                       FROM cars AS c
                                JOIN results AS r ON c.name = r.car
                       GROUP BY c.class),
                       --  Считаю среднюю позицию для каждого класса
     min_avg_pos AS (SELECT class
                     FROM avg_class_pos
                     WHERE avg = (SELECT MIN(avg) FROM avg_class_pos)),
                    --  Нахожу класс с минимальным средним
     details AS (SELECT c.name, c.class, AVG(r.position) AS average_position, COUNT(r.race) AS race_count
                 FROM cars AS c
                          JOIN results AS r ON c.name = r.car
                 WHERE c.class IN (SELECT class FROM min_avg_pos)
                 GROUP BY c.name, c.class),
                --  вытягиваю данные машин по классу
     summary AS (SELECT c.class, COUNT(r.race) AS total_races
                 FROM cars AS c
                          JOIN Results AS r ON c.name = r.car
                 WHERE c.class IN (SELECT class FROM min_avg_pos)
                 GROUP BY c.class)
                 --  вытягиваю данные машин по классу
SELECT details.name, details.class, details.average_position, details.race_count, c.country, summary.total_races
FROM details
         JOIN classes AS c ON details.class = c.class
         JOIN summary ON details.class = summary.class
ORDER BY details.class, details.name;

-- Задание 4
WITH avg_pos AS (SELECT c.class, AVG(r.position) AS pos
                 FROM cars as c JOIN results AS r ON c.name = r.car
                 GROUP BY c.class
                 HAVING COUNT(DISTINCT c.name) >= 2),
                 --  Считаю среднюю позицию для каждого класса + накладываю ограничение на минимум 2 авто
     details AS (SELECT c.name, c.class, AVG(r.position) AS average_position, COUNT(r.race) AS race_count
                 FROM cars AS c
                          JOIN results AS r ON c.name = r.car
                 GROUP BY c.name, c.class)
                -- собираю данные по каждой машине 
SELECT details.name, details.class, details.average_position, details.race_count, Classes.country
FROM details
         JOIN avg_pos ON details.class = avg_pos.class
         JOIN classes ON details.class = Classes.class
WHERE details.average_position < avg_pos.pos
ORDER BY details.class, details.average_position;
-- сортирую и вывожу данные

-- Задание 5
WITH car_details AS (SELECT c.name          AS car_name,
                            c.class         AS car_class,
                            AVG(r.position) AS average_position,
                            COUNT(r.race)   AS race_count
                     FROM cars c
                              JOIN results r ON c.name = r.car
                     GROUP BY c.name, c.class),
                    -- Собираю данные по каждой машине в классе
     low_avg_classes AS (SELECT car_class, COUNT(car_name) AS low_avg_cnt
                         FROM car_details
                         WHERE average_position > 3.0
                         GROUP BY car_class),
                        --  сортирую авто по средней позиции
     class_max_low_avg AS (SELECT car_class
                           FROM low_avg_classes
                           WHERE low_avg_cnt = (SELECT MAX(low_avg_cnt)  FROM low_avg_classes)),
                                                -- нахожу авто с максимальной средней позицей в классе
     total_races AS (SELECT c.class AS car_class, COUNT(r.race) AS total_races
                     FROM cars c
                              JOIN results r ON c.name = r.car
                     GROUP BY c.class)
                    --  считаю общее кол-во гонок
SELECT cd.car_name, cd.car_class, cd.average_position, cd.race_count, cl.country AS car_country, tr.total_races
FROM car_details cd
         JOIN class_max_low_avg clma ON cd.car_class = clma.car_class
         JOIN classes cl ON cd.car_class = cl.class
         JOIN total_races tr ON cd.car_class = tr.car_class
WHERE cd.average_position > 3.0
ORDER BY (SELECT COUNT(*) FROM car_details WHERE car_class = cd.car_class AND average_position > 3.0), cd.car_name;
