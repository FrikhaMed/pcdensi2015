<%@ include file="taskpaneHeader.jsp" %>

<openmrs:require privilege="Form Entry" otherwise="/login.htm" redirect="/module/formentry/taskpane/user.htm" />

<c:choose>
	<c:when test="${not empty param.nodePath}">
		<c:set var="nodePath" value="${param.nodePath}"/>
	</c:when>
	<c:otherwise>
		<script type="text/javascript">
			alert("You must provide the nodePath query parameter with the node to fill in (e.g. nodePath='//encounter.provider_id)')");
		</script>
	</c:otherwise>
</c:choose>

<c:choose>
	<c:when test="${empty param.title}">
		<h3><spring:message code="User.title"/></h3>
	</c:when>
	<c:otherwise>
		<h3><spring:message code="${param.title}"/></h3>
	</c:otherwise>
</c:choose>

<openmrs:htmlInclude file="/dwr/interface/DWRPersonService.js" ></openmrs:htmlInclude>
<openmrs:htmlInclude file="/dwr/interface/DWRUserService.js" ></openmrs:htmlInclude>

<script type="text/javascript">
	dojo.require("dojo.widget.openmrs.UserSearch");
	dojo.require("dojo.widget.openmrs.OpenmrsSearch");
	
	function miniObject(o) {
		this.key = o.userId;
		this.value = searchWidget.getName(o);
	}
	
	var searchWidget;
	
	dojo.addOnLoad( function() {
		
		searchWidget = dojo.widget.manager.getWidgetById("uSearch");			
		
		dojo.event.topic.subscribe("uSearch/select", 
			function(msg) {
				setObj('${nodePath}', new miniObject(msg.objs[0]));
			}
		);
		
		dojo.event.topic.subscribe("uSearch/objectsFound", 
			function(msg) {
				if (msg.objs.length == 1 && typeof msg.objs[0] == 'string')
					msg.objs.push('<p class="no_hit"><spring:message code="provider.missing" /></p>');
			}
		);
		
		searchWidget.getName = function(o) {
			if (typeof o == 'string') return o;
			str = ''
			str += o.givenName + " ";
			str += o.familyName;
			str += " (" + o.systemId + ")";
			return str;
		};
		
		searchWidget.getCellFunctions = function() {
			var arr = new Array();
			arr.push(this.simpleClosure(this, "getNumber"));
			arr.push(this.simpleClosure(this, "getName"));
			return arr;
		};
		
		searchWidget.showHeaderRow = false;
		
		searchWidget.allowAutoJump = function() {
			return this.text && this.text.length > 1;
		};

		searchWidget.inputNode.focus();
		searchWidget.inputNode.select();

		// maybe prefill users on page load
		<openmrs:globalProperty var="showAllUsersOnLoad" key="formentry.infopath_taskpane.showAllUsersOnLoad" defaultValue="true"/>
		<c:if test="${showAllUsersOnLoad}">
			setTimeout(function() {searchWidget.showAll()}, 250);
		</c:if>
	});

</script>

<div dojoType="UserSearch" widgetId="uSearch" inputWidth="10em" useOnKeyDown="true" roles='<request:existsParameter name="role"><request:parameters id="r" name="role"><request:parameterValues id="names"><jsp:getProperty name="names" property="value"/>;</request:parameterValues></request:parameters></request:existsParameter>'></div>
<br />
<small><em><spring:message code="general.search.hint"/></em></small>

<br/><br/>

<%@ include file="/WEB-INF/template/footer.jsp" %>