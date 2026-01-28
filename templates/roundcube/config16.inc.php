<?php
$config = array();
$config['db_dsnw'] = 'mysql://roundcube16:%password%@localhost/roundcube16';
$config['db_dsnr'] = '';
$config['imap_host'] = 'localhost:143';
// $config['smtp_host'] = 'localhost:587';
$config['smtp_host'] = 'localhost:25';
$config['smtp_user'] = '%u'; // maybe needs empty
$config['smtp_pass'] = '%p'; // maybe needs empty
$config['smtp_helo_host'] = '%helo_host%';
$config['log_dir'] = '/var/log/roundcube16/';
$config['log_driver'] = 'file';
$config['log_file_ext'] = '.log';
$config['debug_level'] = 1;
$config['log_driver'] = 'file';
$config['log_date_format'] = 'd-M-Y H:i:s O';
$config['smtp_log'] = true;
$config['temp_dir'] = '/tmp';
$config['force_https'] = false;
$config['use_https'] = false;
$config['login_autocomplete'] = 0;
$config['drafts_mbox'] = 'Drafts';
$config['junk_mbox'] = 'Spam';
$config['sent_mbox'] = 'Sent';
$config['trash_mbox'] = 'Trash';
$config['default_folders'] = array('INBOX', 'Drafts', 'Sent', 'Spam', 'Trash');
$config['create_default_folders'] = true;
$config['protect_default_folders'] = true;
$config['enable_spellcheck'] = true;
$config['spellcheck_dictionary'] = false;
$config['spellcheck_engine'] = 'googie';
$config['default_charset'] = 'UTF-8';
$config['delete_junk'] = true;
$config['timezone'] = 'auto';
$config['support_url'] = '';
$config['product_name'] = 'Roundcube Webmail';
$config['des_key'] = '%des_key%';
$config['plugins'] = array(
    'archive',
    'zipdownload',
    'password',
);
$config['skin'] = 'elastic';
