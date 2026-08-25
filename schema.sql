create schema if not exists raw;

drop table if exists raw.order_items, raw.orders, raw.products, raw.users, raw.categories;

create table raw.categories (
    id   int primary key,
    name varchar(100) not null
);

create table raw.users (
    id        int primary key,
    name      varchar(100) not null,
    last_name varchar(100) not null
);

create table raw.products (
    id          int primary key,
    category_id int not null references raw.categories(id),
    name        varchar(200) not null,
    stock       int not null,
    price       numeric(12,2) not null
);

create table raw.orders (
    id          int primary key,
    user_id     int not null references raw.users(id),
    total_price numeric(12,2) not null,
    order_date  timestamp not null
);

create table raw.order_items (
    id               int primary key,
    order_id         int not null references raw.orders(id),
    product_id       int not null references raw.products(id),
    historical_price numeric(12,2) not null,
    quantity         int not null
);