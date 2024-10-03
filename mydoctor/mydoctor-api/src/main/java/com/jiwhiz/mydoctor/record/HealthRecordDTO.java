package com.jiwhiz.mydoctor.record;

public record HealthRecordDTO(
    String userId,
    String rbc,
    String hemoglobin,
    String hematocrit,
    String tsh,
    String glucose,
    String cholesterol,
    String mchc
) {}
