(function () {
  function clearMatomoCookies() {
    var expires = 'expires=Thu, 01 Jan 1970 00:00:00 GMT';

    document.cookie.split(';').forEach(function (entry) {
      var name = entry.split('=')[0].trim();
      if (/^(?:_pk_|mtm_)/i.test(name)) {
        document.cookie = name + '=; ' + expires + '; path=/';
      }
    });
  }

  function revokeMatomoConsent() {
    window._paq = window._paq || [];
    window._paq.push(['forgetCookieConsentGiven']);
    window._paq.push(['deleteCookies']);
    clearMatomoCookies();
  }

  function initCookieConsentBanners() {
    document.querySelectorAll('[data-cookie-consent-banner]').forEach(function (banner) {
      if (banner.dataset.cookieConsentInitialized === 'true') {
        return;
      }

      banner.dataset.cookieConsentInitialized = 'true';
      var preference = banner.querySelector('[data-cookie-consent-preference="analytics"]');
      var preferencesForm = banner.querySelector('[data-cookie-consent-form="preferences"]');
      var analyticsInput = banner.querySelector('[data-cookie-consent-analytics-input]');

      if (preference && preferencesForm && analyticsInput) {
        preferencesForm.addEventListener('submit', function () {
          analyticsInput.value = preference.checked ? 'true' : 'false';
        });
      }

      banner.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function () {
          var input = form.querySelector('[name="analytics_consent"]');
          if (input && input.value === 'false') {
            revokeMatomoConsent();
          }
        });
      });
    });
  }

  document.addEventListener('DOMContentLoaded', initCookieConsentBanners);
  document.addEventListener('turbo:load', initCookieConsentBanners);
})();
