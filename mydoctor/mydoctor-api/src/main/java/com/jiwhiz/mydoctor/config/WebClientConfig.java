package com.jiwhiz.mydoctor.config;

import java.util.function.Function;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.convert.converter.Converter;
import org.springframework.http.RequestEntity;
import org.springframework.security.oauth2.client.AuthorizedClientServiceOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.OAuth2AuthorizationContext;
import org.springframework.security.oauth2.client.OAuth2AuthorizeRequest;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClient;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientProvider;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientProviderBuilder;
import org.springframework.security.oauth2.client.OAuth2AuthorizedClientService;
import org.springframework.security.oauth2.client.TokenExchangeOAuth2AuthorizedClientProvider;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
import org.springframework.security.oauth2.client.endpoint.DefaultTokenExchangeTokenResponseClient;
import org.springframework.security.oauth2.client.endpoint.TokenExchangeGrantRequest;
import org.springframework.security.oauth2.client.endpoint.TokenExchangeGrantRequestEntityConverter;
import org.springframework.security.oauth2.client.registration.ClientRegistrationRepository;
import org.springframework.security.oauth2.client.web.DefaultOAuth2AuthorizedClientManager;
import org.springframework.security.oauth2.client.web.OAuth2AuthorizedClientRepository;
import org.springframework.security.oauth2.client.web.reactive.function.client.ServletOAuth2AuthorizedClientExchangeFilterFunction;
import org.springframework.security.oauth2.core.OAuth2AccessToken;
import org.springframework.security.oauth2.core.OAuth2AccessToken.TokenType;
import org.springframework.security.oauth2.core.OAuth2Token;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.util.MultiValueMap;
import org.springframework.web.reactive.function.client.WebClient;

import lombok.extern.slf4j.Slf4j;

@Configuration
@Slf4j
public class WebClientConfig {

    OAuth2AuthorizedClientProvider tokenExchange(
        ClientRegistrationRepository clientRegistrationRepository,
        OAuth2AuthorizedClientRepository authorizedClientRepository
    ) {
        // This OAuth2AuthorizedClientManager is used for resolving the current
        // user's access token.
        OAuth2AuthorizedClientManager authorizedClientManager =
                new DefaultOAuth2AuthorizedClientManager(
                        clientRegistrationRepository, authorizedClientRepository);
        Function<OAuth2AuthorizationContext, OAuth2Token> subjectResolver = (context) -> {
            if (context.getPrincipal() instanceof OAuth2AuthenticationToken oauthAuthenticationToken) {
                // Get the current user's client registration id
                String clientRegistrationId = oauthAuthenticationToken.getAuthorizedClientRegistrationId();
                log.debug("==>subjectResolver for clientRegistrationId {}", clientRegistrationId);

                OAuth2AuthorizeRequest authorizeRequest =
                        OAuth2AuthorizeRequest.withClientRegistrationId(clientRegistrationId)
                                .principal(context.getPrincipal())
                                .build();
                OAuth2AuthorizedClient authorizedClient = authorizedClientManager.authorize(authorizeRequest);

                OAuth2AccessToken token = authorizedClient.getAccessToken();
                log.debug("Get Access Token for current user {}: {}", context.getPrincipal(), token.getTokenValue());
                return token;
            }
            else if (context.getPrincipal() instanceof JwtAuthenticationToken jwtAuthenticationToken) {
                Jwt jwt = jwtAuthenticationToken.getToken();
                OAuth2AccessToken token = new OAuth2AccessToken(TokenType.BEARER, jwt.getTokenValue(), jwt.getIssuedAt(), jwt.getExpiresAt());
                log.debug("Get Access Token for current user from JwtAuthenticationToken: {}", token.getTokenValue());
                return token;
            }

            throw new RuntimeException("Cannot resolve subject token with context principal " + context.getPrincipal() );
        };

        Converter<TokenExchangeGrantRequest, RequestEntity<?>> requestEntityConverter = new TokenExchangeGrantRequestEntityConverter() {
            @Override
	        protected MultiValueMap<String, String> createParameters(TokenExchangeGrantRequest grantRequest) {
                MultiValueMap<String, String> parameters = super.createParameters(grantRequest);
                parameters.add("requested_issuer", "myhealth-keycloak-oidc");
                return parameters;
            }
        };
        DefaultTokenExchangeTokenResponseClient accessTokenResponseClient = new DefaultTokenExchangeTokenResponseClient();
        accessTokenResponseClient.setRequestEntityConverter(requestEntityConverter);

        TokenExchangeOAuth2AuthorizedClientProvider authorizedClientProvider =
                new TokenExchangeOAuth2AuthorizedClientProvider();
        authorizedClientProvider.setSubjectTokenResolver(subjectResolver);
        authorizedClientProvider.setAccessTokenResponseClient(accessTokenResponseClient);

        return authorizedClientProvider;
    }

    @Bean
    public OAuth2AuthorizedClientManager authorizedClientManager(
            ClientRegistrationRepository clientRegistrationRepository,
            OAuth2AuthorizedClientService clientService,
            OAuth2AuthorizedClientRepository authorizedClientRepository) {

        OAuth2AuthorizedClientProvider authorizedClientProvider =
                OAuth2AuthorizedClientProviderBuilder.builder()
                        .refreshToken()
                        .clientCredentials()
                        .provider(tokenExchange(clientRegistrationRepository, authorizedClientRepository))
                        .build();

        AuthorizedClientServiceOAuth2AuthorizedClientManager authorizedClientManager =
                new AuthorizedClientServiceOAuth2AuthorizedClientManager(clientRegistrationRepository, clientService);

        authorizedClientManager.setAuthorizedClientProvider(authorizedClientProvider);

        return authorizedClientManager;
    }

    @Bean
    WebClient webClient(OAuth2AuthorizedClientManager authorizedClientManager) {
        ServletOAuth2AuthorizedClientExchangeFilterFunction oauth2Client =
                new ServletOAuth2AuthorizedClientExchangeFilterFunction(authorizedClientManager);
        oauth2Client.setDefaultClientRegistrationId("myhealth-auth-client");

        return WebClient.builder()
                .apply(oauth2Client.oauth2Configuration())
                .build();
    }
}

