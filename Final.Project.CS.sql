SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 'ON';
SHOW GLOBAL VARIABLES LIKE 'local_infile';


-- Drop the database if it exists
DROP DATABASE IF EXISTS study_data_db;

-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS study_data_db;

-- Use the created database
USE study_data_db;

-- Create the `study_data` table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS study_data (
    study_id INT PRIMARY KEY,            -- Unique identifier for each patient
    illnessinjury INT,                   -- Illness/injury indicator
    ER_5groups INT,                      -- Ethnoracial group (numeric or coded)
    HMHRS INT,                           -- HMHRS score
    HMHRSrisk INT,                       -- HMHRS risk level
    TwoMosDone INT,                      -- 2-month follow-up completed (yes/no)
    MHsxs2m INT,                         -- 2-month mental health symptoms score
    MHsxs2m_level INT,                   -- 2-month mental health symptoms level (high/low)
    langdone INT,                        -- Language done (numeric)
    age INT,                             -- Age
    gender INT,                          -- Gender
    marital INT,                         -- Marital status
    education INT,                       -- Education level
    workstatus INT,                      -- Employment status
    income_coded INT,                    -- Coded income group (0 = Low, 1 = High, -1 = Unknown)
    respect INT,                         -- Treated with respect score
    pastmh INT,                          -- Past mental health issues score
    cutoff INT,                          -- Felt cut off score
    stressed INT,                        -- Stress level score
    strange_dss INT,                     -- Perception of strange/disconnected surroundings
    phq6_badaboutself INT,               -- PHQ6 score (feel bad about self)
    nolove INT,                          -- Feeling of lack of love
    pessimism INT,                       -- Pessimism about self or the world
    hypervigilant INT,                   -- Hypervigilance (aware/nervous)
    notontop INT,                        -- Not feeling "on top of things"
    GAD7_2m INT,                         -- 2-month GAD-7 score
    PHQ8_2m INT,                         -- 2-month PHQ-8 score
    PTSDsxs_2m INT                       -- 2-month PTSD symptoms score
);


--




-- Load data and handle empty, NULL, or invalid 'Income_coded' values as '-1' for unknown
LOAD DATA LOCAL INFILE '/Users/yumikochow/Documents/CS3200/HMHRS_replication_paper_data.csv'
INTO TABLE study_data
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@study_id, @illnessinjury, @ER_5groups, @HMHRS, @HMHRSrisk, @TwoMosDone, @MHsxs2m, @MHsxs2m_level,
 @langdone, @age, @gender, @marital, @education, @workstatus, @income_coded, @respect, @pastmh, @cutoff,
 @stressed, @strange_dss, @phq6_badaboutself, @nolove, @pessimism, @hypervigilant, @notontop, @GAD7_2m, 
 @PHQ8_2m, @PTSDsxs_2m)
SET 
    study_id = @study_id,
    illnessinjury = @illnessinjury,
    ER_5groups = @ER_5groups,
    HMHRS = @HMHRS,
    HMHRSrisk = @HMHRSrisk,
    TwoMosDone = @TwoMosDone,
    MHsxs2m = @MHsxs2m,
    MHsxs2m_level = @MHsxs2m_level,
    langdone = @langdone,
    age = @age,
    gender = @gender,
    marital = @marital,
    education = @education,
    workstatus = @workstatus,
    income_coded = IF(@income_coded = '' OR @income_coded IS NULL OR @income_coded = ' ' OR @income_coded NOT REGEXP '^-?[0-9]+$', -1, @income_coded),
    respect = @respect,
    pastmh = @pastmh,
    cutoff = @cutoff,
    stressed = @stressed,
    strange_dss = @strange_dss,
    phq6_badaboutself = @phq6_badaboutself,
    nolove = @nolove,
    pessimism = @pessimism,
    hypervigilant = @hypervigilant,
    notontop = @notontop,
    GAD7_2m = @GAD7_2m,
    PHQ8_2m = @PHQ8_2m,
    PTSDsxs_2m = @PTSDsxs_2m;




-- Update rows where 'income_coded' is NULL, empty, or non-numeric to a default value of '-1' for unknown
UPDATE study_data
SET income_coded = -1
WHERE income_coded IS NULL OR income_coded = '' OR income_coded = ' ' OR income_coded NOT REGEXP '^-?[0-9]+$';

-- Create `patient_demographics` table 
CREATE TABLE IF NOT EXISTS patient_demographics (
    study_id INT PRIMARY KEY,
    Income_coded INT NOT NULL,            -- Coded income group (0 = Low, 1 = High, -1 = Unknown)
    Education VARCHAR(50) NOT NULL,
    ER_5groups VARCHAR(50) NOT NULL,
    Marital VARCHAR(50) NOT NULL,
    age INT NOT NULL, 
    workstatus VARCHAR (50) NOT NULL, 
    gender VARCHAR (10) NOT NULL
);

-- Create `mental_health_symptoms` table 
CREATE TABLE IF NOT EXISTS mental_health_symptoms (
    study_id INT PRIMARY KEY, 
    MHsxs2m INT NOT NULL,
    date_assessed DATE,
    FOREIGN KEY (study_id) REFERENCES patient_demographics(study_id)
);

-- Create 'mental_health_questionnaire' table
CREATE TABLE IF NOT EXISTS mental_health_questionnaire (
    study_id INT AUTO_INCREMENT PRIMARY KEY,
    respect VARCHAR(50) NOT NULL,
    Pastmh VARCHAR(50) NOT NULL,
    Cutoff VARCHAR(50) NOT NULL,
    stressed VARCHAR(50) NOT NULL,
    Strange_dss VARCHAR(50) NOT NULL,
    Phq6_badaboutself VARCHAR(50) NOT NULL,
    Nolove VARCHAR(50) NOT NULL,
    Pessimism VARCHAR(50) NOT NULL,
    Hypervigilant VARCHAR(50) NOT NULL,
    Notontop VARCHAR(50) NOT NULL,
    FOREIGN KEY (study_id) REFERENCES patient_demographics(study_id)
);


-- Create 'follow-up' table
CREATE TABLE IF NOT EXISTS follow_up (
    study_id INT AUTO_INCREMENT PRIMARY KEY,
    TwoMosDone BOOLEAN,
    MHsxs2m VARCHAR(50) NOT NULL,
    MHsxs2m_level VARCHAR(50) NOT NULL,
    GAD7_2m INT NOT NULL,
    PHQ8_2m INT NOT NULL,
    PTSDsxs_2m INT NOT NULL,
    FOREIGN KEY (study_id) REFERENCES patient_demographics(study_id)
);

-- Create `marital_impact` table
CREATE TABLE IF NOT EXISTS marital_impact (
    study_id INT PRIMARY KEY,           -- Unique identifier for the participant
    ER_5groups VARCHAR(50) NOT NULL,    -- Ethnoracial group
    marital_status VARCHAR(50) NOT NULL, -- Marital status of the participant
    MHsxs2m INT NOT NULL,                -- Mental health symptoms score
    FOREIGN KEY (study_id) REFERENCES study_data(study_id)
);

-- Create `past_mh_impact` table
CREATE TABLE IF NOT EXISTS past_mh_impact (
    study_id INT PRIMARY KEY,               -- Unique identifier for the participant
    ER_5groups VARCHAR(50) NOT NULL,        -- Ethnoracial group
    past_mental_health BOOLEAN NOT NULL,    -- Whether the participant has a past mental health history
    MHsxs2m INT NOT NULL,                   -- Mental health symptoms score
    FOREIGN KEY (study_id) REFERENCES study_data(study_id)
);

-- Create `education` table
CREATE TABLE IF NOT EXISTS education (
    study_id INT PRIMARY KEY,   
    EDUC VARCHAR(255),          
    FOREIGN KEY (study_id) REFERENCES study_data(study_id) 
);




-- Insert data into `patient_demographics` from `study_data`
INSERT INTO patient_demographics (study_id, Income_coded, Education, ER_5groups, Marital, workstatus, age, gender)
SELECT study_id, 
       income_coded,
       education,
       ER_5groups,
       IF(marital = 0, 'Single', 
          IF(marital = 1, 'Married', 
          IF(marital = 2, 'Divorced', 'Widowed'))) AS Marital,
	   CASE 
		  WHEN workstatus = 0 THEN 'Unemployed'
          WHEN workstatus = 1 THEN 'Employed'
          WHEN workstatus = 2 THEN 'Retired'
          ELSE 'Other' 
		END AS workstatus,
        age, 
        CASE 
		  WHEN gender = 0 THEN 'Male'
          WHEN gender = 1 THEN 'Female'
          Else 'Other' 
		END AS gender
FROM study_data sd
ON DUPLICATE KEY UPDATE
    Income_coded = sd.income_coded,
    Education = sd.Education,
    ER_5groups = sd.ER_5groups,
    Marital = VALUES(Marital),
    workstatus = VALUES(workstatus),
    age = sd.age,
    gender = VALUES(gender);
    

-- Insert data into `mental_health_symptoms` from `study_data`
INSERT INTO mental_health_symptoms (study_id, MHsxs2m, date_assessed)
SELECT study_id, MHsxs2m, CURRENT_DATE()
FROM study_data sd
ON DUPLICATE KEY UPDATE
    MHsxs2m = sd.MHsxs2m,
    date_assessed = CURRENT_DATE();
    
    
-- Insert data into `mental_health_questionnaire` from `study_data`
INSERT INTO mental_health_questionnaire 
    (study_id, respect, Pastmh, Cutoff, stressed, Strange_dss, Phq6_badaboutself, Nolove, Pessimism, Hypervigilant, Notontop)
SELECT
    study_id,
    respect,
    Pastmh,
    Cutoff,
    stressed,
    Strange_dss,
    Phq6_badaboutself,
    Nolove,
    Pessimism,
    Hypervigilant,
    Notontop
FROM study_data sd
ON DUPLICATE KEY UPDATE
    respect = sd.respect,
    Pastmh  = sd.Pastmh,
    Cutoff  = sd.Cutoff,
    stressed = sd.stressed,
    Strange_dss = sd.Strange_dss,
    Phq6_badaboutself = sd.Phq6_badaboutself,
    Nolove = sd.Nolove,
    Pessimism = sd.Pessimism,
    Hypervigilant = sd.Hypervigilant,
    Notontop = sd.Notontop;
    
    -- Insert data into `follow_up` from `study_data`
INSERT INTO follow_up 
    (study_id, TwoMosDone, MHsxs2m, MHsxs2m_level, GAD7_2m, PHQ8_2m, PTSDsxs_2m)
SELECT 
    study_id,
    TwoMosDone,
    MHsxs2m,
    MHsxs2m_level,
    GAD7_2m,
    PHQ8_2m,
    PTSDsxs_2m
FROM study_data sd
ON DUPLICATE KEY UPDATE
    TwoMosDone = sd.TwoMosDone,
    MHsxs2m = sd.MHsxs2m,
    MHsxs2m_level = sd.MHsxs2m_level,
    GAD7_2m = sd.GAD7_2m,
    PHQ8_2m = sd.PHQ8_2m,
    PTSDsxs_2m = sd.PTSDsxs_2m;
    

-- Populate `marital_impact`
INSERT INTO marital_impact (study_id, ER_5groups, marital_status, MHsxs2m)
SELECT 
    study_id,
    CASE 
        WHEN ER_5groups = 0 THEN 'Group A'
        WHEN ER_5groups = 1 THEN 'Group B'
        WHEN ER_5groups = 2 THEN 'Group C'
        WHEN ER_5groups = 3 THEN 'Group D'
        WHEN ER_5groups = 4 THEN 'Group E'
        WHEN ER_5groups = 5 THEN 'Group B'
        ELSE 'Other' 
    END AS ER_5groups,
    CASE 
        WHEN marital = 0 THEN 'Single'
        WHEN marital = 1 THEN 'Married'
        WHEN marital = 2 THEN 'Divorced'
        ELSE 'Other' 
    END AS marital_status,
    MHsxs2m
FROM study_data;

-- Populate `past_mh_impact`
INSERT INTO past_mh_impact (study_id, ER_5groups, past_mental_health, MHsxs2m)
SELECT 
    study_id,
    CASE 
        WHEN ER_5groups = 0 THEN 'Group A'
        WHEN ER_5groups = 1 THEN 'Group B'
        WHEN ER_5groups = 2 THEN 'Group C'
        WHEN ER_5groups = 3 THEN 'Group D'
        WHEN ER_5groups = 4 THEN 'Group E'
        WHEN ER_5groups = 5 THEN 'Group B'
        ELSE 'Other' 
    END AS ER_5groups,
    pastmh AS past_mental_health,
    MHsxs2m
FROM study_data;


-- Query 1: Relationship Between Income, Education, 
-- and Mental Health Symptoms by Ethnicity
SELECT 
    pd.ER_5groups AS Ethnicity, 
    pd.Income_coded As Income, 
    AVG(mh.MHsxs2m) AS Avg_Symptoms
FROM 
    patient_demographics pd
JOIN 
    mental_health_symptoms mh ON pd.study_id = mh.study_id
GROUP BY 
    pd.ER_5groups, 
    pd.Income_coded
ORDER BY 
    pd.ER_5groups, 
    pd.Income_coded;



-- Query 2: Comparing Mental Health Symptoms by Income and 
-- Education Within Ethnicity
SELECT 
	pd.ER_5groups AS Ethnicity, 
	pd.Income_coded AS Income, 
	pd.Education AS Education, 
	COUNT(*) AS num_patients, 
	AVG(mh.MHsxs2m) AS Avg_Symptoms
FROM 
	patient_demographics pd
JOIN 
	mental_health_symptoms mh ON pd.study_id = mh.study_id
GROUP BY 
	pd.ER_5groups, 
	pd.Income_coded, 
	pd.Education
ORDER BY 
	pd.ER_5groups, 
	pd.Income_coded, 
	pd.Education;

-- Query: Relationship between PTSD symptoms and feels of being cut off 
SELECT 
    Cutoff, 
    AVG(PTSDsxs_2m) AS Avg_PTSD_Symptoms, 
    COUNT(*) AS Participant_Count
FROM mental_health_questionnaire mq
JOIN follow_up f ON mq.study_id = f.study_id
GROUP BY Cutoff;

-- Query: How does being cut off and PTSD vary across different marital statuses?
SELECT 
    p.marital, 
    mq.Cutoff, 
    AVG(f.PTSDsxs_2m) AS Avg_PTSD_Symptoms, 
    COUNT(*) AS Participant_Count
FROM patient_demographics p
JOIN mental_health_questionnaire mq ON p.study_id = mq.study_id
JOIN follow_up f ON p.study_id = f.study_id
GROUP BY p.marital, mq.Cutoff
ORDER BY p.marital, mq.Cutoff;

-- Query: How do language preferences and race interact to influence mental health symptoms?
SELECT 
    pd.ER_5groups AS Ethnicity, 
    sd.langdone AS Language_Preference, 
    AVG(mh.MHsxs2m) AS Avg_MH_Symptoms, 
    COUNT(*) AS Participant_Count
FROM study_data sd
JOIN patient_demographics pd ON sd.study_id = pd.study_id
JOIN mental_health_symptoms mh ON sd.study_id = mh.study_id
GROUP BY pd.ER_5groups, sd.langdone
ORDER BY pd.ER_5groups, sd.langdone;



-- Query: What role does education play in this relationship?
SELECT 
    pd.ER_5groups AS Ethnicity, 
    sd.langdone AS Language_Preference, 
    pd.education AS Education_Level, 
    AVG(mh.MHsxs2m) AS Avg_MH_Symptoms, 
    COUNT(*) AS Participant_Count
FROM study_data sd
JOIN patient_demographics pd ON sd.study_id = pd.study_id
JOIN mental_health_symptoms mh ON sd.study_id = mh.study_id
GROUP BY pd.ER_5groups, sd.langdone, pd.education
ORDER BY pd.ER_5groups, sd.langdone, pd.education;


-- Query: How does marital status impact mental health symptoms across different ethnoracial groups?
Select ER_5groups as ethnoracial_group, marital_status, AVG(MHsxs2m) as avg_MHsxs2m
From marital_impact
Group By ER_5groups, marital_status
Order By ER_5groups, marital_status;

-- Query: How does past mental health history impct mental health symptoms across different ethnoracial groups?
Select ER_5groups as ethnoracial_group, past_mental_health, AVG(MHsxs2m) as avg_MHsxs2m
from past_mh_impact
Group By ER_5groups, past_mental_health
Order By ER_5groups, past_mental_health;

