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
