DROP DATABASE IF EXISTS store ;
CREATE DATABASE store;
USE store;


CREATE TABLE stockGroups(
  id int not null auto_increment PRIMARY KEY,
  name VARCHAR(255) NOT NULL
)ENGINE = InnoDB;

CREATE TABLE brands(
  id int not null auto_increment PRIMARY KEY,
  name VARCHAR(255) NOT NULL
)ENGINE = InnoDB;

CREATE TABLE models(
  id int not null auto_increment PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  brand_id int not null,
  group_id int not null,
  constraint foreign key(brand_id) references brands(id),
  constraint foreign key(group_id) references stockGroups(id)
)ENGINE = InnoDB;

CREATE TABLE stock(
  id int not null auto_increment PRIMARY KEY,
  groups_id int not null,
  brand_id int not null,
  model_id int  not null,
  quantity int not null,
  price double not null,
  constraint foreign key (groups_id) references stockGroups(id),
  constraint foreign key (brand_id) references brands(id),
  constraint foreign key (model_id) references models(id)
)ENGINE = InnoDB;

CREATE TABLE clients(
  id int not null auto_increment PRIMARY KEY,
  name varchar(255) not null,
  address varchar(255) not null,
  phone varchar(20) not null,
  email varchar(255)
  )ENGINE = InnoDB;

CREATE TABLE orders(
  id int not null auto_increment PRIMARY KEY,
  client_id int not null,
  stock_id int not null,
  order_quantity int not null,
  dateOfOrder DATE not null,
  constraint foreign key (client_id) references clients(id),
  constraint foreign key (stock_id) references stock(id)
)ENGINE = InnoDB;

CREATE TABLE payments(
  id int not null auto_increment PRIMARY KEY,
  order_id int not null,
  client_id int not null,
  total double not null,
  pay_Date DATE not null,
  constraint foreign key (client_id) references clients(id),
  constraint foreign key (order_id) references orders(id),
  constraint foreign key(order_id) references orders(id)
)ENGINE = InnoDB;

CREATE TABLE discount(
  id int not null auto_increment PRIMARY KEY,
  stock_id int not null,
  min_quantity int not null,
  discount_percentage int not null,
 constraint foreign key (stock_id) references stock(id)
)ENGINE = InnoDB;

CREATE TABLE deliveries(
  id int not null auto_increment PRIMARY KEY,
  stock_id int not null,
  client_id int not null,
  delivery_quantity int not null,
  status ENUM ('At warehouse','Delivering','Delivered'),
  delivery_date DATE not null,
  constraint foreign key(client_id) REFERENCES clients(id),
  constraint foreign key (stock_id) references stock(id)
)ENGINE = InnoDB;


INSERT INTO clients (name, address, phone, email)
VALUES ('Ivan Georgiev', 'ul. Slavqnska 7', '088 528 5767', 'ivangeorgiev@abv.bg'),
		('Petur Ivanov', 'ul. Ivan Vazov 13', '08888 45 500', 'peturivanov@abv.bg'),
		('Mitko Trapov', 'ul. Banishora 25', '08888 21 300', 'mitkotrapov@abv.bg'),
        ('Georgi Nikolaev', 'ul. Aleksandur Stamboliiski 62 ', '0878 396 5765', 'georginikolaev@abv.bg');

INSERT INTO stockGroups (name)
VALUES ('Washing Mashines'),
		('TVs'),
        ('Laptops'),
        ('Fridges');

INSERT INTO brands (name)
VALUES ('Miele'),
		('Sony'),
        ('Apple'),
        ('Beko');

INSERT INTO models (name, brand_id, group_id)
VALUES ('A++', 1, 1),
		('Bravia', 2, 2),
        ('MacBook',3,3),
        ('NoFrost',4,4);

INSERT INTO stock (groups_id, brand_id, model_id, quantity, price)
VALUES (1, 1, 1, 222, 900),
        (2, 2, 2, 333, 2000),
		(3, 3, 3, 555, 3000),
        (4, 4, 4, 444, 4000);

INSERT INTO orders (client_id, stock_id, order_quantity, dateOfOrder)
VALUES (1, 1, 10, '2023-05-07'),
		(2, 2, 11, '2023-11-14'),
		(3, 3, 12, '2023-04-05'),
        (4, 4, 5, '2023-07-05');

INSERT INTO discount (stock_id, min_quantity, discount_percentage)
VALUES (1, 10, 15),
		(2, 5, 10),
        (3, 15, 25),
		(4, 20, 35);

INSERT INTO payments (order_id, client_id, total, pay_Date)
SELECT orders.id, orders.client_id, stock.price * orders.order_quantity, CURDATE()
FROM orders
INNER JOIN stock ON orders.stock_id = stock.id;


INSERT INTO deliveries (client_id, stock_id, delivery_quantity,status, delivery_date)
VALUES (1, 1, 5,'Delivered', '2023-11-22'),
		(2, 2, 10,'At warehouse', '2023-12-23'),
        (3, 3, 21,'Delivering', '2023-01-23'),
		(4, 4, 21,'Delivering', '2023-01-23');
        
        