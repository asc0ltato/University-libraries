-----------------------------ФАКУЛЬТЕТ--------------------------------------
CREATE INDEX idx_faculty_name ON faculty (name);
------------------------------ГРУППА----------------------------------------
CREATE INDEX idx_groupname_name ON groupname (name);
-------------------------------РОЛЬ-----------------------------------------
CREATE INDEX idx_role_role ON role (role);
---------------------------ПОЛЬЗОВАТЕЛЬ-------------------------------------
CREATE INDEX idx_users_lastname_firstname ON users(lastname, firstname);
CREATE INDEX idx_users_studentIDCard ON users(studentIDCard);
------------------------------КНИГА-----------------------------------------
CREATE INDEX idx_book_title ON book(title);
----------------------------ИЗДАТЕЛЬСТВО------------------------------------
CREATE INDEX idx_publishinghouse_name ON publishinghouse(name);
------------------------------АВТОР-----------------------------------------
CREATE INDEX idx_author_lastname_firstname ON author(lastname, firstname);
-------------------------------ЖАНР-----------------------------------------
CREATE INDEX idx_genre_genre ON genre(genre);
----------------------------------------------------------------------------
DROP INDEX idx_faculty_name ON faculty;
DROP INDEX idx_groupname_name ON groupname;
DROP INDEX idx_role_role ON role;
DROP INDEX idx_users_lastname_firstname ON users;
DROP INDEX idx_users_studentIDCard ON users;
DROP INDEX idx_book_title ON book;
DROP INDEX idx_publishinghouse_name ON publishinghouse;
DROP INDEX idx_author_lastname_firstname ON author;
DROP INDEX idx_genre_genre ON genre;

SELECT lastname, firstname FROM users WHERE lastname = 'Lastname80000' and firstname = 'Firstname80000';