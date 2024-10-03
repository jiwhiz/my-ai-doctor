package com.jiwhiz.mydoctor.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.boot.autoconfigure.security.oauth2.resource.OAuth2ResourceServerProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.messaging.Message;
import org.springframework.messaging.simp.SimpMessageType;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.security.authorization.AuthorizationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.socket.EnableWebSocketSecurity;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtValidators;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.messaging.access.intercept.MessageMatcherDelegatingAuthorizationManager;
import org.springframework.security.web.SecurityFilterChain;

import com.jiwhiz.mydoctor.common.ApplicationProperties;
import com.jiwhiz.mydoctor.security.KeycloakJwtAuthenticationConverter;

@Configuration
@EnableWebSecurity
@EnableWebSocketSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
@Slf4j
public class SecurityConfig {

    private final ApplicationProperties appProperties;

    private final KeycloakJwtAuthenticationConverter keycloakJwtAuthenticationConverter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        // @formatter:off
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors((cors) -> cors
                .configurationSource(request -> appProperties.getCors())
            )
            .authorizeHttpRequests(authorize -> authorize
                .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()
                .requestMatchers("/swagger-ui/**").permitAll()
                .requestMatchers("/api-docs/**").permitAll()
                .requestMatchers("/ws/**").permitAll()
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2ResourceServer -> oauth2ResourceServer
                .jwt( jwt -> jwt.jwtAuthenticationConverter(keycloakJwtAuthenticationConverter) )
            )
            .oauth2Client(Customizer.withDefaults());
            ;
        // @formatter:on
        return http.build();

    }

    /**
     * Create an empty ChannelInterceptor for CSRF, so we can disable csrf in Websocket.
     * It will be used by WebSocketMessageBrokerSecurityConfiguration through @EnableWebSocketSecurity
     * @return
     */
    @Bean
    public ChannelInterceptor csrfChannelInterceptor() {
        return new ChannelInterceptor() {};
    }

    @Bean
    AuthorizationManager<Message<?>> messageAuthorizationManager(MessageMatcherDelegatingAuthorizationManager.Builder messages) {
        messages
                .simpTypeMatchers(SimpMessageType.CONNECT,
                        SimpMessageType.DISCONNECT, SimpMessageType.OTHER).permitAll()
                //.simpDestMatchers("/app/**").hasRole("USER")
                .anyMessage().permitAll()
                ;

        return messages.build();
    }

    @Bean
    public JwtDecoder jwtDecoder(OAuth2ResourceServerProperties oAuth2ResourceServerProperties) {
        NimbusJwtDecoder jwtDecoder = NimbusJwtDecoder.withJwkSetUri(oAuth2ResourceServerProperties.getJwt().getJwkSetUri()).build();
        jwtDecoder.setJwtValidator(JwtValidators.createDefaultWithIssuer(oAuth2ResourceServerProperties.getJwt().getIssuerUri()));
        return jwtDecoder;
    }
}

