Readme.txt for Java lob demos. Updated for DB 11.2

See the Chapter "Getting Started" in the "Oracle  Database
JDBC Developer's Guide and Reference" for information
on setting up your system to be able to compile and run
JDBC programs with the Oracle Driver.

You may use JDK 5 and ojdbc5.jar or JDK6 and ojdbc6.jar.
If JDK 5 is uses you must include on the command line

   -Djdbc.drivers=oracle.jdbc.OracleDriver 

to specify the driver to use. In JDK 6 this is not
required.

As written LobDemoConnectionFactory uses the JDBC OCI
driver with a local connection. You should edit the URL
"jdbc:oracle:oci8:@" to match your setup. Again see the
"Getting Started" section in the manual.

The file names in this directory match those for the
other language in parallel subdirectories and generally
implement the same algorithms. They are not normal 
Java style class names. 

These classes are written for JDBC 3.0 supported with
ojdbc5.jar and JDK 1.5. JDBC 4.0 is added in JDK6 and is 
supported starting in DB 11.1 in ojdbc6.jar. See the
JDBC lob demos for JDBC 4.0 examples. 

Where possible only JDK standard classes and methods are
used. If a cases where the standard does not provide
the desired functionality, it is necessary to use Oracle
proprietary classes.

To increase clarity, the code is written without exception
handling or defensive tests, etc. Any exceptions will be
handled by the top level handler in the code that launches
the main function. This would not be good practice for
production code.



