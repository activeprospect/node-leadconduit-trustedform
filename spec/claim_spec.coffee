assert = require('chai').assert
integration = require('../src/claim')

describe 'Claim Request', ->
  request     = null
  fullRequest = null
  claimId     = '533c80270218239ec3000012'
  apiKey      = 'c9351ff49a8e38a23493c6b7328c7629'
  baseUrl     = "https://cert.trustedform.com/#{claimId}"

  baseRequest = (extraKeys) ->
    hash =
      claimId: claimId
      apiKey:  apiKey

    for key, value of extraKeys
      hash[key] = value

    hash

  beforeEach ->
    request = integration.request fullRequest

  context 'without parameters', ->
    before ->
      fullRequest = baseRequest()

    it 'uses the claim id in the url', ->
      assert.equal baseUrl, request.url

    it 'uses the apiKey in the auth header', ->
      assert.equal 'Basic QVBJOmM5MzUxZmY0OWE4ZTM4YTIzNDkzYzZiNzMyOGM3NjI5', request.headers.Authorization

    it 'is a POST request type', ->
      assert.equal 'POST', request.method

    it 'accepts JSON', ->
      assert.equal 'application/json', request.headers.Accepts

  context 'with a reference parameter', ->
    reference = 'my lead identifier'

    before ->
      fullRequest = baseRequest reference: reference

    it 'includes the parameter in the URL', ->
      assert.equal "#{baseUrl}?reference=#{encodeURIComponent reference}", request.url

  context 'with a vendor parameter', ->
    vendor = 'pamperseller'

    before ->
      fullRequest = baseRequest vendor: vendor

    it 'includes the parameter in te URL', ->
      assert.equal "#{baseUrl}?vendor=#{vendor}", request.url

  context 'with a scan parameter', ->
    scan = 'string'

    before ->
      fullRequest = baseRequest scan: scan

    it 'includes the parameter in the URL', ->
      assert.equal "#{baseUrl}?scan=#{scan}", request.url

  context 'with multiple scan parameters', ->
    first = 'first'
    last  = 'last'

    before ->
      fullRequest = baseRequest scan: [ first, last ]

    it 'includes the parameter in the URL', ->
      assert.equal "#{baseUrl}?scan=#{first}&scan=#{last}", request.url

  context 'with a scanAbsence parameter', ->
    scan = 'string'

    before ->
      fullRequest = baseRequest scanAbsence: scan

    it 'includes the parameter in the URL', ->
      assert.equal "#{baseUrl}?scan!=#{scan}", request.url

  context 'with multiple scanAbsence parameters', ->
    first = 'first'
    last  = 'last'

    before ->
      fullRequest = baseRequest scanAbsence: [ first, last ]

    it 'includes the parameters in the URL', ->
      assert.equal "#{baseUrl}?scan!=#{first}&scan!=#{last}", request.url


  context 'with multiple parameters', ->
    reference = 'fooreference'
    vendor    = 'myvendor'

    before ->
      fullRequest = baseRequest vendor: vendor, reference: reference

    it 'includes the parameters in the URL', ->
      assert.equal "#{baseUrl}?reference=#{reference}&vendor=#{vendor}", request.url

  context 'with fingerprint parameters', ->
    fingerprint = 'touch'

    before ->
      fullRequest = baseRequest fingerprint: fingerprint

    it 'includes the parameter in the url', ->
      assert.equal "#{baseUrl}?fingerprint=#{fingerprint}", request.url

  context 'with multiple fingerprint parameters', ->
    first = 'first'
    last  = 'last'

    before ->
      fullRequest = baseRequest fingerprint: [ first, last ]

    it 'includes the parameters in the url', ->
      assert.equal "#{baseUrl}?fingerprint=#{first}&fingerprint=#{last}", request.url

describe 'Claim Response', ->
  it 'parses JSON body', ->
    vars = {}
    req  = {}
    res  =
      status: 201,
      headers:
        'Content-Type': 'application/json'
      body: """
            {
              "cert": {
                "browser": "Chrome 33.0.1750",
                "claims": [
                  {
                    "created_at": "2014-04-02T21:24:55Z",
                    "expires_at": "2019-04-01T21:24:55Z",
                    "fingerprints": {
                      "matching": [],
                      "non_matching": []
                    },
                    "id": "533c80270218239ec3000012",
                    "page_id": "533c76bd0218239ec3000007",
                    "reference": null,
                    "scans": null,
                    "vendor": null,
                    "warnings": []
                  }
                ],
                "created_at": "2014-04-02T21:24:22Z",
                "expires_at": "2014-04-05T21:24:22Z",
                "framed": false,
                "geo": {
                  "city": "Austin",
                  "country_code": "US",
                  "lat": 30.2966,
                  "lon": -97.7663,
                  "postal_code": "78703",
                  "state": "TX",
                  "time_zone": "America/Chicago"
                },
                "ip": "127.0.0.1",
                "location": "http://localhost:81/leadconduit_iframe.html",
                "operating_system": "Mac OS X 10.9.2",
                "parent_location": null,
                "snapshot_url": "http://snapshots.trustedform.dev/0dcf20941b6b4f196331ff7ae1ca534befa269dd/index.html",
                "token": "0dcf20941b6b4f196331ff7ae1ca534befa269dd",
                "user_agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36"
              },
              "created_at": "2014-04-02T21:24:55Z",
              "expires_at": "2019-04-01T21:24:55Z",
              "fingerprints": {
                "matching": [],
                "non_matching": []
              },
              "id": "533c80270218239ec3000012",
              "page_id": "533c76bd0218239ec3000007",
              "reference": null,
              "scans": null,
              "vendor": null,
              "warnings": []
            }
            """

    expected =
      outcome: 'success'
      cert:
        browser: "Chrome 33.0.1750",
        claims: [
          created_at: "2014-04-02T21:24:55Z",
          expires_at: "2019-04-01T21:24:55Z",
          fingerprints:
            matching: [],
            non_matching: []
          id: "533c80270218239ec3000012",
          page_id: "533c76bd0218239ec3000007",
          reference: null,
          scans: null,
          vendor: null,
          warnings: []
        ],
        created_at: "2014-04-02T21:24:22Z",
        expires_at: "2014-04-05T21:24:22Z",
        framed: false,
        geo:
          city: "Austin",
          country_code: "US",
          lat: 30.2966,
          lon: -97.7663,
          postal_code: "78703",
          state: "TX",
          time_zone: "America/Chicago"
        ip: "127.0.0.1",
        location: "http://localhost:81/leadconduit_iframe.html",
        operating_system: "Mac OS X 10.9.2",
        parent_location: null,
        snapshot_url: "http://snapshots.trustedform.dev/0dcf20941b6b4f196331ff7ae1ca534befa269dd/index.html",
        token: "0dcf20941b6b4f196331ff7ae1ca534befa269dd",
        user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36"
      created_at: "2014-04-02T21:24:55Z",
      expires_at: "2019-04-01T21:24:55Z",
      fingerprints:
        matching: [],
        non_matching: []
      id: "533c80270218239ec3000012",
      page_id: "533c76bd0218239ec3000007",
      reference: null,
      scans: null,
      vendor: null,
      warnings: []

    response = integration.response vars, req, res
    assert.deepEqual expected, response

  it 'returns an error on non-201 response status', ->
    vars = {}
    req  = {}
    res  =
      status: 404
      headers:
        'Content-Type': 'application/json'
      body: """
            {
              "message": "certificate not found"
            }
            """
    expected =
      outcome: 'error'
      reason:  'TrustedForm error - certificate not found (404)'
    response = integration.response(vars, req, res)
    assert.deepEqual expected, response
