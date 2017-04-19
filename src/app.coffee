'use strict'

module.exports = (ndx) ->
  ndx.app.post '/auth/token', (req, res) ->
    token = ''
    if req.headers and req.headers.authorization
      parts = req.headers.authorization.split ' '
      if parts.length is 2
        scheme = parts[0]
        credentials = parts[1]
        if /^Basic$/i.test scheme
          decrypted = new Buffer credentials, 'base64'
          .toString 'utf8'
          cparts = decrypted.split ':'
          if cparts.length is 2
            ndx.database.select ndx.settings.USER_TABLE, 
              where:
                local:
                  email: cparts[0]
            , (users) ->
              if users and users.length
                if ndx.validPassword cparts[1], users[0].local.password
                  token = ndx.generateToken users[0][ndx.settings.AUTO_ID], req.ip
            , true
    if token
      res.json
        accessToken: token
    else
      throw ndx.UNAUTHORIZED
  ndx.app.post '/api/generate_cors_token', ndx.authenticate('superadmin'), (req, res, next) ->
    newUser =
      email: req.body.name
      displayName: req.body.name
      local:
        email: req.body.name
        password: ''
    newUser[ndx.settings.AUTO_ID] = ndx.generateID()
    ndx.database.insert ndx.settings.USER_TABLE, newUser, null, true
    res.json
      token: ndx.generateToken newUser[ndx.settings.AUTO_ID], '', req.body.hours, true
  ndx.app.post '/api/revoke_cors_token', ndx.authenticate('superadmin'), (req, res, next) ->
    where = {}
    if req.body.name
      where.name = req.body.name
    if req.body.id
      where[ndx.settings.AUTO_ID] = req.body.id
    if req.body.token
      where[ndx.settings.AUTO_ID] = ndx.parseToken req.body.token
    ndx.database.delete ndx.settings.USER_TABLE, where
    res.end 'OK'