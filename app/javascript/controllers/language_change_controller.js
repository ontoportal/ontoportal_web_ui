import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="language-change"
export default class extends Controller {


  connect() {
    // can be used for debugging
    // console.log(this.element.value);
    jQuery(document).data().bp.lang = this.element.value;
  }

  dispatchLangChangeEvent() {
    jQuery(document).data().bp.lang = this.element.value;

    var url = window.location.href;
    url = this.removeURLParameter(url, 'lang');
    if (url.indexOf('?') > -1) {
      url += '&lang=' + this.element.value;
    } else {
      url += '?lang=' + this.element.value;
    }
    jQuery.blockUI({ message: '<h1>Switching language...</h1>', showOverlay: true });
    window.location.href = url;
  }

  removeURLParameter(url, parameter) {
    //prefer to use l.search if you have a location/link object
    var urlparts = url.split('?');

    if (urlparts.length >= 2) {
      var prefix = encodeURIComponent(parameter) + '=';
      var pars = urlparts[1].split(/[&;]/g);

      //reverse iteration as may be destructive
      for (var i = pars.length; i-- > 0;) {
        //idiom for string.startsWith
        if (pars[i].lastIndexOf(prefix, 0) !== -1) {
          pars.splice(i, 1);
        }
      }
      return urlparts[0] + (pars.length > 0 ? '?' + pars.join('&') : '');
    }
    return url;
  }

}
