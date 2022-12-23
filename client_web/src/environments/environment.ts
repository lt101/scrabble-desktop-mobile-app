// This file can be replaced during build by using the `fileReplacements` array.
// `ng build` replaces `environment.ts` with `environment.prod.ts`.
// The list of file replacements can be found in `angular.json`.

export const environment = {
    firebase: {
        projectId: 'projet3-equipe106',
        appId: '1:1059383809484:web:52c5e9e3c17bf01673b969',
        databaseURL: 'https://projet3-equipe106-default-rtdb.firebaseio.com',
        storageBucket: 'projet3-equipe106.appspot.com',
        locationId: 'us-central',
        apiKey: 'AIzaSyBY5NdcB3LtwHKHNnf-e5TIygJ6BKSVqb4',
        authDomain: 'projet3-equipe106.firebaseapp.com',
        messagingSenderId: '1059383809484',
    },
    production: false,
    serverUrl: 'http://ec2-35-182-33-161.ca-central-1.compute.amazonaws.com:3000',
    socketUrl: 'http://ec2-35-182-33-161.ca-central-1.compute.amazonaws.com:3000',
};

/*
 * For easier debugging in development mode, you can import the following file
 * to ignore zone related error stack frames such as `zone.run`, `zoneDelegate.invokeTask`.
 *
 * This import should be commented out in production mode because it will have a negative impact
 * on performance if an error is thrown.
 */
// import 'zone.js/plugins/zone-error';  // Included with Angular CLI.
