package com.jiwhiz.myhealth.common;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.web.cors.CorsConfiguration;

import java.util.ArrayList;
import java.util.List;

@ConfigurationProperties(prefix = "app", ignoreUnknownFields = false)
@Getter
public class ApplicationProperties {

    private final CorsConfiguration cors = new CorsConfiguration();

    private final Security security = new Security();

    @Getter
    public static class Security {

        private String contentSecurityPolicy = "default-src 'self'; frame-src 'self' data:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://storage.googleapis.com; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self' data:";

        private final OAuth2 oauth2 = new OAuth2();

        @Getter
        @Setter
        public static class OAuth2 {
            private List<String> audience = new ArrayList<>();
        }
    }
}
