<?php
    $host="localhost";
    $dbname="strading_stradingmada";
    $user="strading_Nivonantenaina"
    $pass="Scarfacetm@1725"

    try{
        $db= new PDO("mysql:host=$host;dbname=$dbname",$user,$pass);
        echo "connecté";
    }catch(\Throwable $th){
        echo "Error:"->getMessage();
    }
?>