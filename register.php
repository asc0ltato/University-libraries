<?php
$serverName = "ASCOLTAT0"; 
$connectionOptions = array(
    "Database" => "Library",
    "Uid" => "AdminUser",
    "PWD" => "111",
    "CharacterSet" => "UTF-8"
);

$conn = sqlsrv_connect($serverName, $connectionOptions);

if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
}

$lastname = $_POST['lastname'];
$firstname = $_POST['firstname'];
$patronymic = $_POST['patronymic'];
$birthday = $_POST['birthday'];
$group = $_POST['group'];
$studentIDcard = $_POST['studentIDcard'];
$login = $_POST['login'];
$password = $_POST['password'];

$sql = "INSERT INTO users (role_id, groupname_id, studentIDcard, lastname, firstname, patronymic, birthday, login, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
$role_id = 3;

$check_login_query = "SELECT * FROM users WHERE login=?";
$stmt_check_login = sqlsrv_prepare($conn, $check_login_query, array(&$login));
sqlsrv_execute($stmt_check_login);
$result_check_login = sqlsrv_fetch_array($stmt_check_login, SQLSRV_FETCH_ASSOC);

$check_studentID_query = "SELECT * FROM users WHERE studentIDcard=?";
$stmt_check_studentID = sqlsrv_prepare($conn, $check_studentID_query, array(&$studentIDcard));
sqlsrv_execute($stmt_check_studentID);
$result_check_studentID = sqlsrv_fetch_array($stmt_check_studentID, SQLSRV_FETCH_ASSOC);

if ($result_check_login === true) {
    echo "Логин уже существует в базе данных!";
} elseif ($result_check_studentID === true) {
    echo "Номер студенческой карты уже существует в базе данных!";
} else {
    $stmt = sqlsrv_prepare($conn, $sql, array(&$role_id, &$group, &$studentIDcard, &$lastname, &$firstname, &$patronymic, &$birthday, &$login, &$password));
    
    if (sqlsrv_execute($stmt)) {
        header("Location: index.html");
        exit(); 
    } else {
        echo "Ошибка при регистрации: " . print_r(sqlsrv_errors(), true);
    }
}

sqlsrv_free_stmt($stmt_check_login);
sqlsrv_free_stmt($stmt_check_studentID);
sqlsrv_free_stmt($stmt);
sqlsrv_close($conn);
?>