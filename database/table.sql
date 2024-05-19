--DROP DATABASE Library;
--ALTER DATABASE Library SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
USE master;
GO
CREATE DATABASE Library ON PRIMARY
(
    NAME = N'Library_mdf',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Library_mdf.mdf',
    SIZE = 10240KB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 1024KB
),
FILEGROUP FG1
(
    NAME = N'Library_fg1',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Library_fg1.ndf',
    SIZE = 10240KB,
    MAXSIZE = 1GB,
    FILEGROWTH = 25%
),
FILEGROUP FG2
(
    NAME = N'Library_fg2',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Library_fg2.ndf',
    SIZE = 10240KB,
    MAXSIZE = 1GB,
    FILEGROWTH = 25%
)
LOG ON
(
    NAME = N'Library_log',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Library_log.ldf',
    SIZE = 10240KB,
    MAXSIZE = 2048GB,
    FILEGROWTH = 10%
);
GO
use Library;
------------------------------------------------------------------
CREATE TABLE role (
  id int IDENTITY(1,1) PRIMARY KEY,
  role varchar(50) NOT NULL UNIQUE 
) ON FG1;

CREATE TABLE users (
  id int IDENTITY(1,1) PRIMARY KEY,
  role_id int NOT NULL,
  groupname_id int DEFAULT NULL,
  studentIDcard int DEFAULT NULL,
  lastname varchar(255) NOT NULL,
  firstname varchar(255) NOT NULL,
  patronymic varchar(255) NOT NULL,
  birthday date NOT NULL,
  login varchar(255) NOT NULL UNIQUE, 
  password varchar(255) NOT NULL,
  create_at datetime NOT NULL DEFAULT GETDATE()
) ON FG1;

CREATE TABLE groupname (
  id int IDENTITY(1,1) PRIMARY KEY,
  faculty_id int NOT NULL,
  year int NOT NULL,
  name varchar(50) NOT NULL
) ON FG1;

CREATE TABLE faculty (
  id int IDENTITY(1,1) PRIMARY KEY,
  name varchar(255) NOT NULL UNIQUE
) ON FG1;

CREATE TABLE listgetbooks (
  id int IDENTITY(1,1) PRIMARY KEY,
  user_id int NOT NULL,
  sample_id int NOT NULL,
  takedate date NOT NULL,
  returndate date DEFAULT NULL,
  mark int DEFAULT NULL
) ON FG2;

CREATE TABLE sample (
  id int IDENTITY(1,1) PRIMARY KEY,
  book_id int NOT NULL,
  description varchar(255) NOT NULL,
  presence tinyint CHECK (presence IN (0, 1))
) ON FG2;

CREATE TABLE book (
  id int PRIMARY KEY,
  publishinghouse_id int NOT NULL,
  title varchar(255) NOT NULL,
  year int NOT NULL,
  pages smallint NOT NULL
);

CREATE TABLE publishinghouse (
  id int IDENTITY(1,1) PRIMARY KEY,
  name varchar(255) NOT NULL UNIQUE,
  address varchar(255) NOT NULL
) ON FG2;

CREATE TABLE genre (
  id int IDENTITY(1,1) PRIMARY KEY,
  genre varchar(255) NOT NULL UNIQUE
) ON FG2;

CREATE TABLE books_genres (
	book_id int,
	genre_id int,
	PRIMARY KEY (book_id, genre_id),
	FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE NO ACTION,
	FOREIGN KEY (genre_id) REFERENCES genre (id) ON DELETE NO ACTION
) ON FG2;

CREATE TABLE author (
  id int IDENTITY(1,1) PRIMARY KEY,
  lastname varchar(255) NOT NULL,
  firstname varchar(255) NOT NULL,
  birthday date
) ON FG2;

CREATE TABLE books_authors (
	book_id int,
	author_id int,
	PRIMARY KEY (book_id, author_id),
	FOREIGN KEY (book_id) REFERENCES book (id) ON DELETE NO ACTION,
	FOREIGN KEY (author_id) REFERENCES author (id) ON DELETE NO ACTION
) ON FG2;

ALTER TABLE users
ADD CONSTRAINT fk_users_role
FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE NO ACTION;

ALTER TABLE users
ADD CONSTRAINT fk_users_groupname
FOREIGN KEY (groupname_id) REFERENCES groupname(id) ON DELETE NO ACTION;

ALTER TABLE groupname 
ADD CONSTRAINT fk_groupname_faculty
FOREIGN KEY (faculty_id) REFERENCES faculty(id) ON DELETE NO ACTION;

ALTER TABLE listgetbooks 
ADD CONSTRAINT fk_listgetbooks_users
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE NO ACTION;

ALTER TABLE listgetbooks 
ADD CONSTRAINT fk_listgetbooks_sample 
FOREIGN KEY (sample_id) REFERENCES sample(id) ON DELETE NO ACTION;

ALTER TABLE sample 
ADD CONSTRAINT fk_sample_book 
FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE NO ACTION;

ALTER TABLE book 
ADD CONSTRAINT fk_book_publishinghouse 
FOREIGN KEY (publishinghouse_id) REFERENCES publishinghouse(id) ON DELETE NO ACTION;

ALTER TABLE books_authors 
ADD CONSTRAINT fk_books_authors_book
FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE NO ACTION;

ALTER TABLE books_authors 
ADD CONSTRAINT fk_books_authors_author 
FOREIGN KEY (author_id) REFERENCES author(id) ON DELETE NO ACTION;

ALTER TABLE books_genres 
ADD CONSTRAINT fk_books_genres_book
FOREIGN KEY (book_id) REFERENCES book(id) ON DELETE NO ACTION;

ALTER TABLE books_genres
ADD CONSTRAINT fk_books_genres_genre 
FOREIGN KEY (genre_id) REFERENCES genre(id) ON DELETE NO ACTION;
------------------------------------------------------------------
DROP TABLE genre;
DROP TABLE books_genres;
DROP TABLE author;
DROP TABLE books_authors;
DROP TABLE publishinghouse;
DROP TABLE book;
DROP TABLE sample;
DROP TABLE listgetbooks;
DROP TABLE role;
DROP TABLE users;
DROP TABLE groupname;
DROP TABLE faculty;