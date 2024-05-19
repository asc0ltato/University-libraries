<?php
session_start();

$serverName = "ASCOLTAT0";
$database = "Library";

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $username = $_POST['login'];
    $password = $_POST['password'];

    $masterConn = sqlsrv_connect($serverName, array(
        "Database" => $database,
        "UID" => "sa",
        "PWD" => "sa"
    ));

    if ($masterConn === false) {
        die("Ошибка подключения к базе данных: " . print_r(sqlsrv_errors(), true));
    }

    $sql = "SELECT id, password, role_id FROM users WHERE login = ? AND password = ?";
    $params = array($username, $password);
    $stmt = sqlsrv_query($masterConn, $sql, $params);

    if ($stmt === false) {
        die("Ошибка выполнения запроса: " . print_r(sqlsrv_errors(), true));
    }

    
    $user = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);

    if ($user) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['role_id'] = $user['role_id'];

        if ($user['role_id'] == 1) {
            header("Location: admin_page.php");
            exit(); 
        } elseif ($user['role_id'] == 2) {
            header("Location: librarian_page.php");
            exit(); 
        } elseif ($user['role_id'] == 3) {
            header("Location: reader_page.php");
            exit(); 
        } else {
            die('Неправильная роль');
        }
    } else {
        echo "Неверный логин или пароль";
    }

    sqlsrv_close($masterConn);
}
?>