baseUrl = 'https://cert.trustedform.com'

#
# Request Function -------------------------------------------------------
#

paramString = (vars) ->
  string = ''
  params = []

  if vars.reference?
    params.push "reference=#{encodeURIComponent vars.reference}"

  if vars.vendor?
    params.push "vendor=#{encodeURIComponent vars.vendor}"

  if vars.scans?
    params.push "scan=#{encodeURIComponent scan}" for scan in vars.scans

  if vars.scanAbsences?
    params.push "scan!=#{encodeURIComponent scan}" for scan in vars.scanAbsences

  if vars.fingerprints?
    params.push "fingerprint=#{fingerprint}" for fingerprint in vars.fingerprints

  if params.length
    string = "?#{params.join '&'}"

  string

request = (vars) ->
  {
    url:     "#{baseUrl}/#{vars.claimId}#{paramString(vars)}",
    method:  'POST',
    headers: {
      # TODO: verify that we won't communicate via x-www-form-urlencoded
      Accepts:       'application/json',
      Authorization: encodeAuthentication vars.apiKey
    }
  }

request.variables = ->
  [
    { name: 'apiKey', type: 'string', required: true, description: 'TrustedForm API Key' },
    { name: 'claimId', type: 'string', required: true, description: 'Claim ID' }
  ]

encodeAuthentication = (apiKey) ->
  'Basic ' + new Buffer('API' + ':' + apiKey).toString('base64')

#
# Response Function ------------------------------------------------------
#

response = (vars, req, res) ->
  event = JSON.parse(res.body)

  if res.status == 201
    event['outcome'] = 'success'
    event
  else
    { outcome: 'error', reason: "TrustedForm error - #{event.message} (#{res.status})" }

response.variables = ->
  [
  ]

#
# Exports ----------------------------------------------------------------
#

module.exports =
  request:  request,
  response: response
