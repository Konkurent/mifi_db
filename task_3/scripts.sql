-- Задание 1
SELECT c.name,
       c.email,
       c.phone,
       COUNT(b.id_booking)                     AS total_bookings,
       STRING_AGG(DISTINCT h.name, ', ')       AS hotels,
    --   Собираю строку имен по шаблону (разделитель ,)
       AVG(b.check_out_date - b.check_in_date) AS average_stay
    --    Среднее кол-во дней в броне
FROM customer c
         JOIN
     booking b ON c.id_customer = b.id_customer
         JOIN
     room r ON b.id_room = r.id_room
         JOIN
     hotel h ON r.id_hotel = h.id_hotel
GROUP BY c.id_customer, c.name, c.email, c.phone
HAVING COUNT(DISTINCT b.id_booking) > 2
   AND COUNT(DISTINCT h.id_hotel) > 1
--    Сортирую свои группы по условиям блоне > 2 + > 1 отеля
ORDER BY total_bookings DESC;

-- Задание 2
WITH customer_summary AS (SELECT c.id_customer,
                                 c.name,
                                 COUNT(b.id_booking)                                 AS total_bookings,
                                 COUNT(DISTINCT r.id_hotel)                          AS unique_hotels,
                                 SUM(r.price * (b.check_out_date - b.check_in_date)) AS total_spent
                          FROM customer c
                                   JOIN
                               booking b ON c.id_customer = b.id_customer
                                   JOIN
                               room r ON b.id_room = r.id_room
                          GROUP BY c.id_customer, c.name),
     customers_with_multiple_bookings AS (SELECT id_customer,
                                                 name,
                                                 total_bookings,
                                                 unique_hotels,
                                                 total_spent
                                          FROM customer_summary
                                          WHERE total_bookings > 2
                                            AND unique_hotels > 1),
                                            --   Определил клиентов, которые сделали более двух бронирований и забронировали номера в более чем одном отеле
     customers_spending_over_500 AS (SELECT id_customer,
                                            name,
                                            total_spent,
                                            total_bookings,
                                            unique_hotels
                                     FROM customer_summary
                                     WHERE total_spent > 500)
                                    --  Определил клиентов, которые поторатили больше $500
SELECT cm.id_customer AS "ID_customer",
       cm.name,
       cm.total_bookings,
       cm.total_spent,
       cm.unique_hotels
FROM customers_with_multiple_bookings cm
         JOIN
     customers_spending_over_500 cs ON cm.id_customer = cs.id_customer
ORDER BY cm.total_spent ASC;

-- Задание 3
WITH hotel_category AS (SELECT h.id_hotel,
                               h.name  AS hotel_name,
                               CASE
                                   WHEN AVG(r.price) < 175 THEN 'Дешевый'
                                   WHEN AVG(r.price) <= 300 THEN 'Средний'
                                   ELSE 'Дорогой'
                                   END AS category
                        FROM hotel h
                                 JOIN
                             room r ON h.id_hotel = r.id_hotel
                        GROUP BY h.id_hotel, h.name),
                        -- Определяю катешгорию отеля
     customer_preferences AS (SELECT c.id_customer,
                                     c.name,
                                     CASE
                                         WHEN EXISTS (SELECT 1
                                                      FROM booking b
                                                               JOIN room r ON b.id_room = r.id_room
                                                               JOIN hotel_category hc ON r.id_hotel = hc.id_hotel
                                                      WHERE b.id_customer = c.id_customer
                                                        AND hc.category = 'Дорогой') THEN 'дорогой'
                                         WHEN EXISTS (SELECT 2
                                                      FROM booking b
                                                               JOIN room r ON b.id_room = r.id_room
                                                               JOIN hotel_category hc ON r.id_hotel = hc.id_hotel
                                                      WHERE b.id_customer = c.id_customer
                                                        AND hc.category = 'Средний') THEN 'средний'
                                         ELSE 'Дешевый'
                                         END                                  AS preferred_hotel_type,
                                     STRING_AGG(DISTINCT hc.hotel_name, ', ') AS visited_hotels
                                    --  Поровожу категоризацию клиента
                              FROM customer c
                                       JOIN
                                   booking b ON c.id_customer = b.id_customer
                                       JOIN
                                   room r ON b.id_room = r.id_room
                                       JOIN
                                   hotel_category hc ON r.id_hotel = hc.id_hotel
                              GROUP BY c.id_customer, c.name)
SELECT id_customer,
       name,
       preferred_hotel_type,
       visited_hotels
FROM customer_preferences
ORDER BY CASE preferred_hotel_type
             WHEN 'Дешевый' THEN 1
             WHEN 'Средний' THEN 2
             WHEN 'Дорогой' THEN 3
             END,
            --  Соритирую категории
         id_customer;