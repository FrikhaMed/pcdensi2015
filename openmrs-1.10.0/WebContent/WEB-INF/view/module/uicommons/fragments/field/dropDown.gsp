<%
    config.require("formFieldName")
    config.require("options")

    def required = config.classes && config.classes.contains("required");

    def selectDataBind = "";
    if (config.depends && config.depends.disable) {
        selectDataBind += "disable: ${ config.depends.variable }() == '${ config.depends.disable }'"
    }
    if (config.depends && config.depends.enable) {
        selectDataBind += "enable: ${ config.depends.variable }() == '${ config.depends.enable }'"
    }
    if (config.dependency || required) {
        selectDataBind += ", value: ${ config.id }"
    }
%>

<p id="${ config.id }"
    <% if (config.depends) { %> data-bind="visible: ${ config.depends.variable }() == '${ config.depends.value }'" <% } %>
    <% if (config.left) { %> class="left" <% } %>  >

    <label for="${ config.id }-field">
        ${ ui.message(config.label) ?: '' } <% if (required) { %><span>(${ ui.message("emr.formValidation.messages.requiredField.label") })</span><% } %>
    </label>

    <select id="${ config.id }-field" name="${ config.formFieldName}"
            <% if (config.classes) { %> class="${ config.classes.join(' ') }" <% } %>
            <% if (config.maximumSize) { %> size="${ [config.maximumSize, config.options.size()].min() }" <% } %>
            <% if (selectDataBind) { %> data-bind="${ selectDataBind }" <% } %> >

        <% if(!config.hideEmptyLabel) { %>
            <option value="">${ ui.message(config.emptyOptionLabel ?: '') }</option>
        <% } %>
        <% config.options.each {
            def selected = it.selected || it.value == config.initialValue
        %>
            <option value="${ it.value }"  <% if (selected) { %>selected<% } %>/>${ it.label }</option>
        <% } %>
    </select>

    ${ ui.includeFragment("uicommons", "fieldErrors", [ fieldName: config.formFieldName ]) }
</p>

<% if (config.dependency || required) { %>
<script type="text/javascript">
    var viewModel = viewModel || {};
    viewModel.validations = viewModel.validations || [];

    viewModel.${ config.id } = ko.observable();
    <% if (required) { %>
    viewModel.validations.push(function() {
        return jq('#${ config.id }-field').is(':disabled') || (viewModel.${ config.id }() ? true : false);
    });
    <% } else { %>
    viewModel.validations.push(function() {
        viewModel.${ config.id }();
        return true;
    });
    <% } %>
</script>
<% } %>