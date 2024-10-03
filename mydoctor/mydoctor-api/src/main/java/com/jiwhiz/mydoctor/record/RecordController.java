package com.jiwhiz.mydoctor.record;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.annotation.RegisteredOAuth2AuthorizedClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

import com.jiwhiz.mydoctor.common.ApplicationProperties;
import com.jiwhiz.mydoctor.common.Constants;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;


@RestController
@RequestMapping(Constants.API_ENDPOINT_BASE)
@RequiredArgsConstructor
@Slf4j
public class RecordController {

    private final ApplicationProperties appProperties;

    private final WebClient webClient;

    @GetMapping("/records")
    public List<HealthRecordDTO> getHealthRecords(
        @RegisteredOAuth2AuthorizedClient("mydoctor-auth-client")
        OAuth2AuthorizedClient doctorAuthClient
    ) {
        String token = doctorAuthClient.getAccessToken().getTokenValue();
        log.debug("Exchanged access token is:\n {}\n", token);

        var result = webClient.get()
            .uri(appProperties.getMyHealth().getApiBaseUrl() + "/health-records")
            .headers((headers) -> headers.setBearerAuth(token))
            .retrieve()
            .bodyToMono(new ParameterizedTypeReference<List<HealthRecordDTO>>() {})
            .block()
            ;
        log.debug("Return result from MyHealth API Server: {}", result);
        return result;
    }
}
