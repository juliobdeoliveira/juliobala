#!/bin/bash


source /usr/local/osmosix/etc/userenv


function empty
{
    local var="$1"

    # Return true if:
    # 1.    var is a null string ("" as empty string)
    # 2.    a non set variable is passed
    # 3.    a declared variable or array but without a value is passed
    # 4.    an empty array is passed
    if test -z "$var"
    then
        [[ $( echo "1" ) ]]
        return

    # Return true if var is zero (0 as an integer or "0" as a string)
    elif [ "$var" == 0 2> /dev/null ]
    then
        [[ $( echo "1" ) ]]
        return

    # Return true if var is 0.0 (0 as a float)
    elif [ "$var" == 0.0 2> /dev/null ]
    then
        [[ $( echo "1" ) ]]
        return
    fi

    [[ $( echo "" ) ]]
}


if empty "${cliqrWebappContext}"
    then
       echo "There is no WebContext"
    else
       echo " Web Context Exist $cliqrWebappContext"
fi



if empty "${cliqrWebappConfigFiles}"
    then
       echo "There is no Config Files to Parase"
    else
       echo " Config File exist on $cliqrWebappConfigFiles path"
fi




tomcat_jdbc="/usr/local/apache-tomcat-7.0.59/webapps/$cliqrWebappContext/$cliqrWebappConfigFiles"
jdbc_driver="com.mysql.jdbc.Driver"
jpa_platform="oracle.toplink.essentials.platform.database.MySQL4Platform"
jpa_database="MYSQL"
hibernate_dialect="org.hibernate.dialect.MySQLDialect"
port="3306"

if empty "${CliqrDependencies}"
 then
        echo "Dependency Variable is Empty. No further Process."
 else

                echo "Dependencies variable has valid Value"
                Tier_Arr=$(echo $CliqrDependencies | tr "," "\n")
                for tier  in $Tier_Arr
                do
                        GSQL_Tier="CliqrTier_${tier}_PUBLIC_IP"
                        echo $GSQL_Tier
                        Tier_Type="CliqrTier_${tier}_driverClassName"
                        Tier_Class="mysql"
                        GSQL_TIER_IP=${!GSQL_Tier}
                        echo $GSQL_TIER_IP
						# Postgres logic
                        echo $Tier_Class
						if [ "$Tier_Class" = "postgresql" ]; then  
						  jdbc_driver="org.postgresql.Driver" 
						  jpa_platform="org.hibernate.dialect.PostgreSQLDialect"
						  jpa_database="POSTGRESQL"
						  hibernate_dialect="org.hibernate.dialect.PostgreSQLDialect"
						  port="5432"
						fi
						init_location="classpath:db/$Tier_Class/initDB.txt"
						data_location="classpath:db/$Tier_Class/populateDB.txt"

                        sed -i  's/^jdbc.url/#jdbc.url/g'  $tomcat_jdbc
						sed -i  's/^jdbc.driverClassName/#jdbc.driverClassName/g'  $tomcat_jdbc 
						sed -i  's/^jdbc.initLocation/#jdbc.initLocation/g'  $tomcat_jdbc 
						sed -i  's/^jdbc.dataLocation/#jdbc.dataLocation/g'  $tomcat_jdbc 
						sed -i  's/^hibernate.dialect/#hibernate.dialect/g'  $tomcat_jdbc 
						sed -i  's/^jpa.databasePlatform/#jpa.databasePlatform/g'  $tomcat_jdbc 
						sed -i  's/^jpa.database/#jpa.database/g'  $tomcat_jdbc 
						
                        echo "jdbc.url=jdbc:$Tier_Class://${GSQL_TIER_IP}:$port/petclinic" >> $tomcat_jdbc
						echo "jdbc.driverClassName=$jdbc_driver" >> $tomcat_jdbc
						echo "jdbc.initLocation=$init_location" >> $tomcat_jdbc
						echo "jdbc.dataLocation=$data_location" >> $tomcat_jdbc
						echo "hibernate.dialect=$hibernate_dialect" >> $tomcat_jdbc
						echo "jpa.databasePlatform=$jpa_platform" >> $tomcat_jdbc
						echo "jpa.database=$jpa_database" >> $tomcat_jdbc 
						
                        echo "jdbc.initialize=true" >> $tomcat_jdbc
                        echo "jdbc.datasource.initialize=true" >> $tomcat_jdbc
                        echo "spring.datasource.initialize=true" >> $tomcat_jdbc
                        echo "datasource.initialize=true" >> $tomcat_jdbc
                        echo "jdbc.initialization-mode=ALWAYS" >> $tomcat_jdbc
                        echo "datasource.initialization-mode=ALWAYS" >> $tomcat_jdbc
                        echo "jdbc.datasource.initialization-mode=ALWAYS" >> $tomcat_jdbc
                        echo "spring.datasource.initialization-mode=ALWAYS" >> $tomcat_jdbc
                        echo "export CliqrTier_Database_IP=$GSQL_TIER_IP"  >> /usr/local/osmosix/etc/userenv
						
                done
				
				
			
fi

source /usr/local/osmosix/etc/userenv


