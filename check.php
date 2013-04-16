<?php

$userdata = json_decode($_POST['userdata']);

$myFile = "promolog";
$fh = fopen($myFile, 'a') or die("can't open file");
$stringData = "-".$userdata->appname."\n";
$stringData = $_POST['userdata']."\n";
fwrite($fh, $stringData);
fclose($fh);

$arr = array('clickurl' => 'https://itunes.apple.com/app/rosalyns-animal-coloring/id602071830?mt=8', 'imageurl' => 'http://www.wungi.com/moregames/freeuser.png', 'active' => true);

echo json_encode($arr);

?>