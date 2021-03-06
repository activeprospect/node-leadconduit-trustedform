const assert = require('chai').assert;
const helper = require('../lib/helpers');

describe('Helper functions', () => {

  describe('Fingerprinting', () => {

    it('should set summary to all matching', () => {
      const actual = helper.evalFingerprint({}, { matching: ['abc'], non_matching: [] });
      assert.equal(actual.fingerprints_summary, 'All Matched');
    });

    it('should set summary to some matching', () => {
      const actual = helper.evalFingerprint({}, { matching: ['abc'], non_matching: ['def'] });
      assert.equal(actual.fingerprints_summary, 'Some Matched');
    });

    it('should set summary to none matching', () => {
      const actual = helper.evalFingerprint({}, { matching: [], non_matching: ['def'] });
      assert.equal(actual.fingerprints_summary, 'None Matched');
    });

    it('should set summary to no data', () => {
      const actual = helper.evalFingerprint({}, { matching: [], non_matching: [] });
      assert.equal(actual.fingerprints_summary, 'No Fingerprinting Data');
    });

    it('should set matched flag for email', () => {
      const fingerprints = { matching: ['c4a8e7fe184993964ae81380e91579015306838a'], non_matching: [] };
      const actual = helper.evalFingerprint({ email: 'kelly@thethings.biz' }, fingerprints);
      assert.isTrue(actual.email_fingerprint_matched);
      assert.isUndefined(actual.phone_1_fingerprint_matched);
      assert.isUndefined(actual.phone_2_fingerprint_matched);
      assert.isUndefined(actual.phone_3_fingerprint_matched);
    });

    it('should set matched flag for phone_1', () => {
      const fingerprints = { matching: ['d511850d569bcd7802c30f54de34bb9f2b31eede'], non_matching: [] };
      const actual = helper.evalFingerprint({ phone_1: '5135556719' }, fingerprints);
      assert.isUndefined(actual.email_fingerprint_matched);
      assert.isTrue(actual.phone_1_fingerprint_matched);
      assert.isUndefined(actual.phone_2_fingerprint_matched);
      assert.isUndefined(actual.phone_3_fingerprint_matched);
    });

    it('should match one and not match another', () => {
      const fingerprints = { matching: ['c4a8e7fe184993964ae81380e91579015306838a'], non_matching: ['thiswillnotmatchsorry'] };
      const actual = helper.evalFingerprint({ email: 'kelly@thethings.biz',  phone_1: '5135556719' }, fingerprints);
      assert.isTrue(actual.email_fingerprint_matched);
      assert.isFalse(actual.phone_1_fingerprint_matched);
      assert.isUndefined(actual.phone_2_fingerprint_matched);
      assert.isUndefined(actual.phone_3_fingerprint_matched);
    });
  })

  describe('Cert URL validate', () => {

    it('should error on undefined cert url', () => {
      const error = helper.validate({lead: {}});
      assert.equal(error, 'TrustedForm cert URL must not be blank');
    });

    it('should error on null cert url', () => {
      const error = helper.validate({lead: { trustedform_cert_url: null }});
      assert.equal(error, 'TrustedForm cert URL must not be blank');
    });

    it('should error on invalid cert url', () => {
      const error = helper.validate({lead: { trustedform_cert_url: 'http://someothersite.com' }});
      assert.equal(error, 'TrustedForm cert URL must be valid');

      const error2 = helper.validate({lead: { trustedform_cert_url: 'KOWABUNGAhttps://cert.trustedform.com/' }});
      assert.equal(error2, 'TrustedForm cert URL must be valid');
    });

    it('should not error when cert url is valid', () => {
      const error = helper.validate({lead: { trustedform_cert_url: 'https://cert.trustedform.com/2605ec3a321e1b3a41addf0bba1213505ef57985' }});
      assert.isUndefined(error);

      const error2 = helper.validate({lead: { trustedform_cert_url: 'https://cert.trustedform.com/0.YpUzjEEpW3vIkuEJFst4gSDQ7KiFGLZGYkTwIMzRXt8TxcnRUnx3p1U34EWx6KUZ9hyJUuwVm11qoEodrSfsXYDLS7LDFWOyeuCP2MNCHdnAXYkG.IW3iXaUjponmuoB4HNdsWQ.H6cCZ53mOpSXUtUlpdwlWw' }});
      assert.isUndefined(error2);

    });

    it('should not error when cert url is http', () => {
      const error = helper.validate({lead: { trustedform_cert_url: 'http://cert.trustedform.com/2605ec3a321e1b3a41addf0bba1213505ef57985' }});
      assert.isUndefined(error);
    });


    it('should accept staging certs on staging', () => {
      process.env.NODE_ENV = 'staging';
      const error = helper.validate({lead: { trustedform_cert_url: 'http://cert.staging.trustedform.com/2605ec3a321e1b3a41addf0bba1213505ef57985' }});
      assert.isUndefined(error);
    });

    it('should not accept invalid certs on staging', () => {
      process.env.NODE_ENV = 'staging';
      const error = helper.validate({lead: { trustedform_cert_url: 'http://someothersite.com' }});
      assert.equal(error, 'TrustedForm cert URL must be valid');

      const error2 = helper.validate({lead: { trustedform_cert_url: 'KOWABUNGAhttps://cert.trustedform.com/' }});
      assert.equal(error2, 'TrustedForm cert URL must be valid');
    });

    it('should not accept staging certs on production', () => {
      const error = helper.validate({lead: { trustedform_cert_url: 'http://cert.staging.trustedform.com/2605ec3a321e1b3a41addf0bba1213505ef57985' }});
      assert.equal(error, 'TrustedForm cert URL must be valid');
    });

    it('should accept a production cert on staging', () => {
      process.env.NODE_ENV = 'staging';
      const error = helper.validate({lead: { trustedform_cert_url: 'https://cert.trustedform.com/2605ec3a321e1b3a41addf0bba1213505ef57985' }});
      assert.isUndefined(error);
    });
  });
});
