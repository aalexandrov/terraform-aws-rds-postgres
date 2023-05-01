# Materialize + Postgres RDS + Terraform

Terraform module for deploying a new RDS Postgres instance and connecting it to Materialize.

For the manual setup, see the [Materialize + RDS](https://materialize.com/docs/integrations/cdc-postgres/#direct-postgres-source) documentation.

> **Warning** This is provided on a best-effort basis and Materialize cannot offer support for this module.

## Overview

This module will create the following resources:

- VPC with public and private subnets
- Security group for RDS Postgres instance: allows inbound traffic from Materialize and the user's IP address
- RDS Postgres instance
- RDS Parameter Group for RDS Postgres instance to enable logical replication

To override the default AWS provider variables, you can export the following environment variables:

```bash
export AWS_PROFILE=<your_aws_profile> # eg. default
export AWS_CONFIG_FILE=<your_aws_config_file> # eg. ["~/.aws/config"]
```

## Prerequisites

Before using this module, you must have the following:

- An AWS account
- Materialize instance
- Get your Materialize instance egress IP addresses from the `mz_egress_ips` table:

    Access the Materialize instance and run the following query:

    ```sql
    SELECT '[' || string_agg( '"' || egress_ip || '/32' || '"', ', ') || ']' as egress_ip_array
        FROM mz_egress_ips;
    ```

    The query above will return a JSON array of egress IP addresses. Define the following variable in your `terraform.tfvars` file:

    ```bash
    mz_egress_ips = ["123.456.789.0/32", "123.456.789.1/32"]
    ```

## Running the module

1. Clone the repository:

    ```bash
    git clone https://github.com/bobbyiliev/terraform-materialize-rds.git
    ```

2. Copy the `terraform.tfvars.example` file to `terraform.tfvars` and fill in the variables:

    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```

3. Add the Materialize instance egress IP addresses to the `mz_egress_ips` variable in `terraform.tfvars`:

    ```bash
    mz_egress_ips = ["123.456.789.0/32", "123.456.789.1/32"]
    ```

4. Apply the Terraform configuration:

    ```bash
    terraform apply
    ```

    Once you run the command, it might take a few minutes for the RDS instance to be created.

5. Check the output:

    ```bash
    terraform output -raw mz_rds_details
    ```

## Output

```sql
    -- On the RDS instance side:
    -- 1. Connect to the RDS instance
    PGPASSWORD=YOUR_SECURE_PASSWORD psql -h mz-rds-demo-db.some-db-url.us-east-1.rds.amazonaws.com -U materialize -d materialize
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
    CREATE SECRET mz_rds_password AS 'YOUR_SECURE_PASSWORD';
    -- 2. Create a connection to the RDS instance
    CREATE CONNECTION pg_connection TO POSTGRES (
        HOST 'mz-rds-demo-db.some-db-url.us-east-1.rds.amazonaws.com',
        PORT 5432,
        USER 'materialize',
        PASSWORD SECRET mz_rds_password,
        SSL MODE 'require',
        DATABASE 'materialize'
    );

    -- 3. Create a source
    CREATE SOURCE mz_source
        FROM POSTGRES CONNECTION pg_connection (PUBLICATION 'mz_source')
        FOR ALL TABLES
        WITH (SIZE = '3xsmall');

    -- 4. Query the source
    SELECT * FROM test_table;
```

## Security

The RDS instance is publicly accessible, but the module creates a security group that allows inbound traffic from the Materialize egress IPs and the user's IP address on port 5432.

## Helpful links

- [Materialize](https://materialize.com/)
- [Postgres Connection](https://materialize.com/docs/sql/create-connection/#postgres)
- [Postgres CDC](https://materialize.com/docs/integrations/cdc-postgres/)
- [Materialize Terraform Provider](https://github.com/MaterializeInc/terraform-provider-materialize)
