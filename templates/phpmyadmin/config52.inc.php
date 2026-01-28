<?php
// all directives are explained in documentation in the doc/ folder or at <https://docs.phpmyadmin.net/>.

declare(strict_types=1);

// needed for cookie based authentication to encrypt password in cookie. should be to be 32 chars long.
$cfg['blowfish_secret'] = '%phpmyadmin_blowfish%';
// $cfg['DefaultConnectionCollation'] = 'utf8mb4_unicode_ci';

// directories for saving/loading files from server and better performance
// leave parameters empty to disallow upload ans storing files
// requires to configure open_basedir
$qweec_pma_dir = '/var/lib/phpmyadmin52';
$cfg['SaveDir'] = $qweec_pma_dir.'/save';
$cfg['UploadDir'] = $qweec_pma_dir.'/upload';
$cfg['TempDir']  = $qweec_pma_dir.'/tmp/';
$cfg['cacheDir']  = $qweec_pma_dir.'/libraries/cache';

// servers configuration
$i = 0;
$confdfiles = array_values(array_diff(scandir('./conf.d'), array('.', '..')));
foreach ($confdfiles as $file) {
    if (substr($file, 0, strlen("dbserver")) === "dbserver" && substr($file, -(strlen(".php"))) === ".php") {
include_once './conf.d/' . $file;
        $cfg['Servers'][$i]['auth_type'] = 'cookie';
        $cfg['Servers'][$i]['compress'] = false;
        // $cfg['Servers'][$i]['extension'] = 'mysqli';
        $cfg['Servers'][$i]['AllowNoPassword'] = false;
        $cfg['Servers'][$i]['AllowRoot'] = false;
        $cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
        $cfg['Servers'][$i]['relation'] = 'pma__relation';
        $cfg['Servers'][$i]['table_info'] = 'pma__table_info';
        $cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
        $cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
        $cfg['Servers'][$i]['column_info'] = 'pma__column_info';
        $cfg['Servers'][$i]['history'] = 'pma__history';
        $cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
        $cfg['Servers'][$i]['tracking'] = 'pma__tracking';
        $cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
        $cfg['Servers'][$i]['recent'] = 'pma__recent';
        $cfg['Servers'][$i]['favorite'] = 'pma__favorite';
        $cfg['Servers'][$i]['users'] = 'pma__users';
        $cfg['Servers'][$i]['usergroups'] = 'pma__usergroups';
        $cfg['Servers'][$i]['navigationhiding'] = 'pma__navigationhiding';
        $cfg['Servers'][$i]['savedsearches'] = 'pma__savedsearches';
        $cfg['Servers'][$i]['central_columns'] = 'pma__central_columns';
        $cfg['Servers'][$i]['designer_settings'] = 'pma__designer_settings';
        $cfg['Servers'][$i]['export_templates'] = 'pma__export_templates';
    }
}
