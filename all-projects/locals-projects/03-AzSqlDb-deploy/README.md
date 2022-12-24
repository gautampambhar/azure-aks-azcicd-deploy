# Task
1. Create Azure MySql server and database
2. Connect AKS to Azure MySql server and database
    - in sql server, settings --> connection security
        - allow access to azure services // so that AKS can connect
        - add a firewall rule if you want to connect your local desktop to this database server
        - disable SSL
    - Connection methods
        - AKS to DB: 
            - firewall rules not required
            - how: 
            ```
            # Template
            kubectl run -it --rm --image=mysql:5.7.22 --restart=Never mysql-client -- mysql -h <AZURE-MYSQ-DB-HOSTNAME> -u <USER_NAME> -p<PASSWORD>

            # Replace Host Name of Azure MySQL Database and Username and Password
            kubectl run -it --rm --image=mysql:5.7.22 --restart=Never mysql-client -- mysql -h akswebappdb.mysql.database.azure.com -u dbadmin@akswebappdb -pRedhat1449

            mysql> show schemas;
            mysql> create database webappdb;
            mysql> show schemas;
            mysql> exit
            ```
        - Local device to DB
            ```
            # Template
            mysql --host=mydemoserver.mysql.database.azure.com --user=myadmin@mydemoserver -p

            # 
            mysql --host=akswebappdb.mysql.database.azure.com --user=dbadmin@akswebappdb -p
            ```
