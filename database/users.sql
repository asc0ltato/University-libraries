----------------------------------------------------------------------
----------------------------ЧИТАТЕЛЬ----------------------------------
----------------------------------------------------------------------
CREATE LOGIN ReaderUser WITH PASSWORD = '321';
CREATE USER ReaderUser FOR LOGIN ReaderUser;
CREATE ROLE ReaderRole;
ALTER ROLE ReaderRole ADD MEMBER ReaderUser;

GRANT SELECT ON dbo.author TO ReaderUser;
GRANT SELECT ON dbo.books_authors TO ReaderUser;
GRANT SELECT ON dbo.books_genres TO ReaderUser;
GRANT SELECT ON dbo.genre TO ReaderUser;
GRANT SELECT ON dbo.publishinghouse TO ReaderUser;
GRANT SELECT ON dbo.book TO ReaderUser;
GRANT SELECT ON dbo.users TO ReaderUser;
GRANT SELECT, UPDATE, INSERT ON dbo.listgetbooks TO ReaderUser;
GRANT SELECT, UPDATE ON dbo.sample TO ReaderUser;
GRANT EXECUTE ON dbo.RegisterReader TO ReaderRole;
GRANT EXECUTE ON dbo.BorrowBook TO ReaderRole;
GRANT EXECUTE ON dbo.ReturnBookReader TO ReaderRole;
GRANT SELECT ON dbo.GetBorrowedBooks TO ReaderRole;
GRANT SELECT ON dbo.SearchBooksByTitleInRating TO ReaderRole;
GRANT SELECT ON dbo.GetBookRatings TO ReaderRole;
----------------------------------------------------------------------
----------------------------АДМИНИСТРАТОР-----------------------------
----------------------------------------------------------------------
CREATE LOGIN AdminUser WITH PASSWORD = '111';
CREATE USER AdminUser FOR LOGIN AdminUser;
CREATE ROLE AdminRole;
ALTER ROLE AdminRole ADD MEMBER AdminUser;

GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.author TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.book TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.books_authors TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.books_genres TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.faculty TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.genre TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.groupname TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.listgetbooks TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.publishinghouse TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.role TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.sample TO AdminRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.users TO AdminRole;
GRANT EXECUTE ON dbo.AddLibrarian TO AdminRole;
GRANT EXECUTE ON dbo.AddReader TO AdminRole;
GRANT EXECUTE ON dbo.UpdateLibrarian TO AdminRole;
GRANT EXECUTE ON dbo.UpdateReader TO AdminRole;
GRANT EXECUTE ON dbo.DeleteUser TO AdminRole;
GRANT EXECUTE ON dbo.AddBook TO AdminRole;
GRANT EXECUTE ON dbo.DeleteBook TO AdminRole;
GRANT SELECT ON dbo.SearchReaderByStudentIDCard TO AdminRole;
GRANT SELECT ON dbo.GetAllReaders TO AdminRole;
----------------------------------------------------------------------
----------------------------БИБЛИОТЕКАРЬ------------------------------
----------------------------------------------------------------------
CREATE LOGIN LibrarianUser WITH PASSWORD = '123';
CREATE USER LibrarianUser FOR LOGIN LibrarianUser;
CREATE ROLE LibrarianRole;
ALTER ROLE LibrarianRole ADD MEMBER LibrarianUser;

GRANT SELECT ON dbo.author TO LibrarianRole;
GRANT SELECT ON dbo.book TO LibrarianRole;
GRANT SELECT ON dbo.books_authors TO LibrarianRole;
GRANT SELECT ON dbo.books_genres TO LibrarianRole;
GRANT SELECT ON dbo.genre TO LibrarianRole;
GRANT SELECT ON dbo.users TO LibrarianRole;
GRANT SELECT ON dbo.book TO LibrarianRole;
GRANT SELECT ON dbo.publishinghouse TO LibrarianRole;
GRANT SELECT, UPDATE, INSERT ON dbo.listgetbooks TO LibrarianRole;
GRANT SELECT, UPDATE, INSERT, DELETE ON dbo.sample TO LibrarianRole;
GRANT EXECUTE ON dbo.AddBookSample TO LibrarianRole;
GRANT EXECUTE ON dbo.DeleteBookSample TO LibrarianRole;
GRANT EXECUTE ON dbo.IssueBook TO LibrarianRole;
GRANT EXECUTE ON dbo.ReturnBookLibrarian TO LibrarianRole;
GRANT EXECUTE ON dbo.SearchIssuedBooksByStudentID TO LibrarianRole;
GRANT SELECT ON dbo.SearchBooksByTitle TO LibrarianRole;
GRANT EXECUTE ON dbo.GetBookSampleCount TO LibrarianRole;
GRANT SELECT ON dbo.GetBookSamples TO LibrarianRole;
GRANT SELECT ON dbo.GetIssuedBooks TO LibrarianRole;
----------------------------------------------------------------------	
GRANT EXECUTE ON dbo.LoginUser TO AdminRole, LibrarianRole, ReaderRole;
GRANT SELECT ON dbo.ViewBooks TO ReaderRole, LibrarianRole, AdminRole;
GRANT SELECT ON dbo.SearchBooks TO ReaderRole, LibrarianRole, AdminRole;
GRANT SELECT, UPDATE ON dbo.ReaderDetails TO AdminRole;
GRANT SELECT, UPDATE ON dbo.LibrarianDetails TO AdminRole;
GRANT SELECT ON dbo.BookDetails TO AdminRole, LibrarianRole, ReaderRole;
GRANT SELECT ON dbo.AvailableBooks TO ReaderRole, LibrarianRole;
----------------------------------------------------------------------	
DROP LOGIN AdminUser;
DROP USER AdminUser;
DROP ROLE AdminRole;
DROP LOGIN ReaderUser;
DROP USER ReaderUser;
DROP ROLE ReaderRole;
DROP LOGIN LibrarianUser;
DROP USER LibrarianUser;
DROP ROLE LibrarianRole;