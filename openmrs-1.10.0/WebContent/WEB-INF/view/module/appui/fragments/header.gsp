<%
    def addContextPath = {
        if (!it)
            return null
        if (it.startsWith("/")) {
            it = "/" + org.openmrs.ui.framework.WebConstants.CONTEXT_PATH + it
        }
        return it
    }
    def logoIconUrl = addContextPath(configSettings?."logo-icon-url") ?: ui.resourceLink("uicommons", "images/logo/openmrs-with-title-small.png")
    def logoLinkUrl = addContextPath(configSettings?."logo-link-url") ?: "/${ org.openmrs.ui.framework.WebConstants.CONTEXT_PATH }"
%>
<script type="text/javascript">

    var sessionLocationModel = {
        id: ko.observable(),
        text: ko.observable()
    };

    jq(function () {
        jq(".change-location a").click(function () {
            jq('#session-location').show();
            jq(this).addClass('focus');
            jq(".change-location a i:nth-child(3)").removeClass("icon-caret-down");
            jq(".change-location a i:nth-child(3)").addClass("icon-caret-up");
        });

        jq('#session-location').mouseleave(function () {
            jq('#session-location').hide();
            jq(".change-location a").removeClass('focus');
            jq(".change-location a i:nth-child(3)").addClass("icon-caret-down");
            jq(".change-location a i:nth-child(3)").removeClass("icon-caret-up");
        });

        ko.applyBindings(sessionLocationModel, jq('.change-location').get(0));
        sessionLocationModel.id(${ sessionContext.sessionLocationId });
        sessionLocationModel.text("${ ui.format(sessionContext.sessionLocation) }");

        jq("#session-location ul.select li").click(function (event) {
            var element = jq(event.target);
            var locationId = element.attr("locationId");
            var locationName = element.attr("locationName");

            var data = "locationId=" + locationId;

            jq("#spinner").show();

            jq.post("/${ contextPath }/mirebalais/standard.page", data, function (returnedData) {
                sessionLocationModel.id(locationId);
                sessionLocationModel.text(locationName);
                jq('#session-location li').removeClass('selected');
                element.addClass('selected');
                jq("#spinner").hide();

                //this is being used for dispensing app to update medication list
                if (reloadPageToUpdateListMedicationDispensingByLocation != undefined) {
                    reloadPageToUpdateListMedicationDispensingByLocation();
                }
            })

            jq('#session-location').hide();
            jq(".change-location a").removeClass('focus');
            jq(".change-location a i:nth-child(3)").addClass("icon-caret-down");
            jq(".change-location a i:nth-child(3)").removeClass("icon-caret-up");
        });
    });

</script>

<header>
    <div class="logo">
        <a href="${ logoLinkUrl }">
            <img src="${ logoIconUrl }"/>
        </a>
    </div>
    <% if (context.authenticated) { %>
    <ul class="user-options">
        <li class="identifier">
            <i class="icon-user small"></i>
            ${context.authenticatedUser.username ?: context.authenticatedUser.systemId}
        </li>
        <li class="change-location">
            <a href="#">
                <i class="icon-map-marker small"></i>
                <span data-bind="text: text"></span>
                <i class="icon-caret-down link"></i>
            </a>
        </li>
        <li class="logout">
            <a href="/${contextPath}/logout">
                ${ui.message("emr.logout")}
                <i class="icon-signout small"></i>
            </a>
        </li>
    </ul>

    <div id="session-location">
        <div id="spinner" style="position:absolute; display:none">
            <img src="${ui.resourceLink("uicommons", "images/spinner.gif")}">
        </div>
        <ul class="select">
            <% loginLocations.sort { ui.format(it) }.each {
                def selected = (it == sessionContext.sessionLocation) ? "selected" : ""
            %>
            <li class="${selected}" locationId="${it.id}" locationName="${ui.format(it)}">${ui.format(it)}</li>
            <% } %>
        </ul>
    </div>
    <% } %>
</header>