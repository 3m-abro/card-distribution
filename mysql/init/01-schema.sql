-- ./mysql/init/01-schema.sql
-- Create tables with proper indexes
CREATE DATABASE job_search;

USE job_search;

CREATE TABLE job_categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0,
    created_by INT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted DATETIME DEFAULT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE job_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    job_category_id INT,
    sort_order INT DEFAULT 0,
    created_by INT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted DATETIME DEFAULT NULL,
    FOREIGN KEY (job_category_id) REFERENCES job_categories(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE jobs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    media_id INT,
    job_category_id INT,
    job_type_id INT,
    description TEXT,
    detail TEXT,
    business_skill TEXT,
    knowledge TEXT,
    location VARCHAR(255),
    activity TEXT,
    academic_degree_doctor BOOLEAN DEFAULT FALSE,
    academic_degree_master BOOLEAN DEFAULT FALSE,
    academic_degree_professional BOOLEAN DEFAULT FALSE,
    academic_degree_bachelor BOOLEAN DEFAULT FALSE,
    salary_statistic_group VARCHAR(255),
    salary_range_first_year VARCHAR(255),
    salary_range_average VARCHAR(255),
    salary_range_remarks TEXT,
    restriction TEXT,
    estimated_total_workers INT,
    remarks TEXT,
    url VARCHAR(255),
    seo_description TEXT,
    seo_keywords TEXT,
    sort_order INT DEFAULT 0,
    publish_status TINYINT DEFAULT 0,
    version INT DEFAULT 1,
    created_by INT,
    created DATETIME DEFAULT CURRENT_TIMESTAMP,
    modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted DATETIME DEFAULT NULL,
    FOREIGN KEY (job_category_id) REFERENCES job_categories(id),
    FOREIGN KEY (job_type_id) REFERENCES job_types(id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create tables for related entities
CREATE TABLE personalities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    deleted DATETIME DEFAULT NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE jobs_personalities (
    job_id INT,
    personality_id INT,
    PRIMARY KEY (job_id, personality_id),
    FOREIGN KEY (job_id) REFERENCES jobs(id),
    FOREIGN KEY (personality_id) REFERENCES personalities(id)
);

-- Add necessary indexes
ALTER TABLE jobs ADD FULLTEXT INDEX ft_jobs_search (
    name, description, detail, business_skill, knowledge, 
    location, activity, salary_statistic_group, salary_range_remarks, 
    restriction, remarks
);

ALTER TABLE job_categories ADD FULLTEXT INDEX ft_job_categories_name (name);
ALTER TABLE job_types ADD FULLTEXT INDEX ft_job_types_name (name);
ALTER TABLE personalities ADD FULLTEXT INDEX ft_personalities_name (name);
ALTER TABLE jobs ADD INDEX idx_publish_status_deleted (publish_status, deleted);
ALTER TABLE jobs ADD INDEX idx_sort_order_id (sort_order, id);

-- Insert test data
INSERT INTO job_categories (name, sort_order) VALUES 
('航空業界', 1),
('キャビンアテンダント部門', 2),
('グランドスタッフ部門', 3);

INSERT INTO job_types (name, job_category_id, sort_order) VALUES 
('国内線キャビンアテンダント', 2, 1),
('国際線キャビンアテンダント', 2, 2),
('研修担当キャビンアテンダント', 2, 3);

INSERT INTO jobs (
    name, job_category_id, job_type_id, description, 
    detail, business_skill, knowledge, location, 
    salary_range_average, publish_status, sort_order
) VALUES 
('経験者採用 国際線キャビンアテンダント', 2, 2,
 'キャビンアテンダントとして、安全で快適な空の旅を提供します。',
 '国際線での経験を活かし、グローバルな環境で活躍できます。',
 '接客経験、語学力（英語必須）',
 '航空保安、安全管理、救急救命',
 '東京都',
 '450万円 ～ 600万円',
 1, 100),
('新卒採用 国内線キャビンアテンダント', 2, 1,
 'キャビンアテンダントとして国内線でのサービスを担当。',
 '丁寧な研修制度で未経験からでもスキルアップできます。',
 '接客経験歓迎',
 '航空業界の基礎知識',
 '大阪府',
 '350万円 ～ 450万円',
 1, 90);

-- Insert test personality data
INSERT INTO personalities (name) VALUES 
('コミュニケーション力が高い'),
('キャビンアテンダントに向いている性格'),
('チームワーク重視');

-- Create personality relationships
INSERT INTO jobs_personalities (job_id, personality_id) VALUES 
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2);

-- Create optimized view for frequently accessed data
CREATE OR REPLACE VIEW v_active_jobs AS
SELECT 
    j.id,
    j.name,
    j.description,
    j.location,
    jc.name as category_name,
    jt.name as type_name
FROM jobs j
INNER JOIN job_categories jc ON j.job_category_id = jc.id
INNER JOIN job_types jt ON j.job_type_id = jt.id
WHERE j.deleted IS NULL
AND j.publish_status = 1;

-- Optimized search function
DELIMITER //

CREATE FUNCTION search_jobs(search_term VARCHAR(255))
RETURNS INT
READS SQL DATA
BEGIN
    -- Declare a variable to store the result count
    DECLARE result_count INT;
    
    -- Create a temporary table to store the search results
    CREATE TEMPORARY TABLE IF NOT EXISTS job_search_results (
        id INT,
        name VARCHAR(255),
        description TEXT,
        category_name VARCHAR(255),
        type_name VARCHAR(255)
    );
    
    -- Insert the search results into the temporary table
    INSERT INTO job_search_results
    SELECT 
        j.id,
        j.name,
        j.description,
        jc.name as category_name,
        jt.name as type_name
    FROM jobs j
    INNER JOIN job_categories jc ON j.job_category_id = jc.id
    INNER JOIN job_types jt ON j.job_type_id = jt.id
    WHERE j.deleted IS NULL 
    AND j.publish_status = 1
    AND (
        MATCH(j.name, j.description, j.detail, j.business_skill, j.knowledge, 
              j.location, j.activity, j.salary_statistic_group, 
              j.salary_range_remarks, j.restriction, j.remarks) 
        AGAINST(search_term IN BOOLEAN MODE)
        OR MATCH(jc.name) AGAINST(search_term IN BOOLEAN MODE)
        OR MATCH(jt.name) AGAINST(search_term IN BOOLEAN MODE)
    )
    ORDER BY j.sort_order DESC, j.id DESC
    LIMIT 50;
    
    -- Get the count of results
    SELECT COUNT(*) INTO result_count FROM job_search_results;
    
    RETURN result_count;
END
DELIMITER ;

-- Create a procedure to retrieve the results
DELIMITER //

CREATE PROCEDURE get_search_results()
BEGIN
    SELECT * FROM job_search_results;
END //

DELIMITER ;

-- Set up MySQL optimizer hints
SET GLOBAL optimizer_switch='mrr=on,mrr_cost_based=off,batched_key_access=on';

-- Optimize table settings
ALTER TABLE jobs ENGINE=InnoDB;
ALTER TABLE job_categories ENGINE=InnoDB;
ALTER TABLE job_types ENGINE=InnoDB;

-- Analyze and optimize tables
ANALYZE TABLE jobs, job_categories, job_types;
OPTIMIZE TABLE jobs, job_categories, job_types;