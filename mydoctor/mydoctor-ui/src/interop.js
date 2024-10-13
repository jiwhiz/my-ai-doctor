import "./styles.css";
import Keycloak from 'keycloak-js';
import { Client } from '@stomp/stompjs';


// This is called BEFORE your Elm app starts up
// 
// The value returned here will be passed as flags 
// into your `Shared.init` function.
export const flags = ({ env }) => {
    return {
        apiBaseUrl : env.API_BASE_URL
    }
}

// This is called AFTER your Elm app starts up
//
// Here you can work with `app.ports` to send messages
// to your Elm application, or subscribe to incoming
// messages from Elm
export const onReady = ({ app, env }) => {
    console.log("onReady");
    console.log(env);

    var keycloak = new Keycloak({
        url: env.AUTH_SERVER_URL,
        realm: 'mydoctor-demo',
        clientId: 'mydoctor-ui',
    });
    
    var stompClient = new Client({
        brokerURL: env.WS_BASE_URL,
    
        debug: function (str) {
            console.log('Stomp:' + str);
        },
    
        reconnectDelay: 5000,
        heartbeatIncoming: 4000,
        heartbeatOutgoing: 4000,
        onStompError: function (frame) {
            console.log('Broker reported error: ' + frame.headers['message']);
            console.log('Additional details: ' + frame.body);
        }
    })

    // Initialize Keycloak
    keycloak
    .init({
        onLoad: 'check-sso',
        silentCheckSsoRedirectUri:
            window.location.origin + '/assets/silent-check-sso.html'
    })
    .then(function (result) {
        console.log("After init: " + result);
        if (keycloak.authenticated) {
            console.log("Authenticated. Send the access token back to Elm");
            app.ports.onLoginSuccess.send(keycloak.token);
            localStorage.setItem('token', keycloak.token);

            stompClient.connectHeaders = {
                Authorization: 'Bearer ' + keycloak.token
            };

            stompClient.onConnect = (frame) => {
                console.log('call onConnect()');
                stompClient.subscribe('/user/queue',
                    (message) => {
                        console.log('got message: ' + message);
                        if (message && message.body) {
                        const payload = JSON.parse(message.body);
                        console.log(payload);
                        app.ports.messageReceiver.send(payload.content);
                        }
                    }
                )
            }
            stompClient.activate();
        }
    });

    if (app.ports && app.ports.login && app.ports.logout) {

        app.ports.login.subscribe( () => {
            console.log("Call login()");
            keycloak
            .login()
            .then(function () {
                console.log("After login: " + keycloak.authenticated);
                if (keycloak.authenticated) {
                    app.ports.onLoginSuccess.send(keycloak.token);
                }
            })
            .catch(function () {
                console.error('Failed to login Keycloak');
            });
        })
    
        app.ports.logout.subscribe( () => {
            console.log("Call logout()");
            keycloak
            .logout()
            .then(function () {
                console.log("After logout: " + keycloak.authenticated);
            })
            .catch(function (err) {
                console.error('Failed to logout Keycloak');
                console.error(err);
            });
        })
    }

    if (app.ports && app.ports.sendMessage) {
        app.ports.sendMessage.subscribe( function (message) {
            const payload = {content: message};
            stompClient.publish({
                destination: '/app/chat',
                body: JSON.stringify(payload)
              })
        })
    }
}