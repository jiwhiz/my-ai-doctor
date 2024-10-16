import Keycloak from 'keycloak-js';

// var keycloak = new Keycloak({
//     url: 'http://auth.myhealth:8090',
//     realm: 'myhealth-demo',
//     clientId: 'myhealth-ui',
// });


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
        realm: 'myhealth-demo',
        clientId: 'myhealth-ui',
    });

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

}