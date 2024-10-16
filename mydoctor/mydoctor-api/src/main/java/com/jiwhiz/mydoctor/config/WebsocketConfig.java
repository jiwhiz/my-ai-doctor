package com.jiwhiz.mydoctor.config;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import java.util.List;

import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.lang.NonNull;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.StompWebSocketEndpointRegistration;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import com.jiwhiz.mydoctor.common.ApplicationProperties;
import com.jiwhiz.mydoctor.security.KeycloakJwtAuthenticationConverter;

@Configuration
@EnableWebSocketMessageBroker
@Order(Ordered.HIGHEST_PRECEDENCE + 99)
@RequiredArgsConstructor
@Slf4j
public class WebsocketConfig implements WebSocketMessageBrokerConfigurer {

    private final ApplicationProperties appProperties;

    private final JwtDecoder jwtDecoder;

    private final KeycloakJwtAuthenticationConverter keycloakJwtAuthenticationConverter;

    @Override
    public void registerStompEndpoints(@NonNull StompEndpointRegistry registry) {
        StompWebSocketEndpointRegistration reg = registry.addEndpoint("/ws");

        List<String> allowedOrigins = appProperties.getCors().getAllowedOrigins();
        if (allowedOrigins != null){
            reg.setAllowedOrigins(allowedOrigins.toArray(new String[allowedOrigins.size()])) ;
        }
    }

    @Override
    public void configureMessageBroker(@NonNull MessageBrokerRegistry registry) {
        registry.enableSimpleBroker("/queue");
        registry.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void configureClientInboundChannel(@NonNull ChannelRegistration registration) {
        registration.interceptors(connectAuthInterceptor());
    }

    public ChannelInterceptor connectAuthInterceptor() {
        return new ChannelInterceptor() {
            @Override
            public Message<?> preSend(@NonNull Message<?> message, @NonNull MessageChannel channel) {
                StompHeaderAccessor accessor =
                        MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);
                log.info("ChannelInterceptor.preSend() - Headers: {}", accessor);

                assert accessor != null;
                if (StompCommand.CONNECT.equals(accessor.getCommand())) {
                    String authorizationHeader = accessor.getFirstNativeHeader("Authorization");
                    assert authorizationHeader != null;
                    String token = authorizationHeader.substring(7);
                    Jwt jwt = jwtDecoder.decode(token);
                    Authentication auth = keycloakJwtAuthenticationConverter.convert(jwt);
                    log.info("Chat client connect with principal `{}` and authorities `{}`",
                        auth.getPrincipal(), auth.getAuthorities());

                    SecurityContextHolder.getContext().setAuthentication(auth);
                    accessor.setUser(auth);
                }

                return message;
            }
        };
    }
}

