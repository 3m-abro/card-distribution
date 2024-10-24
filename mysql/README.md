# SQL Optimization and Virtual Environment Setup

This guide explains how to set up a virtual environment using **Docker** for MySQL and test the optimized SQL query from **Phase 3**.

## Prerequisites

Before testing, ensure you have the following installed:

- [Docker](https://www.docker.com/get-started)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 1. Clone the Repository

First, clone the repository to your local machine:

```bash
git clone https://github.com/3m-abro/card-distribution.git
cd card-distribution
```

## 2. Setting Up the MySQL Database in Docker

To create and configure the MySQL database, follow these steps:

### Step 1: Create the Docker Environment

1. Ensure your **`docker-compose.yml`** is correctly set up for MySQL. Here’s an example:

   ```yaml
   version: '3.8'
   services:
     mysql:
        image: mysql:8.0
        container_name: mysql
        restart: unless-stopped
        environment:
        MYSQL_ROOT_PASSWORD: root
        MYSQL_DATABASE: card_db
        MYSQL_USER: user
        MYSQL_PASSWORD: password
        ports:
            - "3306:3306"
        volumes:
            - mysql-data:/var/lib/mysql
            - ./mysql/init:/docker-entrypoint-initdb.d
            - ./mysql/conf.d:/etc/mysql/conf.d
        cap_add:
            - SYS_NICE  # CAP_SYS_NICE for better CPU scheduling
        networks:
            - card-distribution
   ```

2. **Start the MySQL container**:

   ```bash
   docker-compose up -d
   ```

   This will start the MySQL container and create the `card_db` database.

### Step 2: Connect to MySQL and Create Tables, Insert Sample Data and Create Indexes for Optimization

1. Connect to the running MySQL container:

   ```bash
   docker exec -it mysql-db mysql -u user -p < docker-entrypoint-initdb.d/01-schema.sql
   ```

   This will create `job_search` database, tables and insert sample data.

2. Enter the password when prompted (`password` by default).

### Step 3: Run the Optimized SQL Query

1. Run the improved SQL query to test its performance:

   ```sql
    -- Main optimized query
    WITH RECURSIVE 

    -- CTE for related personality matches
    personalities_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_personalities jp ON j.id = jp.job_id
        INNER JOIN personalities p ON p.id = jp.personality_id
        WHERE p.deleted IS NULL 
        AND MATCH(p.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- CTE for related practical skills matches
    practical_skills_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_practical_skills jps ON j.id = jps.job_id
        INNER JOIN practical_skills ps ON ps.id = jps.practical_skill_id
        WHERE ps.deleted IS NULL 
        AND MATCH(ps.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- CTE for related basic abilities matches
    basic_abilities_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_basic_abilities jba ON j.id = jba.job_id
        INNER JOIN basic_abilities ba ON ba.id = jba.basic_ability_id
        WHERE ba.deleted IS NULL 
        AND MATCH(ba.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- CTE for tools matches
    tools_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_tools jt ON j.id = jt.job_id
        INNER JOIN affiliates a ON a.id = jt.affiliate_id
        WHERE a.deleted IS NULL 
        AND a.type = 1
        AND MATCH(a.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- Combine all related matches
    all_related_matches AS (
        SELECT job_id FROM personalities_matches
        UNION
        SELECT job_id FROM practical_skills_matches
        UNION
        SELECT job_id FROM basic_abilities_matches
        UNION
        SELECT job_id FROM tools_matches
    )

    -- Main query with optimized structure
    SELECT 
        -- Only select needed columns instead of all columns
        j.id,
        j.name,
        j.media_id,
        j.job_category_id,
        j.job_type_id,
        j.description,
        j.detail,
        j.business_skill,
        j.knowledge,
        j.location,
        j.activity,
        j.salary_statistic_group,
        j.salary_range_remarks,
        j.restriction,
        j.remarks,
        j.url,
        -- Include essential related data
        jc.name AS category_name,
        jt.name AS type_name
    FROM jobs j
        -- Use INNER JOIN instead of LEFT JOIN where appropriate
        INNER JOIN job_categories jc 
            ON j.job_category_id = jc.id 
            AND jc.deleted IS NULL
        INNER JOIN job_types jt 
            ON j.job_type_id = jt.id 
            AND jt.deleted IS NULL
        -- Left join with our combined matches
        LEFT JOIN all_related_matches arm 
            ON j.id = arm.job_id
    WHERE 
        j.deleted IS NULL
        AND j.publish_status = 1
        AND (
            -- Use MATCH AGAINST instead of LIKE for better performance
            MATCH(j.name, j.description, j.detail, j.business_skill,
                j.knowledge, j.location, j.activity, j.salary_statistic_group,
                j.salary_range_remarks, j.restriction, j.remarks)
            AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
            OR MATCH(jc.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
            OR MATCH(jt.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
            OR arm.job_id IS NOT NULL
        )
    GROUP BY j.id
    ORDER BY j.sort_order DESC, j.id DESC
    LIMIT 50;
   ```

2. **Use the `EXPLAIN ANALYZE` statement** to verify how MySQL executes the query and check if the indexes are being used:

   ```sql
    EXPLAIN ANALYZE
    -- Main optimized query
    WITH RECURSIVE 

    -- CTE for related personality matches
    personalities_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_personalities jp ON j.id = jp.job_id
        INNER JOIN personalities p ON p.id = jp.personality_id
        WHERE p.deleted IS NULL 
        AND MATCH(p.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- CTE for related practical skills matches
    practical_skills_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_practical_skills jps ON j.id = jps.job_id
        INNER JOIN practical_skills ps ON ps.id = jps.practical_skill_id
        WHERE ps.deleted IS NULL 
        AND MATCH(ps.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- CTE for related basic abilities matches
    basic_abilities_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_basic_abilities jba ON j.id = jba.job_id
        INNER JOIN basic_abilities ba ON ba.id = jba.basic_ability_id
        WHERE ba.deleted IS NULL 
        AND MATCH(ba.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- CTE for tools matches
    tools_matches AS (
        SELECT DISTINCT j.id AS job_id
        FROM jobs j
        INNER JOIN jobs_tools jt ON j.id = jt.job_id
        INNER JOIN affiliates a ON a.id = jt.affiliate_id
        WHERE a.deleted IS NULL 
        AND a.type = 1
        AND MATCH(a.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
    ),

    -- Combine all related matches
    all_related_matches AS (
        SELECT job_id FROM personalities_matches
        UNION
        SELECT job_id FROM practical_skills_matches
        UNION
        SELECT job_id FROM basic_abilities_matches
        UNION
        SELECT job_id FROM tools_matches
    )

    -- Main query with optimized structure
    SELECT 
        -- Only select needed columns instead of all columns
        j.id,
        j.name,
        j.media_id,
        j.job_category_id,
        j.job_type_id,
        j.description,
        j.detail,
        j.business_skill,
        j.knowledge,
        j.location,
        j.activity,
        j.salary_statistic_group,
        j.salary_range_remarks,
        j.restriction,
        j.remarks,
        j.url,
        -- Include essential related data
        jc.name AS category_name,
        jt.name AS type_name
    FROM jobs j
        -- Use INNER JOIN instead of LEFT JOIN where appropriate
        INNER JOIN job_categories jc 
            ON j.job_category_id = jc.id 
            AND jc.deleted IS NULL
        INNER JOIN job_types jt 
            ON j.job_type_id = jt.id 
            AND jt.deleted IS NULL
        -- Left join with our combined matches
        LEFT JOIN all_related_matches arm 
            ON j.id = arm.job_id
    WHERE 
        j.deleted IS NULL
        AND j.publish_status = 1
        AND (
            -- Use MATCH AGAINST instead of LIKE for better performance
            MATCH(j.name, j.description, j.detail, j.business_skill,
                j.knowledge, j.location, j.activity, j.salary_statistic_group,
                j.salary_range_remarks, j.restriction, j.remarks)
            AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
            OR MATCH(jc.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
            OR MATCH(jt.name) AGAINST('キャビンアテンダント' IN BOOLEAN MODE)
            OR arm.job_id IS NOT NULL
        )
    GROUP BY j.id
    ORDER BY j.sort_order DESC, j.id DESC
    LIMIT 50;
   ```

---

## 3. Testing the Optimized Query

### Step 1: Benchmark the Query

1. **Run the original query** (if needed) and note down the execution time.
2. **Run the optimized query** and compare the performance improvements.

### Step 2: Analyze the `EXPLAIN` Output

- Verify that the query is using the **indexes** created earlier.
- Check the **rows** and **keys** being scanned to ensure optimal query execution.

---

## 4. Clean Up

To stop and remove the containers:

```bash
docker-compose down
```

---

## Summary of Changes

1. **Optimizations**: Indexing key columns, reducing the number of selected columns, and simplifying `JOINs`.
2. **Testing**: Use Docker to create a MySQL environment and test the optimized query.
