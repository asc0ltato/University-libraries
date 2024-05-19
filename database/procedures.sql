----------------------------------------------------------------------
------------------------РЕГИСТРАЦИЯ ЧИТАТЕЛЯ--------------------------
----------------------------------------------------------------------
CREATE PROCEDURE RegisterReader
    @groupname_id int,
    @studentIDcard int,
    @lastname varchar(255),
    @firstname varchar(255),
    @patronymic varchar(255),
    @birthday date,
    @login varchar(255),
    @password varchar(255)
AS
BEGIN
    DECLARE @readerRoleId INT;
    DECLARE @readerUserExists INT;
    BEGIN TRY
        SELECT @readerRoleId = id FROM role WHERE role = 'ReaderRole';

        IF @readerRoleId IS NULL
        BEGIN
            INSERT INTO role (role) VALUES ('ReaderRole');
            SET @readerRoleId = SCOPE_IDENTITY(); 
        END

        SELECT @readerUserExists = COUNT(*) FROM sys.server_principals WHERE name = 'ReaderUser';

        IF @readerUserExists = 0
        BEGIN
            CREATE LOGIN ReaderUser WITH PASSWORD = '321';
            CREATE USER ReaderUser FOR LOGIN ReaderUser;
            ALTER ROLE ReaderRole ADD MEMBER ReaderUser;
        END

        INSERT INTO users (role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password)
        VALUES (@readerRoleId, @groupname_id, @studentIDcard, @lastname, @firstname, @patronymic, @birthday, @login, @password);

        PRINT 'Пользователь успешно зарегистрирован как читатель';
    END TRY
    BEGIN CATCH
        PRINT 'При регистрации пользователя произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Триггер, в котором произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END;
GO

EXEC RegisterReader @groupname_id = 1, @studentIDcard = 123456, @lastname = 'Иванов', @firstname = 'Петр', @patronymic = 'Сергеевич', @birthday = '1990-05-15', @login = 'ivanov_p', @password = 'ivanov_pass123';
EXEC RegisterReader @groupname_id = 1, @studentIDcard = 123456, @lastname = 'Иванов', @firstname = 'Петр', @patronymic = 'Сергеевич', @birthday = '1990-05-15', @login = 'ivanov_m', @password = 'ivanov_pass123';
EXEC RegisterReader @groupname_id = 1, @studentIDcard = 123456, @lastname = 'Иванов', @firstname = 'Петр', @patronymic = 'Сергеевич', @birthday = '1990-05-15', @login = 'ivanov_s', @password = 'ivanov_pass123';
EXEC RegisterReader @groupname_id = 100, @studentIDcard = 132453, @lastname = 'Иванов', @firstname = 'Петр', @patronymic = 'Сергеевич', @birthday = '1990-05-15', @login = 'ivanov_k', @password = 'ivanov_pass123';
delete from users where id = 6;
----------------------------------------------------------------------
------------------------ВЗЯТИЕ КНИГ В АРЕНДУ--------------------------
----------------------------------------------------------------------
CREATE PROCEDURE BorrowBook
    @userId INT,
    @bookId INT
AS
BEGIN
	BEGIN TRY
		DECLARE @sampleId INT;
		DECLARE @AlreadyBorrowed BIT;

		SELECT @AlreadyBorrowed = CASE WHEN COUNT(lg.id) > 0 THEN 1 ELSE 0 END
        FROM listgetbooks lg
        JOIN sample s ON lg.sample_id = s.id
        WHERE lg.user_id = @userId AND s.book_id = @bookId AND lg.returndate IS NULL;

		IF @AlreadyBorrowed = 1
        BEGIN
            PRINT 'Пользователь уже взял экземпляр этой книги';
        END
        ELSE
        BEGIN
            SELECT TOP 1 @sampleId = id FROM sample WHERE book_id = @bookId AND presence = 1;

            IF (@sampleId IS NOT NULL)
            BEGIN    
                INSERT INTO listgetbooks (user_id, sample_id, takedate) 
                VALUES (@userId, @sampleId, GETDATE());
            
                UPDATE sample 
                SET presence = 0 
                WHERE id = @sampleId;

                PRINT 'Книга успешно взята в аренду';
            END
            ELSE
            BEGIN
                PRINT 'Нет доступных экземпляров книги';
            END
        END
    END TRY
    BEGIN CATCH
        PRINT 'При аренде книги произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END
GO
----------------------------------------------------------------------
-------------------------ВОЗВРАТ КНИГИ--------------------------------
----------------------------------------------------------------------
CREATE PROCEDURE ReturnBookReader
    @listGetBookId INT,
    @mark INT
AS
BEGIN
    BEGIN TRY
        DECLARE @sampleId INT;
        DECLARE @UserId INT;
        DECLARE @BookId INT;
        DECLARE @AlreadyRated BIT;

        SELECT @sampleId = sample_id, @UserId = user_id
        FROM listgetbooks
        WHERE id = @listGetBookId;

        SELECT @BookId = book_id
        FROM sample
        WHERE id = @sampleId;

        IF @sampleId IS NOT NULL AND @UserId IS NOT NULL AND @BookId IS NOT NULL
        BEGIN
            SELECT @AlreadyRated = CASE WHEN COUNT(lg.mark) > 0 THEN 1 ELSE 0 END
            FROM listgetbooks lg
            JOIN sample s ON lg.sample_id = s.id
            WHERE lg.user_id = @UserId AND s.book_id = @BookId AND lg.mark IS NOT NULL;

            IF @AlreadyRated = 1
            BEGIN
                UPDATE listgetbooks 
                SET returndate = GETDATE(), mark = NULL
                WHERE id = @listGetBookId AND returndate IS NULL;
            END
            ELSE
            BEGIN
                UPDATE listgetbooks 
                SET returndate = GETDATE(), mark = @mark
                WHERE id = @listGetBookId AND returndate IS NULL;
            END

            UPDATE sample 
            SET presence = 1 
            WHERE id = @sampleId;

            PRINT 'Книга успешно возвращена';
        END
        ELSE
        BEGIN
            PRINT 'При возврате книги произошла ошибка: Некорректные данные';
        END;
    END TRY
    BEGIN CATCH
        PRINT 'При возврате книги произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END
GO
----------------------------------------------------------------------
-----------------ПОЛУЧЕНИЕ СПИСКА ВЗЯТЫХ КНИГ-------------------------
----------------------------------------------------------------------
CREATE FUNCTION GetBorrowedBooks(@userId INT)
RETURNS TABLE
AS
RETURN (
    SELECT l.id, b.title, l.takedate
    FROM listgetbooks l
    JOIN sample s ON l.sample_id = s.id
    JOIN book b ON s.book_id = b.id
    WHERE l.user_id = @userId AND l.returndate IS NULL
);
GO
----------------------------------------------------------------------
----------------ПОИСК ПО НАЗВАНИЮ КНИГИ В РЕЙТИНГЕ--------------------
----------------------------------------------------------------------
CREATE FUNCTION dbo.SearchBooksByTitleInRating (@title NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
    SELECT b.id, b.title,
        STUFF((SELECT DISTINCT ', ' + g.genre 
               FROM books_genres bg 
               JOIN genre g ON bg.genre_id = g.id 
               WHERE bg.book_id = b.id FOR XML PATH('')), 1, 2, '') AS genres,
        STUFF((SELECT DISTINCT ', ' + a.lastname + ' ' + a.firstname 
               FROM books_authors ba 
               JOIN author a ON ba.author_id = a.id 
               WHERE ba.book_id = b.id FOR XML PATH('')), 1, 2, '') AS authors,
        p.name AS publishinghouse, AVG(l.mark) AS average_rating
    FROM book b
    JOIN sample s ON b.id = s.book_id
    JOIN listgetbooks l ON l.sample_id = s.id
    LEFT JOIN publishinghouse p ON b.publishinghouse_id = p.id
    WHERE b.title LIKE '%' + @title + '%'
    GROUP BY b.id, b.title, p.name
);
GO
----------------------------------------------------------------------
----------------ПОЛУЧЕНИЕ СПИСКА РЕЙТИНГА КНИГ------------------------
----------------------------------------------------------------------
CREATE FUNCTION dbo.GetBookRatings()
RETURNS TABLE
AS
RETURN
(
    SELECT b.id, b.title,
        STUFF((SELECT DISTINCT ', ' + g.genre 
               FROM books_genres bg 
               JOIN genre g ON bg.genre_id = g.id 
               WHERE bg.book_id = b.id FOR XML PATH('')), 1, 2, '') AS genres,
        STUFF((SELECT DISTINCT ', ' + a.lastname + ' ' + a.firstname 
               FROM books_authors ba 
               JOIN author a ON ba.author_id = a.id 
               WHERE ba.book_id = b.id FOR XML PATH('')), 1, 2, '') AS authors,
        p.name AS publishinghouse, AVG(l.mark) AS average_rating
    FROM book b
    JOIN sample s ON b.id = s.book_id
    JOIN listgetbooks l ON l.sample_id = s.id
    LEFT JOIN publishinghouse p ON b.publishinghouse_id = p.id
    GROUP BY b.id, b.title, p.name
);
GO
--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------
------------------------ДОБАВЛЕНИЕ БИБЛИОТЕКАРЯ-----------------------
----------------------------------------------------------------------
CREATE PROCEDURE AddLibrarian
    @lastname varchar(255),
    @firstname varchar(255),
    @patronymic varchar(255),
    @birthday date,
    @login varchar(255),
    @password varchar(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO users (role_id, lastname, firstname, patronymic, birthday, login, password)
        VALUES (2, @lastname, @firstname, @patronymic, @birthday, @login, @password);

        PRINT 'Библиотекарь успешно добавлен';
    END TRY
    BEGIN CATCH
        PRINT 'При добавлении читателя произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END;
GO
----------------------------------------------------------------------
------------------------ДОБАВЛЕНИЕ ЧИТАТЕЛЯ---------------------------
----------------------------------------------------------------------
CREATE PROCEDURE AddReader
	@groupname_id int,
	@studentIDcard int,
    @lastname varchar(255),
    @firstname varchar(255),
    @patronymic varchar(255),
    @birthday date,
    @login varchar(255),
    @password varchar(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO users (role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password)
        VALUES (3, @groupname_id, @studentIDcard, @lastname, @firstname, @patronymic, @birthday, @login, @password);

        PRINT 'Читатель успешно добавлен';
    END TRY
    BEGIN CATCH
        PRINT 'При добавлении читателя произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END;
GO
----------------------------------------------------------------------
----------------ОБНОВЛЕНИЕ ДАННЫХ О БИБЛИОТЕКАРЕ----------------------
----------------------------------------------------------------------
CREATE PROCEDURE UpdateLibrarian
    @user_id int,
    @lastname varchar(255),
    @firstname varchar(255),
    @patronymic varchar(255),
    @birthday date
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE users
        SET lastname = @lastname,
            firstname = @firstname,
            patronymic = @patronymic,
            birthday = @birthday
        WHERE id = @user_id;

        COMMIT TRANSACTION; 

        PRINT 'Данные библиотекаря успешно обновлены';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'При обновлении данных библиотекаря произошла ошибка: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO
----------------------------------------------------------------------
--------------------ОБНОВЛЕНИЕ ДАННЫХ О ЧИТАТЕЛЕ----------------------
----------------------------------------------------------------------
CREATE PROCEDURE UpdateReader
    @user_id int,
	@groupname_id int,
    @lastname varchar(255),
    @firstname varchar(255),
    @patronymic varchar(255),
    @birthday date
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE users
        SET groupname_id = @groupname_id,
			lastname = @lastname,
            firstname = @firstname,
            patronymic = @patronymic,
            birthday = @birthday
        WHERE id = @user_id;

        COMMIT TRANSACTION; 

        PRINT 'Данные читателя успешно обновлены';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT 'При обновлении данных читателя произошла ошибка: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO
----------------------------------------------------------------------
-----------------------УДАЛЕНИЕ ПОЛЬЗОВАТЕЛЯ--------------------------
----------------------------------------------------------------------
CREATE PROCEDURE DeleteUser
    @userId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM users WHERE id = @userId)
        BEGIN
            THROW 50001, 'Пользователя с таким ID не существует', 1;
        END
        ELSE
        BEGIN
            DECLARE @booksCount INT;
            SELECT @booksCount = COUNT(*) FROM listgetbooks WHERE user_id = @userId AND returndate IS NULL;

            IF @booksCount = 0
            BEGIN
				DELETE FROM listgetbooks WHERE user_id = @userId;
                DELETE FROM users WHERE id = @userId;
                COMMIT TRANSACTION; 
                PRINT 'Пользователь успешно удален';
            END
            ELSE
            BEGIN
                THROW 50002, 'Невозможно удалить пользователя. У пользователя есть невозвращенные книги.', 1;
            END
        END;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        PRINT 'При удалении пользователя произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH;
END;
GO
----------------------------------------------------------------------
---------------------------ДОБАВЛЕНИЕ КНИГИ---------------------------
----------------------------------------------------------------------
CREATE PROCEDURE AddBook
    @publishinghouse_id INT,
    @title NVARCHAR(255),
    @year INT,
    @pages INT,
    @genre_id INT,
    @author_id INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM publishinghouse WHERE id = @publishinghouse_id)
    BEGIN
        THROW 50003, 'Издательство с указанным ID не найдено', 1;
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM genre WHERE id = @genre_id)
    BEGIN
        THROW 50004, 'Жанр с указанным ID не найден', 1;
        RETURN;
    END;

    IF NOT EXISTS (SELECT 1 FROM author WHERE id = @author_id)
    BEGIN
        THROW 50005, 'Автор с указанным ID не найден', 1;
        RETURN;
    END;

    DECLARE @max_book_id INT;
    SELECT @max_book_id = ISNULL(MAX(id), 0) FROM book;
    SET @max_book_id = @max_book_id + 1;

    INSERT INTO book (id, publishinghouse_id, title, year, pages)
    VALUES (@max_book_id, @publishinghouse_id, @title, @year, @pages);

    INSERT INTO books_genres (book_id, genre_id)
    VALUES (@max_book_id, @genre_id);

    INSERT INTO books_authors (book_id, author_id)
    VALUES (@max_book_id, @author_id);

    SELECT 'Книга успешно добавлена' AS Result;
END;
GO
----------------------------------------------------------------------
-----------------------------УДАЛЕНИЕ КНИГИ---------------------------
----------------------------------------------------------------------
CREATE PROCEDURE DeleteBook
    @book_id int
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM book WHERE id = @book_id)
        BEGIN
            THROW 51006, 'Книги с таким ID не существует', 1;
        END
        ELSE IF EXISTS (SELECT 1 FROM listgetbooks WHERE sample_id IN (SELECT id FROM sample WHERE book_id = @book_id) AND returndate IS NULL)
        BEGIN
            THROW 51020, 'Невозможно удалить книгу, так как она находится в распоряжении читателя', 1;
        END
        ELSE
        BEGIN
            DELETE FROM listgetbooks WHERE sample_id IN (SELECT id FROM sample WHERE book_id = @book_id);
            DELETE FROM sample WHERE book_id = @book_id;
			DELETE FROM books_genres WHERE book_id = @book_id;
            DELETE FROM books_authors WHERE book_id = @book_id;
            DELETE FROM book WHERE id = @book_id;
            PRINT 'Книга успешно удалена';
        END;
    END TRY
    BEGIN CATCH
        PRINT 'При удалении книги произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END;
----------------------------------------------------------------------
------------ПОИСК ПО СТУДЕНЧЕСКОЙ КАРТЕ ДЛЯ АДМИНА--------------------
----------------------------------------------------------------------
CREATE FUNCTION SearchReaderByStudentIDCard(@studentIDcard VARCHAR(6))
RETURNS TABLE
AS
RETURN (
    SELECT 
        u.id, 
        r.role, 
        u.groupname_id, 
        u.studentIDcard, 
        u.lastname, 
        u.firstname, 
        u.patronymic, 
        u.birthday, 
        u.create_at
    FROM users u 
    INNER JOIN role r ON u.role_id = r.id 
    WHERE u.role_id = 3 AND u.studentIDcard = @studentIDcard
);
GO
----------------------------------------------------------------------
---------------------ИНФОРМАЦИЯ О ЧИТАТЕЛЯХ---------------------------
----------------------------------------------------------------------
CREATE FUNCTION GetAllReaders()
RETURNS TABLE
AS
RETURN (
    SELECT 
        u.id, 
        r.role, 
        u.groupname_id, 
        u.studentIDcard, 
        u.lastname, 
        u.firstname, 
        u.patronymic, 
        u.birthday, 
        u.create_at
    FROM users u 
    INNER JOIN role r ON u.role_id = r.id 
    WHERE u.role_id = 3
);
GO
--------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------
------------------ДОБАВЛЕНИЕ ЭКЗЕМПЛЯРА КНИГИ-------------------------
----------------------------------------------------------------------
CREATE PROCEDURE AddBookSample
    @book_id int,
	@description varchar(255)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM book WHERE id = @book_id)
        BEGIN
            THROW 50007, 'Книга с указанным ID не существует', 1;
            RETURN;
        END

        INSERT INTO sample (book_id, description, presence)
        VALUES (@book_id, @description, 1);

        PRINT 'Экземпляр книги успешно добавлен';
    END TRY
    BEGIN CATCH
        PRINT 'При добавлении экземпляра книги произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END;
GO
----------------------------------------------------------------------
--------------------УДАЛЕНИЕ ЭКЗЕМПЛЯРА КНИГИ-------------------------
----------------------------------------------------------------------
CREATE PROCEDURE DeleteBookSample
    @sample_id int
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM sample WHERE id = @sample_id)
        BEGIN
            THROW 50008, 'Экземпляр книги с указанным ID не существует', 1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM listgetbooks WHERE sample_id = @sample_id AND returndate IS NULL)
        BEGIN
            THROW 50009, 'Невозможно удалить экземпляр книги, так как он все еще находится в использовании', 1;
            RETURN;
        END

        DELETE FROM listgetbooks WHERE sample_id = @sample_id;
        DELETE FROM sample WHERE id = @sample_id;

        PRINT 'Экземпляр книги успешно удален';
    END TRY
    BEGIN CATCH
        PRINT 'При удалении экземпляра книги произошла ошибка: ' + ERROR_MESSAGE();
        PRINT 'Код ошибки: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Уровень ошибки: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
        PRINT 'Строка, на которой произошла ошибка: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        PRINT 'Процедура, в которой произошла ошибка: ' + ERROR_PROCEDURE();
    END CATCH
END;
GO
----------------------------------------------------------------------
---------------------ВЫДАЧИ КНИГИ ДЛЯ ЧИТАТЕЛЯ------------------------
----------------------------------------------------------------------
CREATE PROCEDURE dbo.IssueBook
    @StudentIDCard INT,
    @BookId INT
AS
BEGIN
    DECLARE @UserId INT;
    DECLARE @SampleId INT;
    DECLARE @AlreadyBorrowed BIT;

    SELECT @UserId = id FROM users WHERE studentIDcard = @StudentIDCard;

    SELECT @AlreadyBorrowed = CASE WHEN COUNT(1) > 0 THEN 1 ELSE 0 END
    FROM listgetbooks lg
    INNER JOIN sample s ON lg.sample_id = s.id
    WHERE lg.user_id = @UserId AND s.book_id = @BookId AND lg.returndate IS NULL;

    IF @AlreadyBorrowed = 1
    BEGIN
        THROW 50012, 'Пользователь уже взял экземпляр этой книги.', 1;
    END
    ELSE
    BEGIN
        SELECT TOP 1 @SampleId = s.id
        FROM sample s
        WHERE s.book_id = @BookId AND s.presence = 1;

        IF @SampleId IS NOT NULL
        BEGIN
            INSERT INTO listgetbooks (user_id, sample_id, takedate)
            VALUES (@UserId, @SampleId, GETDATE())
            
            UPDATE sample
            SET presence = 0
            WHERE id = @SampleId;
        END
        ELSE
        BEGIN
            THROW 50009, 'Нет доступных экземпляров для выдачи книги.', 1;
        END
    END
END
GO
----------------------------------------------------------------------
---------------------ПРИЕМ КНИГИ ОТ ЧИТАТЕЛЯ------------------------
----------------------------------------------------------------------
CREATE PROCEDURE dbo.ReturnBookLibrarian
    @StudentIDCard INT,
    @SampleId INT,
    @mark INT
AS
BEGIN
    DECLARE @UserId INT;
    DECLARE @BookId INT;
    DECLARE @AlreadyRated BIT;

    SELECT @UserId = id
    FROM users
    WHERE studentIDcard = @StudentIDCard;

    SELECT @BookId = book_id
    FROM sample
    WHERE id = @SampleId;

    IF @UserId IS NOT NULL AND @BookId IS NOT NULL
    BEGIN
        SELECT @AlreadyRated = CASE WHEN COUNT(mark) > 0 THEN 1 ELSE 0 END
        FROM listgetbooks lg
        JOIN sample s ON lg.sample_id = s.id
        WHERE lg.user_id = @UserId AND s.book_id = @BookId AND lg.mark IS NOT NULL;

        IF EXISTS (SELECT 1 FROM listgetbooks WHERE user_id = @UserId AND sample_id = @SampleId AND returndate IS NULL)
        BEGIN
            IF @AlreadyRated = 1
            BEGIN
                UPDATE listgetbooks
                SET returndate = GETDATE(), mark = NULL
                WHERE user_id = @UserId AND sample_id = @SampleId AND returndate IS NULL;
            END
            ELSE
            BEGIN
                UPDATE listgetbooks
                SET returndate = GETDATE(), mark = @mark
                WHERE user_id = @UserId AND sample_id = @SampleId AND returndate IS NULL;
            END

            UPDATE sample
            SET presence = 1
            WHERE id = @SampleId;

            SELECT 'Книга успешно возвращена' AS Status;
        END
        ELSE
        BEGIN
            THROW 50010, 'Книга не была взята на руки для данного пользователя или уже была возвращена', 1;
        END
    END
    ELSE
    BEGIN
        THROW 50011, 'Пользователь с указанной студенческой картой или книга не найдены', 1;
    END
END
GO
----------------------------------------------------------------------
-------------------ПОИСК ПО СТУДЕНЧЕСКОЙ КАРТЕ------------------------
----------------------------------------------------------------------
CREATE PROCEDURE SearchIssuedBooksByStudentID
    @StudentIDCard VARCHAR(50)
AS
BEGIN
    SELECT *
    FROM dbo.GetIssuedBooks()
    WHERE studentIDCard LIKE '%' + @StudentIDCard + '%';
END;
GO
----------------------------------------------------------------------
--------------ПОИСК ЭКЗЕМПЛЯРОВ ПО НАЗВАНИЮ КНИГИ---------------------
----------------------------------------------------------------------
CREATE FUNCTION SearchBooksByTitle(@Title NVARCHAR(255))
RETURNS TABLE
AS
RETURN
(
    SELECT s.id as id, s.book_id, b.title, s.description, s.presence
    FROM book AS b
    INNER JOIN sample AS s ON b.id = s.book_id
    WHERE b.title LIKE '%' + @Title + '%'
)
GO
----------------------------------------------------------------------
----------ПОДСЧЕТ КОЛ-ВА ЭКЗЕМПЛЯРОВ КНИГИ ПО ЕЕ ID-------------------
----------------------------------------------------------------------
CREATE FUNCTION GetBookSampleCount(@book_id int)
RETURNS INT
AS
BEGIN
    DECLARE @sample_count INT;
    SELECT @sample_count = COUNT(id) FROM sample WHERE book_id = @book_id;
    RETURN @sample_count;
END;
GO
----------------------------------------------------------------------
------------------ПОЛУЧЕНИЕ ЭКЗЕМПЛЯРОВ КНИГ--------------------------
----------------------------------------------------------------------
CREATE FUNCTION GetBookSamples()
RETURNS TABLE
AS
RETURN
(
    SELECT sample.id AS id, sample.book_id, book.title, sample.description, sample.presence 
    FROM sample 
    INNER JOIN book ON sample.book_id = book.id
);
GO
----------------------------------------------------------------------
-------ПОЛУЧЕНИЕ ПОЛЬЗОВАТЕЛЕЙ, У КОТОРЫХ КНИГА НА РУКАХ-------------
----------------------------------------------------------------------
CREATE FUNCTION dbo.GetIssuedBooks()
RETURNS TABLE
AS
RETURN
(
    SELECT u.studentIDCard, s.id as id, lg.takedate
    FROM listgetbooks lg
    INNER JOIN users u ON lg.user_id = u.id
    INNER JOIN sample s ON lg.sample_id = s.id
	WHERE lg.returndate IS NULL
);
GO
----------------------------------------------------------------------
----------------------------АВТОРИЗАЦИЯ-------------------------------
----------------------------------------------------------------------
CREATE PROCEDURE LoginUser
    @login varchar(255),
    @password varchar(255)
AS
BEGIN
    DECLARE @message varchar(100);

    IF NOT EXISTS (SELECT * FROM users WHERE login = @login)
    BEGIN
        SET @message = 'Неправильный логин';
    END
    ELSE IF NOT EXISTS (SELECT * FROM users WHERE login = @login AND password = @password)
    BEGIN
        SET @message = 'Неправильный пароль';
    END
    ELSE
    BEGIN
        SET @message = 'Вход в систему прошел успешно';
    END

    SELECT @message AS Message;
END;
GO

EXEC LoginUser @login = 'ivanov', @password = 'wrong_password';
EXEC LoginUser @login = 'ivanov_p', @password = 'wrong_password';
EXEC LoginUser @login = 'ivanov_p', @password = 'ivanov_pass123';
EXEC LoginUser @login = 'ivanov_p', @password = 41234;
----------------------------------------------------------------------
---------------------ПОЛУЧЕНИЕ СПИСКА КНИГ----------------------------
----------------------------------------------------------------------
CREATE FUNCTION ViewBooks()
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT
        b.id, 
        b.title, 
        b.year, 
        b.pages, 
        p.name AS publishinghouse, 
        STUFF((
            SELECT ', ' + g.genre
            FROM books_genres bg
            JOIN genre g ON bg.genre_id = g.id
            WHERE bg.book_id = b.id
            FOR XML PATH('')), 1, 2, '') AS genres, 
        STUFF((
            SELECT ', ' + CONCAT(a.lastname, ' ', a.firstname)
            FROM books_authors ba
            JOIN author a ON ba.author_id = a.id
            WHERE ba.book_id = b.id
            FOR XML PATH('')), 1, 2, '') AS authors
    FROM book b
    INNER JOIN publishinghouse p ON b.publishinghouse_id = p.id
    LEFT JOIN books_genres bg ON b.id = bg.book_id
    LEFT JOIN genre g ON bg.genre_id = g.id
    LEFT JOIN books_authors ba ON b.id = ba.book_id
    LEFT JOIN author a ON ba.author_id = a.id
    GROUP BY b.id, b.title, b.year, b.pages, p.name
);
GO
----------------------------------------------------------------------
---------------------ПОИСК КНИГ ПО КРИТЕРИЯМ--------------------------
----------------------------------------------------------------------
CREATE FUNCTION SearchBooks (@searchString NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT
        b.id, 
        b.title, 
        b.year, 
        b.pages, 
        p.name AS publishinghouse, 
        STUFF((
            SELECT ', ' + g.genre
            FROM books_genres bg
            JOIN genre g ON bg.genre_id = g.id
            WHERE bg.book_id = b.id
            FOR XML PATH('')), 1, 2, '') AS genres, 
        STUFF((
            SELECT ', ' + CONCAT(a.lastname, ' ', a.firstname)
            FROM books_authors ba
            JOIN author a ON ba.author_id = a.id
            WHERE ba.book_id = b.id
            FOR XML PATH('')), 1, 2, '') AS authors
    FROM book b
    INNER JOIN publishinghouse p ON b.publishinghouse_id = p.id
    LEFT JOIN books_genres bg ON b.id = bg.book_id
    LEFT JOIN genre g ON bg.genre_id = g.id
    LEFT JOIN books_authors ba ON b.id = ba.book_id
    LEFT JOIN author a ON ba.author_id = a.id
    WHERE b.title LIKE '%' + @searchString + '%' OR a.firstname LIKE '%' + @searchString + '%' OR a.lastname LIKE '%' + @searchString + '%' OR g.genre LIKE '%' + @searchString + '%'
    GROUP BY b.id, b.title, b.year, b.pages, p.name
);
GO
--------------------------------------------------------------------------------------------------------
DROP PROCEDURE RegisterReader;
DROP PROCEDURE BorrowBook;
DROP PROCEDURE ReturnBookReader;
DROP FUNCTION GetBorrowedBooks;
DROP FUNCTION SearchBooksByTitleReader;
DROP FUNCTION GetBookRatings;
--------------------------------------------------------------------------------------------------------
DROP PROCEDURE AddLibrarian;
DROP PROCEDURE AddReader
DROP PROCEDURE UpdateLibrarian;
DROP PROCEDURE UpdateReader;
DROP PROCEDURE DeleteUser;
DROP PROCEDURE AddBook;
DROP PROCEDURE DeleteBook;
DROP FUNCTION SearchReaderByStudentIDCard;
DROP FUNCTION GetAllReaders;
--------------------------------------------------------------------------------------------------------
DROP PROCEDURE AddBookSample;
DROP PROCEDURE DeleteBookSample;
DROP PROCEDURE IssueBook;
DROP PROCEDURE ReturnBookLibrarian;
DROP PROCEDURE SearchIssuedBooksByStudentID;
DROP FUNCTION SearchBooksByTitle;
DROP FUNCTION GetBookSampleCount;
DROP FUNCTION GetBookSamples;
DROP FUNCTION GetIssuedBooks;
--------------------------------------------------------------------------------------------------------
DROP FUNCTION ViewBooks;
DROP FUNCTION SearchBooks;
DROP PROCEDURE LoginUser;