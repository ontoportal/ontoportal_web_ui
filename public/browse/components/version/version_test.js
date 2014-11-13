'use strict';

describe('FacetedBrowsing.version module', function() {
  beforeEach(module('FacetedBrowsing.version'));

  describe('version service', function() {
    it('should return current version', inject(function(version) {
      expect(version).toEqual('0.1');
    }));
  });
});
