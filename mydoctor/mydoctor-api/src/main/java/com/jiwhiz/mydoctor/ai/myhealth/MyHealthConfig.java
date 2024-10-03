package com.jiwhiz.mydoctor.ai.myhealth;

import java.util.function.Function;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Description;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.web.reactive.function.client.WebClient;

import com.jiwhiz.mydoctor.common.ApplicationProperties;

@Configuration
public class MyHealthConfig {

    @Bean
    @Description("Get my health record")
    public Function<RecordRequest, RecordResponse> healthRecordFunction(
        final WebClient webClient,
        final OAuth2AuthorizedClientManager authorizedClientManager,
        final ApplicationProperties appProperties
    ) {
        return new MyHealthRecordService(appProperties, authorizedClientManager, webClient);
    }
}
