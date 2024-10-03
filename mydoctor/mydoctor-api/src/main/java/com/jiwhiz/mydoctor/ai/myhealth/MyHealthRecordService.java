package com.jiwhiz.mydoctor.ai.myhealth;

import java.util.function.Function;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.web.reactive.function.client.WebClient;

import com.jiwhiz.mydoctor.common.ApplicationProperties;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RequiredArgsConstructor
@Slf4j
public class MyHealthRecordService implements Function<RecordRequest, RecordResponse> {

    private final ApplicationProperties appProperties;

    private final OAuth2AuthorizedClientManager authorizedClientManager;

    private final WebClient webClient;

    @Override
    public RecordResponse apply(RecordRequest t) {
        log.debug("AI calls function to get health record data ");

        try {
            OAuth2AuthorizeRequest authorizeRequest =
                OAuth2AuthorizeRequest
                    .withClientRegistrationId("mydoctor-auth-client")
                    .principal(SecurityContextHolder.getContext().getAuthentication())
                    .build();
            OAuth2AuthorizedClient authClient = authorizedClientManager.authorize(authorizeRequest);
            String token = authClient.getAccessToken().getTokenValue();
            log.debug("Exchanged access token is:\n {}\n", token);

            String result = webClient.get()
                .uri(appProperties.getMyHealth().getApiBaseUrl() + "/health-records")
                .headers((headers) -> headers.setBearerAuth(token))
                .retrieve()
                .bodyToMono(String.class)
                .block()
                ;

            log.debug("Return result from MyHealth API Server: {}", result);
            return new RecordResponse(result);
        } catch (Exception ex) {
            log.warn("Got exception when call MyHealth API.", ex);
            return new RecordResponse("Got error from API server " + ex.getMessage());
        }
    }


}
