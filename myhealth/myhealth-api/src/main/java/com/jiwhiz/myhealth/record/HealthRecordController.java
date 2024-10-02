package com.jiwhiz.myhealth.record;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jiwhiz.myhealth.common.Constants;
import com.jiwhiz.myhealth.security.SecurityUtils;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@RequestMapping(Constants.API_ENDPOINT_BASE)
@RequiredArgsConstructor
@Slf4j
public class HealthRecordController {

    private final HealthRecordRepository healthRecordRepository;

    @GetMapping("/health-records")
    public ResponseEntity<List<HealthRecordDTO>> getUserHealthRecords() {
        return SecurityUtils.getCurrentLoginUserEmail()
            .map( email ->
                    this.healthRecordRepository
                        .findByUserId(email)
                        .stream()
                        .map(p -> p.toDto())
                        .collect(Collectors.toList())
            )
            .map( pList -> ResponseEntity.ok().body(pList) )
            .orElse(ResponseEntity.ok().body(Collections.emptyList()))
            ;
    }
}
