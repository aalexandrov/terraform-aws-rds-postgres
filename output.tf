output "rds_instance" {
  value = aws_db_instance.mz_rds_demo_db
}

output "mz_rds_details" {
  sensitive = true
  value     = <<EOF
    -- On the RDS instance side:
    -- 1. Connect to the RDS instance
    PGPASSWORD=${aws_db_instance.mz_rds_demo_db.password} psql -h ${aws_db_instance.mz_rds_demo_db.address} -U ${aws_db_instance.mz_rds_demo_db.username} -d ${aws_db_instance.mz_rds_demo_db.db_name}
    -- 2. Create a new table
    CREATE TABLE test_table (id int, name varchar(255));
    -- 3. Insert some data
    INSERT INTO test_table VALUES (1, 'test'), (2, 'test2');
    -- 4. Verify the data
    SELECT * FROM test_table;
    -- 5. Set the replica identity to full
    ALTER TABLE test_table REPLICA IDENTITY FULL;
    -- 6. Create a publication
    CREATE PUBLICATION mz_source FOR TABLE test_table;

    -- On the Materialize side:
    -- 1. Create a secret for the RDS password
    CREATE SECRET mz_rds_password AS '${aws_db_instance.mz_rds_demo_db.password}';
    -- 2. Create a connection to the RDS instance
    CREATE CONNECTION pg_connection TO POSTGRES (
        HOST '${aws_db_instance.mz_rds_demo_db.address}',
        PORT 5432,
        USER '${aws_db_instance.mz_rds_demo_db.username}',
        PASSWORD SECRET mz_rds_password,
        SSL MODE 'require',
        DATABASE '${aws_db_instance.mz_rds_demo_db.db_name}'
    );

    -- 3. Create a source
    CREATE SOURCE mz_source
        FROM POSTGRES CONNECTION pg_connection (PUBLICATION 'mz_source')
        FOR ALL TABLES
        WITH (SIZE = '2xsmall');

    -- 4. Query the source
    SELECT * FROM test_table;

    EOF
}
