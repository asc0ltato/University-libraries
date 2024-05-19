<?php
session_start();

if (!isset($_SESSION['user_id']) || $_SESSION['role_id'] != 3) {
    header("Location: index.php");
    exit();
}

$userId = $_SESSION['user_id'];

$serverName = "ASCOLTAT0";
$database = "Library";
$dbUsername = 'ReaderUser';
$dbPassword = '321';

$conn = sqlsrv_connect($serverName, array(
    "Database" => $database,
    "UID" => $dbUsername,
    "PWD" => $dbPassword,
    "CharacterSet" => "UTF-8"
));

if ($conn === false) {
    die("Ошибка подключения к базе данных: " . print_r(sqlsrv_errors(), true));
}

$sqlUserInfo = "SELECT firstname, lastname FROM users WHERE id = ?";
$paramsUserInfo = array($userId);
$stmtUserInfo = sqlsrv_query($conn, $sqlUserInfo, $paramsUserInfo);
if ($stmtUserInfo === false) {
    die("Ошибка выполнения запроса: " . print_r(sqlsrv_errors(), true));
}
$userInfo = sqlsrv_fetch_array($stmtUserInfo, SQLSRV_FETCH_ASSOC);
$userFullName = $userInfo['firstname'] . ' ' . $userInfo['lastname'];

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    if (isset($_POST['borrowBook'])) {
        $bookId = $_POST['book_id'];

        $sqlBorrowBook = "EXEC BorrowBook ?, ?";
        $paramsBorrow = array($userId, $bookId);
        $stmtBorrow = sqlsrv_query($conn, $sqlBorrowBook, $paramsBorrow);

        if ($stmtBorrow === false) {
            die("Ошибка выполнения запроса: " . print_r(sqlsrv_errors(), true));
        }

        echo "Книга успешно взята в аренду";
    } elseif (isset($_POST['returnBook']) && isset($_POST['mark'])) {
        $listGetBookId = $_POST['listgetbook_id'];
        $mark = $_POST['mark'];

        $sqlReturnBook = "EXEC ReturnBookReader ?, ?";
        $paramsReturn = array($listGetBookId, $mark);
        $stmtReturn = sqlsrv_query($conn, $sqlReturnBook, $paramsReturn);

        if ($stmtReturn === false) {
            die("Ошибка выполнения запроса: " . print_r(sqlsrv_errors(), true));
        }

        echo "Книга успешно возвращена";
    }
}

$sqlBooks = "SELECT * FROM ViewBooks()";
$stmtBooks = sqlsrv_query($conn, $sqlBooks);

if ($stmtBooks === false) {
    die("Ошибка при получении информации о книгах: " . print_r(sqlsrv_errors(), true));
}
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Главная</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            color: #333;
        }

        nav {
            background-color: #333;
            padding: 10px 0;
        }

        nav ul {
            list-style-type: none;
            padding: 0;
            margin: 0;
            text-align: center;
        }

        nav ul li {
            display: inline;
        }

        nav ul li a {
            text-decoration: none;
            color: white;
            padding: 10px 20px;
            border: 1px solid #444;
            border-radius: 5px;
            transition: background-color 0.3s, color 0.3s;
        }

        nav ul li a:hover {
            background-color: #555;
            color: #fff;
        }

        h2 {
            text-align: center;
        }

        table {
            width: 90%;
            margin: 20px auto;
            border-collapse: collapse;
        }

        th, td {
            padding: 10px;
            text-align: center;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #f2f2f2;
        }

        form {
            text-align: center;
            margin-bottom: 20px;
            width: 16%;
            margin: 0 auto;
        }

        input[type="submit"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }

        input[type="submit"]:hover {
            background-color: #444;
        }

        input[type="submit"]:focus {
            outline: none;
        }

        form.search-form {
        text-align: center;
        margin-bottom: 20px;
        }

        form.search-form input[type="text"] {
            padding: 10px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ccc;
            font-size: 16px;
            box-sizing: border-box;
            margin-bottom: 10px;
        }

        form.search-form input[type="submit"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-left: 10px;
        }

        form.search-form input[type="submit"]:hover {
            background-color: #444;
        }

        form.search-form input[type="submit"]:focus {
            outline: none;
        }
    </style>
</head>
<body>
    <nav>
        <ul>
            <li><a href="reader_page.php">Главная</a></li>
            <li><a href="book_ratings.php">Рейтинг книг</a></li>
            <li><a href="logout.php">Выход</a></li>
        </ul>
    </nav>
    <h2>Добро пожаловать, <?php echo $userFullName; ?>!</h2>

    <h2>Ваши взятые книги</h2>
    <table>
        <tr>
            <th>ID записи</th>
            <th>Название книги</th>
            <th>Дата взятия</th>
            <th>Оценка</th>
            <th>Действие</
            ></tr>
        <?php
        $sqlBorrowedBooks = "SELECT id, title, takedate FROM GetBorrowedBooks(?);";
        $paramsBorrowed = array($userId);
        $stmtBorrowedBooks = sqlsrv_query($conn, $sqlBorrowedBooks, $paramsBorrowed);

        if ($stmtBorrowedBooks === false) {
            die("Ошибка при получении информации о взятых книгах: " . print_r(sqlsrv_errors(), true));
        }

        while ($rowBorrowedBook = sqlsrv_fetch_array($stmtBorrowedBooks, SQLSRV_FETCH_ASSOC)):
        ?>
        <tr>
            <td><?php echo $rowBorrowedBook['id']; ?></td>
            <td><?php echo $rowBorrowedBook['title']; ?></td>
            <td><?php echo $rowBorrowedBook['takedate']->format('Y-m-d'); ?></td>
            <td>
                <form method="post" style="display:inline;">
                    <input type="hidden" name="listgetbook_id" value="<?php echo $rowBorrowedBook['id']; ?>">
                    <input type="number" name="mark" min="1" max="5" required>
            </td>
            <td>
                    <input type="submit" name="returnBook" value="Вернуть книгу">
                </form>
            </td>
        </tr>
        <?php endwhile; ?>
    </table>

    <h2>Информация о книгах</h2>

    <form class="search-form" method="GET" action="">
        <input type="text" name="search" placeholder="Поиск по названию, автору или жанру">
        <input type="submit" name="submit" value="Поиск">
    </form>
    
    <table>
        <tr>
            <th>ID книги</th>
            <th>Название</th>
            <th>Жанры</th>
            <th>Авторы</th>
            <th>Издательство</th>
            <th>Год издания</th>
            <th>Страницы</th>
            <th>Действие</th>
        </tr>
        <?php
        if (isset($_GET['submit']) && isset($_GET['search'])) {
            $sqlSearch = "SELECT * FROM SearchBooks(?)";
            $paramsSearch = array($_GET['search']);
            $stmtSearch = sqlsrv_query($conn, $sqlSearch, $paramsSearch);

            if ($stmtSearch === false) {
                die("Ошибка при выполнении запроса поиска: " . print_r(sqlsrv_errors(), true));
            }

            while ($rowBook = sqlsrv_fetch_array($stmtSearch, SQLSRV_FETCH_ASSOC)) {
                echo "<tr>
                        <td>{$rowBook['id']}</td>
                        <td>{$rowBook['title']}</td>
                        <td>{$rowBook['genres']}</td>
                        <td>{$rowBook['authors']}</td>
                        <td>{$rowBook['publishinghouse']}</td>
                        <td>{$rowBook['year']}</td>
                        <td>{$rowBook['pages']}</td>
                        <td>
                            <form method='post' style='display:inline;'>
                                <input type='hidden' name='book_id' value='{$rowBook['id']}'>
                                <input type='submit' name='borrowBook' value='Взять книгу'>
                            </form>
                        </td>
                    </tr>";
            }
        } else {
            while ($rowBook = sqlsrv_fetch_array($stmtBooks, SQLSRV_FETCH_ASSOC)): 
        ?>
            <tr>
                <td><?php echo $rowBook['id']; ?></td>
                <td><?php echo $rowBook['title']; ?></td>
                <td><?php echo $rowBook['genres']; ?></td>
                <td><?php echo $rowBook['authors']; ?></td>
                <td><?php echo $rowBook['publishinghouse']; ?></td>
                <td><?php echo $rowBook['year']; ?></td>
                <td><?php echo $rowBook['pages']; ?></td>
                <td>
                    <form method="post" style="display:inline;">
                        <input type="hidden" name="book_id" value="<?php echo $rowBook['id']; ?>">
                        <input type="submit" name="borrowBook" value="Взять книгу">
                    </form>
                </td>
            </tr>
        <?php endwhile; 
        }?>
    </table>
</body>
</html>
<?php
sqlsrv_close($conn);
?>