package com.jiwhiz.myhealth.record;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.Cache;
import org.hibernate.annotations.CacheConcurrencyStrategy;

import com.jiwhiz.myhealth.common.domain.AbstractAuditingEntity;


@Data
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Builder
@Entity
@Table(name = "health_records")
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class HealthRecord extends AbstractAuditingEntity<HealthRecord> {
    @Column(name = "user_id", length = 255, nullable = false)
    private String userId;

    @Column(name = "rbc", length = 255, nullable = true)
    private String rbc;

    @Column(name = "hemoglobin", length = 255, nullable = true)
    private String hemoglobin;

    @Column(name = "hematocrit", length = 255, nullable = true)
    private String hematocrit;

    @Column(name = "tsh", length = 255, nullable = true)
    private String tsh;

    @Column(name = "glucose", length = 255, nullable = true)
    private String glucose;

    @Column(name = "cholesterol", length = 255, nullable = true)
    private String cholesterol;

    @Column(name = "mchc", length = 255, nullable = true)
    private String mchc;

    public HealthRecordDTO toDto() {
        return new HealthRecordDTO(userId, rbc, hemoglobin, hematocrit, tsh, glucose, cholesterol, mchc);
    }
}
