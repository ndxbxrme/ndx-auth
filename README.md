# ndx-auth
### oauth2 user authentication for [ndx-framework](https://github.com/ndxbxrme/ndx-framework)
install with  
`npm install --save ndx-auth`
### what it does
ndx-auth adds a `post` route `/auth/token` to your app, calling this with a valid base64 encoded Basic Authentication header will provide an accessToken which can then be used to connect to the app.
### Example
`src/server/app.coffee`
```coffeescript
require 'ndx-server'
.config
  database: 'db'
.use 'ndx-cors'
.use 'ndx-user-roles'
.use 'ndx-auth'
.use 'ndx-superadmin'
.controller (ndx) ->
  ndx.app.get '/api/protected', ndx.authenticate('superadmin'), (req, res, next) ->
    res.json res.user
.start()
```
`connector.coffee`
```coffeescript
$scope.username = 'superadmin@admin.com'
$scope.password = 'admin'
user = "#{$scope.username}:#{$scope.password}"
$http.defaults.headers.common['Authorization'] = 'Basic ' + base64.encode(user)
$http.post 'http://localhost:3000/auth/token'
.then (response) ->
  if response.data and response.data.accessToken
    $http.defaults.headers.common['Authorization'] = 'Bearer ' + response.data.accessToken
    #all api calls will now be authenticated
    $http.get 'http://localhost:3000/api/protected'
    .then (response) ->
      console.log response.data
```