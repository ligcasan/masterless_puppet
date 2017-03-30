package { "nginx":
    ensure => installed
}

service { "nginx":
    require => Package["nginx"],
    ensure => running,
    enable => true
}

# demo.pp - part 2 
file { "/etc/nginx/sites-enabled/default":
    require => Package["nginx"],
    ensure  => "file",
    content =>
        'server {
        	listen 80 default_server;
        	listen [::]:80 default_server ipv6only=on;
        
        	root /usr/share/nginx/html;
        	index index.php index.html index.htm;
        
        	server_name localhost;
        
        	location / {
        		try_files $uri $uri/ =404;
        	}
        
        	error_page 404 /404.html;
        
        	error_page 500 502 503 504 /50x.html;
        	location = /50x.html {
        		root /usr/share/nginx/html;
        	}
        
        	location ~ \.php$ {
        	        try_files $uri =404;
        		fastcgi_split_path_info ^(.+\.php)(/.+)$;
        		fastcgi_pass unix:/var/run/php5-fpm.sock;
        		fastcgi_index index.php;
                        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        		include fastcgi_params;
        	}
        }',
    notify  => Service["nginx"]
}

package { "mysql-server":
    ensure => installed
}

service { "mysql":
    ensure => "running",
    enable => "true",
    require => Package["mysql-server"],
}

package { "php5-fpm":
    ensure => installed
}

package { "php5-mysql":
    ensure => installed
}

file { "/etc/php5/fpm/php.ini":
    ensure => present;
}

file_line { "Replace line":
    path => '/etc/php5/fpm/php.ini',
    line => 'cgi.fix_pathinfo=0',
    match => ';cgi.fix_pathinfo=1',
}

file { "/var/www/html/info.php":
    ensure => "file",
    content => "<?php phpinfo();",
    notify => Service["nginx"],
}
