
CREATE DATABASE IF NOT EXISTS fitness_network;
USE fitness_network;

-- Удаление таблиц в правильном порядке
DROP TABLE IF EXISTS visits;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS records;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS tariffs;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS trainers;
DROP TABLE IF EXISTS halls;
DROP TABLE IF EXISTS filials;

-- Создание таблиц
CREATE TABLE filials (
    filial_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

CREATE TABLE halls (
    hall_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    filial_id INT NOT NULL,
    CONSTRAINT fk_halls_filials FOREIGN KEY (filial_id) REFERENCES filials(filial_id) ON DELETE CASCADE
);

CREATE TABLE trainers (
    trainer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    specialization VARCHAR(200) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100)
);

CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    passport VARCHAR(20) NOT NULL,
    address VARCHAR(200)
);

CREATE TABLE tariffs (
    tariff_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    access_zone VARCHAR(200) NOT NULL,
    duration_months INT NOT NULL CHECK (duration_months > 0),
    included_visits INT NOT NULL CHECK (included_visits >= 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE subscriptions (
    subscription_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    tariff_id INT NOT NULL,
    sale_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    activation_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Активен',
    CONSTRAINT fk_subscriptions_clients FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    CONSTRAINT fk_subscriptions_tariffs FOREIGN KEY (tariff_id) REFERENCES tariffs(tariff_id)
);

CREATE TABLE services (
    service_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    duration INT NOT NULL CHECK (duration > 0)
);

CREATE TABLE classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    hall_id INT NOT NULL,
    trainer_id INT NOT NULL,
    service_id INT NOT NULL,
    class_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_places INT NOT NULL CHECK (max_places > 0),
    status VARCHAR(20) NOT NULL DEFAULT 'Запланировано',
    CONSTRAINT fk_classes_halls FOREIGN KEY (hall_id) REFERENCES halls(hall_id),
    CONSTRAINT fk_classes_trainers FOREIGN KEY (trainer_id) REFERENCES trainers(trainer_id),
    CONSTRAINT fk_classes_services FOREIGN KEY (service_id) REFERENCES services(service_id)
);

CREATE TABLE records (
    record_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    class_id INT NOT NULL,
    record_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    status VARCHAR(20) NOT NULL DEFAULT 'Записан',
    CONSTRAINT fk_records_clients FOREIGN KEY (client_id) REFERENCES clients(client_id) ON DELETE CASCADE,
    CONSTRAINT fk_records_classes FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE
);

CREATE TABLE payments (
    payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subscription_id BIGINT NOT NULL,
    payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(20) NOT NULL,
    CONSTRAINT fk_payments_subscriptions FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE CASCADE
);

CREATE TABLE visits (
    filial_id INT NOT NULL,
    client_id INT NOT NULL,
    class_id INT NOT NULL,
    visit_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    entry_time TIME NOT NULL,
    locker_number INT CHECK (locker_number > 0),
    visit_status VARCHAR(20) NOT NULL,
    record_id BIGINT,
    payment_id BIGINT,
    PRIMARY KEY (filial_id, client_id, class_id, visit_date),
    CONSTRAINT fk_visits_filials FOREIGN KEY (filial_id) REFERENCES filials(filial_id),
    CONSTRAINT fk_visits_clients FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_visits_classes FOREIGN KEY (class_id) REFERENCES classes(class_id),
    CONSTRAINT fk_visits_records FOREIGN KEY (record_id) REFERENCES records(record_id),
    CONSTRAINT fk_visits_payments FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

-- 1.2. Изменение структуры таблиц
ALTER TABLE visits ADD COLUMN notes TEXT;

-- 1.3. Вставка тестовых записей
INSERT INTO filials (filial_id, name, address, phone) VALUES 
(1, 'FitLife-Центр', 'г. Москва, ул. Ленина, 1', '(495) 123-4567'),
(2, 'FitLife-Север', 'г. Москва, ул. Северная, 10', '(495) 765-4321');

INSERT INTO halls (hall_id, name, capacity, filial_id) VALUES 
(1001, 'Зал №1 (Большой)', 30, 1),
(1002, 'Бассейн', 20, 1),
(1003, 'Зал №2 (Малый)', 25, 1);

INSERT INTO trainers (trainer_id, full_name, specialization, phone, email) VALUES 
(2001, 'Иванова М.А.', 'Yoga, Pilates', '(916) 111-2233', 'ivanova@fitlife.ru'),
(2002, 'Петров С.В.', 'CrossFit', '(916) 222-3344', 'petrov@fitlife.ru'),
(2003, 'Сидорова К.Е.', 'Aqua Aerobics', '(916) 333-4455', 'sidorova@fitlife.ru');

INSERT INTO clients (client_id, full_name, birth_date, phone, email, passport, address) VALUES 
(10000001, 'Иванов Иван Иванович', '1990-05-15', '(916) 111-2233', 'ivanov@mail.ru', '4501 123456', 'г. Москва, ул. Пушкина, 5'),
(10000002, 'Петрова Анна Сергеевна', '1995-08-20', '(916) 222-3344', 'petrova@mail.ru', '4502 654321', 'г. Москва, ул. Гагарина, 7');

INSERT INTO tariffs (tariff_id, name, access_zone, duration_months, included_visits, price) VALUES 
(1, 'Дневной', 'Тренажёрный зал', 1, 0, 3000.00),
(2, 'Безлимит год', 'Все зоны', 12, 0, 18000.00),
(3, 'Соло 8 занятий', 'Групповые программы', 1, 8, 2500.00);

INSERT INTO subscriptions (subscription_id, client_id, tariff_id, sale_date, activation_date, expiration_date, status) VALUES 
(2000000001, 10000001, 2, '2026-10-01', '2026-10-01', '2027-10-01', 'Активен'),
(2000000002, 10000002, 3, '2026-10-05', '2026-10-05', '2026-11-05', 'Активен');

INSERT INTO services (service_id, name, duration) VALUES 
(3001, 'Yoga Mind', 60),
(3002, 'CrossFit Power', 60),
(3003, 'Aqua Aerobics', 45);

INSERT INTO classes (class_id, hall_id, trainer_id, service_id, class_date, start_time, end_time, max_places, status) VALUES 
(400001, 1001, 2001, 3001, '2026-10-10', '18:00:00', '19:00:00', 20, 'Проведено'),
(400002, 1003, 2002, 3002, '2026-10-11', '19:00:00', '20:00:00', 25, 'Проведено'),
(400003, 1002, 2003, 3003, '2026-10-12', '10:00:00', '11:00:00', 15, 'Проведено');

INSERT INTO records (record_id, client_id, class_id, record_date, status) VALUES 
(5000000001, 10000001, 400001, '2026-10-01', 'Пришёл'),
(5000000002, 10000002, 400002, '2026-10-02', 'Пришёл');

INSERT INTO payments (payment_id, subscription_id, payment_date, amount, payment_method) VALUES 
(6000000001, 2000000001, '2026-10-01', 18000.00, 'Карта'),
(6000000002, 2000000002, '2026-10-05', 2500.00, 'Наличные');

INSERT INTO visits (filial_id, client_id, class_id, visit_date, entry_time, locker_number, visit_status, record_id, payment_id) VALUES 
(1, 10000001, 400001, '2026-10-10', '18:30:00', 12, 'Пришёл', 5000000001, 6000000001),
(1, 10000002, 400002, '2026-10-11', '19:00:00', 15, 'Пришёл', 5000000002, 6000000002);

-- 1.4. Обновление и Удаление
UPDATE subscriptions SET status = 'Истёк' WHERE expiration_date < CURRENT_DATE;
DELETE FROM records WHERE status = 'Отменено';

-- 1.5. Создание пользователей (Исправлено для совместимости с MariaDB/XAMPP)
GRANT SELECT, INSERT, UPDATE ON fitness_network.* TO 'fitness_manager'@'localhost' IDENTIFIED BY 'ManagerPass123!';
FLUSH PRIVILEGES;

-- 1.6. Выгрузка метаданных
DESCRIBE filials;
DESCRIBE visits;


-- ============================================================================ --
-- ЛАБОРАТОРНАЯ РАБОТА. ПРОГРАММНАЯ РЕАЛИЗАЦИЯ НА SQL
-- 
-- ЧАСТЬ 2. ЗАПРОСЫ К БАЗЕ ДАННЫХ 
-- ============================================================================ --

USE fitness_network;

-- 2.1. Неявное соединение таблиц с фильтром (WHERE) и сортировкой (ORDER BY)
SELECT c.full_name, s.expiration_date, s.status
FROM clients c, subscriptions s
WHERE c.client_id = s.client_id AND s.status = 'Активен'
ORDER BY s.expiration_date ASC;

-- 2.2. Явное соединение таблиц (JOIN)
SELECT cl.class_date, cl.start_time, s.name AS service_name,
       t.full_name AS trainer_name, h.name AS hall_name
FROM classes cl
INNER JOIN services s ON cl.service_id = s.service_id
INNER JOIN trainers t ON cl.trainer_id = t.trainer_id
INNER JOIN halls    h ON cl.hall_id    = h.hall_id;

-- 2.3. Агрегирующие операции, группировка GROUP BY и фильтрация HAVING
SELECT payment_method,
       SUM(amount)   AS total_revenue,
       COUNT(payment_id) AS transaction_count,
       AVG(amount)   AS average_amount
FROM payments
GROUP BY payment_method
HAVING SUM(amount) > 5000.00;

-- 2.4. Вложенные подзапросы (IN, ALL)
SELECT full_name
FROM clients
WHERE client_id IN (
    SELECT client_id FROM subscriptions WHERE tariff_id IN (
        SELECT tariff_id FROM tariffs WHERE price > ALL (
            SELECT price FROM tariffs WHERE name LIKE '%Дневной%'
        )
    )
);

-- 2.5. Функции управления потоком (CASE)
SELECT class_id, max_places,
       CASE
           WHEN max_places >= 25 THEN 'Высокая вместимость'
           WHEN max_places BETWEEN 16 AND 24 THEN 'Средняя вместимость'
           ELSE 'Камерный зал / Индивидуально'
       END AS capacity_status
FROM classes;

-- 2.6. Постоянное представление (VIEW) и временное (WITH)
-- CREATE OR REPLACE 
CREATE OR REPLACE VIEW view_monthly_financials AS
SELECT YEAR(payment_date)  AS payment_year,
       MONTH(payment_date) AS payment_month,
       SUM(amount)         AS revenue
FROM payments
GROUP BY YEAR(payment_date), MONTH(payment_date);

-- Проверка созданного VIEW
SELECT * FROM view_monthly_financials;

-- Временное представление (WITH)
WITH payment_stats AS (
    SELECT amount, payment_method FROM payments
)
SELECT payment_method, AVG(amount) AS average_receipt
FROM payment_stats
GROUP BY payment_method;

-- 2.7. Индексы и анализ производительности (EXPLAIN)
-- IF NOT EXISTS 
CREATE INDEX IF NOT EXISTS idx_classes_date ON classes(class_date);
EXPLAIN SELECT * FROM classes WHERE class_date = '2026-10-10';

-- 2.8. Транзакция
-- INSERT IGNORE 
START TRANSACTION;
INSERT IGNORE INTO subscriptions
    (subscription_id, client_id, tariff_id, sale_date, activation_date, expiration_date, status)
VALUES
    (2000000003, 10000001, 1, '2026-11-01', '2026-11-01', '2026-12-01', 'Активен');

INSERT IGNORE INTO payments
    (payment_id, subscription_id, payment_date, amount, payment_method)
VALUES
    (6000000003, 2000000003, '2026-11-01', 3000.00, 'Карта');
COMMIT;


SET @sql_query = 'SELECT full_name, phone, email FROM clients WHERE full_name LIKE ?'; PREPARE find_client_phone FROM @sql_query; SET @name_param = '%Иванов%'; EXECUTE find_client_phone USING @name_param; DEALLOCATE PREPARE find_client_phone;

