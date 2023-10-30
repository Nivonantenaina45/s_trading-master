<?php
    include "connection.php";
    $nom=$_POST['nom'];
    $prenom=$_POST['prénom'];
    $email=$_POST['email'];
    $pass=$_POST['password'];

    echo json_encode([
        "result"=>[
           $email,
           $nom,
           $prenom,
           $email,
           $pass 
        ]
    ])

?>