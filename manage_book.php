<?php
    $serverName = "ASCOLTAT0";
    $database = "Library";
    $dbUsername = 'AdminUser';
    $dbPassword = '111';

    $adminConn = sqlsrv_connect($serverName, array(
        "Database" => $database,
        "UID" => $dbUsername,
        "PWD" => $dbPassword,
        "CharacterSet" => "UTF-8"
    ));

    if ($adminConn === false) {
        die("Не удалось установить соединение: " . print_r(sqlsrv_errors(), true));
    }

    $sqlBooks = "SELECT * FROM ViewBooks()";
    $stmtBooks = sqlsrv_query($adminConn, $sqlBooks);

    if ($stmtBooks === false) {
        die("Ошибка при получении информации о книгах: " . print_r(sqlsrv_errors(), true));
    }

    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        if (isset($_POST['AddBook'])) {
            $publishinghouse_id = $_POST['publishinghouse_id'];
            $title = $_POST['title'];
            $year = $_POST['year'];
            $pages = $_POST['pages'];
            $genre_id = $_POST['genre_id'];
            $author_id = $_POST['author_id'];
        
            $sqlAddBook = "{CALL AddBook(?, ?, ?, ?, ?, ?)}"; 
            $params = array($publishinghouse_id, $title, $year, $pages, $genre_id, $author_id); 
            $stmtAddBook = sqlsrv_query($adminConn, $sqlAddBook, $params);
        
            if ($stmtAddBook === false) {
                die("Ошибка при добавлении книги: " . print_r(sqlsrv_errors(), true));
            } else {
                echo "Книга успешно добавлена!";
            }    
        } elseif (isset($_POST['DeleteBook'])) {
            $deleteBookId = $_POST['DeleteBook'];
    
            $sqlDeleteBook = "{CALL DeleteBook(?)}";
            $params = array($deleteBookId);
            $stmtDeleteBook = sqlsrv_query($adminConn, $sqlDeleteBook, $params);
    
            if ($stmtDeleteBook === false) {
                die("Ошибка при удалении книги: " . print_r(sqlsrv_errors(), true));
            }
        }
    }    
?>

<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Управление книгой</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
            color: #333;
        }

        h1, h2 {
            text-align: center;
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

        input[type="submit"], input[type="button"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }

        input[type="submit"]:hover, input[type="button"]:hover {
            background-color: #444;
        }

        input[type="submit"]:focus, input[type="button"]:focus {
            outline: none;
        }

        input[type="text"], input[type="date"], input[type="password"] {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            box-sizing: border-box;
        }

        .button-container {
            text-align: center;
            margin-bottom: 20px;
        }

        .button-container input[type="submit"] {
            margin: 0 5px;
        }

        .form-container {
            text-align: center;
            margin-top: 20px; 
            margin-bottom: 20px;
        }

        .form-container input[type="submit"] {
            padding: 10px 20px;
            background-color: #333;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
            display: block;
            margin-bottom: 10px;
        }

        select {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            box-sizing: border-box;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
            background-color: white;
            background-image: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
        }

        select:focus {
            border-color: #333;
            outline: none;
        }

        select:hover {
            border-color: #555;
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
            <li><a href="admin_page.php">Управление библиотекарем</a></li>
            <li><a href="manage_reader.php">Управление читателем</a></li>
            <li><a href="manage_book.php">Управление книгой</a></li>
            <li><a href="logout.php">Выход</a></li>
        </ul>
    </nav>

    <div class="form-container"> 
        <h2>Добавить книгу</h2>
        <form action="" method="post">
            <label for="title">Название книги:</label><br>
            <input type="text" name="title" id="title" required><br>
            
            <label for="genre_id">ID жанра:</label><br>
            <input type="text" name="genre_id" id="genre_id" required><br>
            
            <label for="author_id">ID автора:</label><br>
            <input type="text" name="author_id" id="author_id" required><br>
            
            <label for="publishinghouse_id">ID издательства:</label><br>
            <input type="text" name="publishinghouse_id" id="publishinghouse_id" required><br>
            
            <label for="year">Год издания:</label><br>
            <input type="text" name="year" id="year" required><br>
            
            <label for="pages">Количество страниц:</label><br>
            <input type="text" name="pages" id="pages" required><br>
            
            <input type="submit" name="AddBook" value="Добавить" style="margin: auto; display: block;">
        </form>
    </div>
    
    <h2>Информация о книгах</h2>

    <form class="search-form" method="GET" action="">
        <input type="text" name="search" placeholder="Поиск по названию, автору или жанру">
        <input type="submit" name="submit" value="Поиск">
    </form>

    <table id="bookTable">
    <tr>
        <th>ID книги</th>
        <th>Название</th>
        <th>Жанры</th>
        <th>Авторы</th>
        <th>Издательство</th>
        <th>Год издания</th>
        <th>Страницы</th>
        <th>Удалить</th> 
    </tr>
    <?php
        if (isset($_GET['submit']) && isset($_GET['search'])) {
            $sqlSearch = "SELECT * FROM SearchBooks(?)";
            $paramsSearch = array($_GET['search']);
            $stmtSearch = sqlsrv_query($adminConn, $sqlSearch, $paramsSearch);

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
                        <form method='POST' style='margin: 0;'>
                            <input type='hidden' name='DeleteBook' value='" . ($rowBook['id'] ?? '') . "'>
                            <input type='submit' value='Удалить' style='margin: auto; ''>
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
                        <input type="hidden" name="DeleteBook" value="<?php echo $rowBook['id']; ?>">
                        <input type="submit" value="Удалить" style= 'margin: auto'>
                    </form>
                </td>
            </tr>
        <?php endwhile; 
        }?>
    </table>
</body>
</html>