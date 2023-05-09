/*2*/
SELECT * from clients
where name="Mitko Trapov";

/*3*/
SELECT clients.name, CONCAT(SUM(payments.total), " BGN") AS total_payments
FROM clients
JOIN payments ON payments.client_id = clients.id
GROUP BY clients.name;

/*4*/
select c.name, c.phone, d.status from clients as c
join deliveries as d on d.client_id = c.id;

/*5*/
select m.name as model, b.name as brand from models as m
left join brands as b ON m.brand_id = b.id;

/*6*/
select  sp.name as stockGroup, m.name as model_name from models as m
join stockGroups as sp on m.id in(
select group_id from models as m where m.group_id = sp.id);

/*7*/
SELECT p.client_id, AVG(p.total) AS average_payment
FROM
  (SELECT client_id, SUM(total) AS total
   FROM payments
   GROUP BY client_id) AS p
   GROUP BY p.client_id;

SELECT * FROM deliveries;

/*8*/


DROP TRIGGER if exists fin_del;
delimiter |
CREATE TRIGGER fin_del BEFORE DELETE ON deliveries
FOR EACH ROW 
BEGIN
IF(OLD.status != 'Delivered')
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  'Delivery still being processed';
end if;
END;
|
delimiter ;

Delete from deliveries
where id=2;

DROP TRIGGER if exists notenought_qty;
delimiter |
CREATE TRIGGER notenought_qty BEFORE INSERT ON orders
FOR EACH ROW 
BEGIN
DECLARE qty_instock INT;
SET qty_instock = (SELECT stock.quantity from stock where id = NEW.stock_id);
IF(NEW.order_quantity>qty_instock)
THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =  'Not enought quantity in stock';
end if;
END;
|
delimiter ;

INSERT INTO orders (client_id, stock_id, order_quantity, dateOfOrder)
VALUES (1, 1, 100000, '2023-05-07');

/*9*/
DROP PROCEDURE IF EXISTS client_orders_select;
DELIMITER |
CREATE PROCEDURE client_orders_select(IN client_name VARCHAR(255))
BEGIN
DECLARE total_due DOUBLE;
DECLARE order_id, client_id, stock_id, order_quantity, model_id, brand_id INT;
DECLARE model_name, brand_name VARCHAR(255);
DECLARE done INT DEFAULT FALSE;
DECLARE order_cursor CURSOR FOR
SELECT o.id, o.client_id, o.stock_id, o.order_quantity, m.id, b.id
FROM orders o
INNER JOIN stock s ON o.stock_id = s.id
INNER JOIN models m ON s.model_id = m.id
INNER JOIN brands b ON m.brand_id = b.id
INNER JOIN clients c ON o.client_id = c.id
WHERE c.name = client_name;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN order_cursor;

SET total_due = 0;
SELECT concat('Orders for client: ', client_name) as result;

FETCH order_cursor INTO order_id, client_id, stock_id, order_quantity, model_id, brand_id;
WHILE NOT done DO
SELECT m.name INTO model_name FROM models m WHERE m.id = model_id;
SELECT b.name INTO brand_name FROM brands b WHERE b.id = brand_id;
SELECT (s.price * o.order_quantity) INTO total_due FROM orders o INNER JOIN stock s ON o.stock_id = s.id WHERE o.id = order_id;
SELECT concat('Order: ', order_id, ', Brand: ', brand_name, ', Model: ', model_name, ', Quantity: ', order_quantity, ', Total: ', total_due, ' BGN') as result
GROUP BY order_id;
SET total_due = 0;
FETCH order_cursor INTO order_id, client_id, stock_id, order_quantity, model_id, brand_id;
END WHILE;

CLOSE order_cursor;

END |
DELIMITER ;

CALL client_orders_select('Mitko Trapov')