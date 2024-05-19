--Представление для списка читателей
CREATE VIEW ReaderDetails AS
SELECT u.id AS user_id, u.lastname, u.firstname, u.patronymic, u.birthday, 
       r.role, g.name AS group_name, f.name AS faculty_name
FROM users u
INNER JOIN role r ON u.role_id = r.id
LEFT JOIN groupname g ON u.groupname_id = g.id
LEFT JOIN faculty f ON g.faculty_id = f.id
WHERE u.role_id = 3;
----------------------------------------------------------------------------
SELECT * FROM ReaderDetails;

DROP VIEW ReaderDetails;
----------------------------------------------------------------------------
--Представление для списка библиотекарей
CREATE VIEW LibrarianDetails AS
SELECT u.id AS user_id, u.lastname, u.firstname, u.patronymic, u.birthday, r.role
FROM users u
INNER JOIN role r ON u.role_id = r.id
LEFT JOIN groupname g ON u.groupname_id = g.id
LEFT JOIN faculty f ON g.faculty_id = f.id
WHERE u.role_id = 2;
----------------------------------------------------------------------------
SELECT * FROM LibrarianDetails;

DROP VIEW LibrarianDetails;
----------------------------------------------------------------------------
--Представление для списка книг с информацией об авторах и жанрах
CREATE VIEW BookDetails AS
SELECT b.id AS book_id, b.title, b.year, b.pages, 
       p.name AS publishing_house, 
       a.lastname AS author_lastname, a.firstname AS author_firstname, 
       STRING_AGG(g.genre, ', ') AS genres
FROM book b
INNER JOIN publishinghouse p ON b.publishinghouse_id = p.id
LEFT JOIN books_authors ba ON b.id = ba.book_id
LEFT JOIN author a ON ba.author_id = a.id
LEFT JOIN books_genres bg ON b.id = bg.book_id
LEFT JOIN genre g ON bg.genre_id = g.id
GROUP BY b.id, b.title, b.year, b.pages, p.name, a.lastname, a.firstname;
----------------------------------------------------------------------------
SELECT * FROM BookDetails;

DROP VIEW BookDetails;
----------------------------------------------------------------------------
--Представление для списка книг, которые находятся в наличии
CREATE VIEW AvailableBooks AS
SELECT b.id AS book_id, b.title, b.year, b.pages, 
       p.name AS publishing_house, 
       STRING_AGG(g.genre, ', ') AS genres
FROM book b
INNER JOIN publishinghouse p ON b.publishinghouse_id = p.id
LEFT JOIN sample s ON b.id = s.book_id
LEFT JOIN books_genres bg ON b.id = bg.book_id
LEFT JOIN genre g ON bg.genre_id = g.id
WHERE s.presence = 1
GROUP BY b.id, b.title, b.year, b.pages, p.name;
----------------------------------------------------------------------------
SELECT * FROM AvailableBooks;

DROP VIEW AvailableBooks;