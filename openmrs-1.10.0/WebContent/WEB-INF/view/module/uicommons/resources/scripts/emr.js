var emr = (function($) {

    var accentMap = {
        "ä": "a", "á": "a", "à": "a", "â": "a", "ã": "a",
        "Ä": "A", "Á": "A", "À": "A", "Â": "A", "Ã": "A",
        "é": "e", "è": "e", "ê": "e", "ë": "e", "œ": "e","æ":"e",
        "É": "E", "È": "E", "Ê": "E", "Ë": "E",
        "ï": "i", "ì": "i", "í": "i", "î": "i",
        "Ï": "I", "Ì": "I", "Í": "I", "Î": "I",
        "ö": "o", "ó": "o", "ò": "o", "ô": "o", "õ": "o",
        "Ö": "O", "Ó": "O", "Ò": "O", "Ô": "O", "Õ": "O",
        "ü": "u", "ú": "u", "ù": "u", "û": "u",
        "Ü": "U", "Ú": "U", "Ù": "U", "Û": "U",
        "ÿ": "y", "Ÿ": "Y", "ñ": "n", "Ñ": "N",
        "ç": "c", "Ç": "C", "ß": "s"
    };

    var toQueryString = function(options) {
        var ret = "?";
        if (options) {
            for (key in options) {
                var val = options[key];
                if ($.isArray(val)) {
                    for (ind in val) {
                        ret += key + '=' + encodeURIComponent(val[ind]) + '&';
                    }
                } else {
                    ret += key + '=' + encodeURIComponent(val) + '&';
                }
            }
        }
        return ret;
    };

    var requireOptions = function() {
        var opts = arguments[0];
        for (var i = 1; i < arguments.length; ++i) {
            if (!opts[arguments[i]]) {
                throw "Missing option: " + arguments[i];
            }
        }
    };

    var jqObject = $();

    return {

        // just used in testing so we can replace the instance with a mock or spy as needed
        setJqObject: function(jqueryInstanceToSet)  {
            jqObject = jqueryInstanceToSet;
        },

        message: function(code, defaultText) {
            if (window.messages) {
                var translated = window.messages[code];
                return translated ? translated : (defaultText ? defaultText : code);
            } else {
                return defaultText ? defaultText : code;
            }
        },

        navigateTo: function(opts) {
            var url = opts.url;
            if (opts.applicationUrl) {
                url = '/' + OPENMRS_CONTEXT_PATH + '/' + opts.applicationUrl;
            }
            if (opts.page) {
                var provider = opts.provider;
                if (provider == null) {
                    provider = "*"
                }
                url = this.pageLink(provider, opts.page, opts.query);
            }
            location.href = url;
        },

        pageLink: function(providerName, pageName, options) {
            var ret = '/' + OPENMRS_CONTEXT_PATH + '/' + providerName + '/' + pageName + '.page';
            return ret + toQueryString(options);
        },

        resourceLink: function(providerName, resourceName) {
            if (providerName == null)
                providerName = '*';
            return '/' + OPENMRS_CONTEXT_PATH + '/ms/uiframework/resource/' + providerName + '/' + resourceName;
        },

        fragmentActionLink: function(providerName, fragmentName, actionName, options) {
            var ret = '/' + OPENMRS_CONTEXT_PATH + '/' + providerName + '/' + fragmentName + '/' + actionName + '.action';
            return ret += toQueryString(options);
        },

        getFragmentActionWithCallback: function(providerName, fragmentName, actionName, options, callback, errorCallback) {
            if (!errorCallback) {
                errorCallback = function(xhr) {
                    emr.handleError(xhr);
                };
            }
            var url = this.fragmentActionLink(providerName, fragmentName, actionName, options);
            $.getJSON(url).success(callback).error(errorCallback);
        },

        /*
         * opts should contain:
         *   provider (defaults to '*')
         *   fragment
         *   action
         *   query, e.g. { q: "bob", checkedInAt: 5 }
         *   resultTarget e.g. '#search-results'
         *   resultTemplate (should be an underscore template)
         */
        ajaxSearch: function(opts) {
            var provider = opts.provider;
            if (!provider) {
                provider = '*';
            }
            var url = this.fragmentActionLink(provider, opts.fragment, opts.action);
            var target = $(opts.resultTarget);
            $.getJSON(url, opts.query)
                .success(function(data) {
                    target.html('');
                    jq.each(data, function(i, result) {
                        jq(opts.resultTemplate(result)).appendTo(target);
                    });
                })
                .error(function(err) {
                    emr.errorMessage(err);
                });
        },

        successMessage: function(message) {
            jqObject.toastmessage( 'showToast', { type: 'success',
                                              position: 'top-right',
                                              text:  emr.message(message) } );
        },

        errorMessage: function(message) {
            jqObject.toastmessage( 'showToast', { type: 'error',
                                              position: 'top-right',
                                              text:  emr.message(message) } );
        },

        alertMessage: function(message) {
            jqObject.toastmessage( 'showToast', { type: 'alert',
                                              position: 'top-right',
                                              text:  emr.message(message) } );
        },

        successAlert: function(message, options) {
            jqObject.toastmessage( 'showToast', { type: 'success',
                position: 'top-right',
                text:  emr.message(message),
                stayTime: 8000,
                close: options && options.close ? options.close : null } );
        },

        errorAlert: function(message, options) {
            jqObject.toastmessage( 'showToast', { type: 'error',
                position: 'top-right',
                text:  emr.message(message),
                stayTime: 8000,
                close: options && options.close ? options.close : null } )
        },

        handleError: function(xhr) {
            emr.handleParsedError(jq.parseJSON(xhr.responseText), xhr.status);
        },

        handleParsedError: function(data, status) {
            if (!emr.redirectOnAuthenticationFailure(status)) {
                if (data.globalErrors) {
                    emr.errorAlert(data.globalErrors[0]);
                } else if (data.error.message) {
                    emr.errorAlert(data.error.message);
                } else {
                    emr.errorAlert("Error!");
                }
            }
        },

        redirectOnAuthenticationFailure: function (status) {
            if (status == 403) {
                window.location = '/' + OPENMRS_CONTEXT_PATH;
                return true;
            }
            return false;
        },

        updateBreadcrumbs: function(extraBreadcrumbs) {
            if (typeof breadcrumbs == 'undefined') {
                return;
            }
            var toUse = breadcrumbs;
            if (extraBreadcrumbs) {
                toUse = _.clone(breadcrumbs);
                if (extraBreadcrumbs == null || extraBreadcrumbs.length == 0) {
                    var index = toUse.length - 1;
                    var modified = _.clone(toUse[index]);
                    if(modified.link !=null){
                        modified.link = null;
                    }
                    toUse[index] = modified;
                }
                _.each(extraBreadcrumbs, function(item) {
                    toUse.push(item);
                })
            }
            $('#breadcrumbs').html(this.generateBreadcrumbHtml(toUse));
        },

        generateBreadcrumbHtml: function(breadcrumbs) {
            var breadcrumbTemplate = _.template($('#breadcrumb-template').html());
            var html = "";

            _.each(breadcrumbs, function(item, index) {
                html += breadcrumbTemplate({ breadcrumb: item, first: index == 0, last: index == breadcrumbs.length-1 });
            });
            return html;
        },

        /*
         * returns an object with show() and close() functions
         */
        setupConfirmationDialog: function(opts) {
            requireOptions(opts, 'selector');
            var element = $(opts.selector);
            element.hide();
            if (opts.actions) {
                if (opts.actions.confirm) {
                    element.find(".confirm").unbind('click');
                    element.find(".confirm").click(opts.actions.confirm);
                }
                if (opts.actions.cancel) {
                    element.find(".cancel").unbind('click');
                    element.find(".cancel").click(opts.actions.cancel);
                }
            }

            var dialogApi = {};
            var dialogOpts = {
                overlayClose: true,
                overlayId: "modal-overlay",
                opacity: 80,
                persist: true,
                closeClass: "cancel"
            };
            if (opts.dialogOpts) {
                $.extend(dialogOpts, opts.dialogOpts);
            }

            dialogApi.show = function() {
                $(opts.selector).modal(dialogOpts);
            };
            dialogApi.close = function() {
                $.modal.close();
            };

           return dialogApi;
        },

        stripAccents: function(term) {
            var ret = "";
            for ( var i = 0; i < term.length; i++ ) {
                ret += accentMap[ term.charAt(i) ] || term.charAt(i);
            }
            return ret;
        },

        isFeatureEnabled: function(key) {
            return featureToggles[key];
        },

        applyContextModel: function(input, contextModel) {
            if (contextModel) {
                $.each(contextModel, function(key, value) {
                    var pattern = new RegExp('{{\\s*' + key + '\\s*}}', 'g');
                    input = input.replace(pattern, value);
                });
            }
            return input;
        },

		getJSON: function(url, data, success) {
			var settings = {
				dataType: "json",
				url: url,
				data: data,
				success: success,
				beforeSend: function(xhr) {
					xhr.setRequestHeader('Disable-WWW-Authenticate', 'true');
				}
			};

			return jq.ajax(settings).fail(emr.handleNotLoggedIn);
		},

        handleNotLoggedIn: function(jqXHR) {
           if (jqXHR.status == 401 || jqXHR.status == 404) {
               if (confirm(emr.message("uicommons.notLoggedIn", "The operation cannot be completed, because you are no longer logged in. Do you want to go to login page?"))) {
                   window.location = "/" + OPENMRS_CONTEXT_PATH + "/login.htm";
               }
           }
        }

    };

})(jQuery);

var jq = jQuery;
_.templateSettings = {
    interpolate : /{{=(.+?)}}/g ,
    escape : /{{-(.+?)}}/g ,
    evaluate : /{{(.+?)}}/g
};
