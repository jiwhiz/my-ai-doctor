CREATE TABLE myhealth.health_records
(
    id              BIGINT        NOT NULL,
    version         BIGINT        NOT NULL DEFAULT 1,
    user_id         VARCHAR(255)  NOT NULL,
    rbc             VARCHAR(255)  NULL,
    hemoglobin      VARCHAR(255)  NULL,
    hematocrit      VARCHAR(255)  NULL,
    tsh             VARCHAR(255)  NULL,
    glucose         VARCHAR(255)  NULL,
    cholesterol     VARCHAR(255)  NULL,
    mchc            VARCHAR(255)  NULL,
    created_at      TIMESTAMPTZ   NOT NULL,
    created_by      VARCHAR(100)  NOT NULL,
    updated_at      TIMESTAMPTZ   NOT NULL,
    updated_by      VARCHAR(100)  NOT NULL,
    PRIMARY KEY(id)
);

create index health_records_idx1
    on myhealth.health_records (user_id);

INSERT INTO myhealth.health_records(id, user_id, rbc, hemoglobin, hematocrit, tsh, glucose, cholesterol, mchc, created_at, created_by, updated_at, updated_by)
VALUES
 (1, 'john.doe@jiwhiz.com', '4.80 10*12/L', '150 g/L', '0.47 L/L', '2.94 mU/L', '5.6 mmol/L', '4.06 mmol/L', '329 g/L', NOW(), 'system', NOW(), 'system')
,(2, 'jane.doe@jiwhiz.com', '4.79 10*12/L', '154 g/L', '0.50 L/L', '5.01 mU/L', '2.0 mmol/L', '5.32 mmol/L', '350 g/L', NOW(), 'system', NOW(), 'system')
;
