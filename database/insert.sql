SELECT * FROM genre;
SELECT * FROM books_genres;
SELECT * FROM author;
SELECT * FROM books_authors;
SELECT * FROM publishinghouse;
SELECT * FROM book;
SELECT * FROM sample;
SELECT * FROM listgetbooks;
SELECT * FROM role;
SELECT * FROM users;
SELECT * FROM groupname;
SELECT * FROM faculty;
------------------------------------------------------------------
INSERT INTO role (role) VALUES
('AdminRole'),
('LibrarianRole'),
('ReaderRole');

INSERT INTO faculty (name) VALUES
('Факультет информационных технологий'),
('Лесохозяйственный факультет'),
('Факультет лесной инженерии, материаловедения и дизайна'),
('Факультет технологии органических веществ'),
('Факультет принттехнологий и медиакоммуникаций'),
('Инженерно-экономический факультет'),
('Факультет химической технологии и техники');

INSERT INTO groupname (faculty_id, year, name) VALUES
(1, 2024, '1-1'),
(2, 2023, '1-2'),
(3, 2024, '1-3'),
(4, 2022, '1-4'),
(5, 2023, '1-5');

INSERT INTO users (role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password)
VALUES
(1, null, null, 'Красовский', 'Евгений', 'Сергеевич', '1999-04-30', 'admin', 'admin'),
(3, 2, 100000, 'Петров', 'Александр', 'Иванович', '1995-08-20', 'reader1', 'reader1'),
(2, null, null, 'Сидорова', 'Елена', 'Александровна', '1992-03-10', 'librarian1', 'librarian1'),
(2, null, null, 'Козлов', 'Дмитрий', 'Петрович', '1988-11-28', 'librarian2', 'librarian2'),
(3, 5, 100001, 'Михайлова', 'Ольга', 'Дмитриевна', '1993-06-05', 'reader2', 'reader2');

INSERT INTO genre (genre) VALUES
('Научная фантастика'),
('Детектив'),
('Фэнтези'),
('Приключения'),
('Роман');

INSERT INTO author (lastname, firstname, birthday) VALUES
('Толстой', 'Лев', '1832-04-25'),
('Достоевский', 'Федор', '1799-04-25'),
('Чехов', 'Антон', '1822-04-25'),
('Пушкин', 'Александр', '1812-04-25'),
('Гоголь', 'Николай', '1802-04-25');

INSERT INTO publishinghouse (name, address) VALUES
('Издательство Азбука', 'ул. Ленина, 10'),
('Издательство Просвещение', 'пр. Победы, 25'),
('Издательство Мир', 'пер. Советский, 5'),
('Издательство Харвест', 'ул. Гагарина, 15'),
('Издательство Дрофа', 'пр. Кирова, 30');

INSERT INTO book (id, publishinghouse_id, title, year, pages) VALUES
(1, 1, 'Война и мир', 1869, 1225),
(2, 2, 'Преступление и наказание', 1866, 671),
(3, 3, 'Три сестры', 1901, 184),
(4, 4, 'Евгений Онегин', 1833, 236),
(5, 5, 'Мёртвые души', 1842, 377);

INSERT INTO books_authors (book_id, author_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

INSERT INTO books_genres (book_id, genre_id) VALUES
(1, 3),
(1, 2),
(2, 3),
(3, 1),
(4, 1),
(5, 2);
----------------------------------------------------------------------
-----------------ВСТАВКА ЗНАЧЕНИЙ В ЭКЗЕМПЛЯРЫ------------------------
----------------------------------------------------------------------
CREATE PROCEDURE InsertSampleBooks
AS
BEGIN
    DECLARE @counter INT
    SET @counter = 1
    
    WHILE @counter <= 20
    BEGIN
        DECLARE @book_id INT
        SET @book_id = CAST(RAND() * 5 + 1 AS INT)
        
        INSERT INTO sample (book_id, description, presence)
        VALUES (@book_id, 'Описание книги ' + CAST(@counter AS VARCHAR), 1)
        
        SET @counter = @counter + 1
    END
END
----------------------------------------------------------------------
EXEC InsertSampleBooks
----------------------------------------------------------------------
----------------------ВСТАВКА 100000 СТРОК----------------------------
----------------------------------------------------------------------
CREATE OR ALTER PROCEDURE InsertUsers
AS
BEGIN
    DECLARE @counter INT = 1
    DECLARE @role_id INT
    DECLARE @groupname_id INT
    DECLARE @studentIDcard INT
    DECLARE @lastname VARCHAR(255)
    DECLARE @firstname VARCHAR(255)
    DECLARE @patronymic VARCHAR(255)
    DECLARE @birthday DATE
    DECLARE @login VARCHAR(255)
    DECLARE @password VARCHAR(255)

    WHILE @counter <= 100000
    BEGIN
        SET @role_id = CASE WHEN @counter % 2 = 0 THEN 2 ELSE 3 END
        SET @groupname_id = CASE WHEN @role_id = 3 THEN CAST(RAND() * 4 + 1 AS INT) ELSE NULL END
        SET @studentIDcard = CASE WHEN @role_id = 3 THEN @counter + 100002 ELSE NULL END
        SET @lastname = 'Lastname' + CAST(@counter AS VARCHAR)
        SET @firstname = 'Firstname' + CAST(@counter AS VARCHAR)
        SET @patronymic = 'Patronymic' + CAST(@counter AS VARCHAR)
        SET @birthday = DATEADD(year, -(@counter % 30 + 18), GETDATE())
        SET @login = 'Login' + CAST(@counter AS VARCHAR)
        SET @password = 'Password' + CAST(@counter AS VARCHAR)

        INSERT INTO users (role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password)
        VALUES (@role_id, @groupname_id, @studentIDcard, @lastname, @firstname, @patronymic, @birthday, @login, @password)

        SET @counter = @counter + 1
    END
END
----------------------------------------------------------------------
EXEC InsertUsers
----------------------------------------------------------------------
DELETE FROM users;