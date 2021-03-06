<?php

// Prevent to be loaded directly
if (!isset($allowed_ops)) {
    die("ERROR");
}

require_once "./setup/config.php";
require_once "./libraries/Locale.inc.php";

$mysqlc = mysql_connect($mysql_host, $mysql_user, $mysql_pass);

if(!$mysqlc){
    echo    '<div class="error">'
            . _("An error has ocurred trying to connect to the MYSQL database.")
            . '.<br /><br /><a href="javascript:history.back(1);">'
            . _("Back")
            . '</a></div>';
    include "../themes/$app_theme/footer.php";
    die();
}

$mysqls = mysql_select_db($mysql_dbname);

if (!$mysqls) {

    require_once "./libraries/Functions.inc.php";
    require_once "./libraries/CreateDatabase.inc.php";
    
    $mysqls = mysql_select_db($mysql_dbname);
    
    if(!$mysqls){
        echo    '<div class="error">'
                . _("An error has ocurred trying to select database ")
                . '"' . $mysql_dbname . '": '
                . mysql_error($mysqlc)
                . '.<br /><br /><a href="javascript:history.back(1);">'
                . _("Back")
                . '</a></div>';
        include "../themes/$app_theme/footer.php";
        die();
    }

}

?>
