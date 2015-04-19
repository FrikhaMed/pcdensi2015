<%@ include file="taskpaneHeader.jsp" %>

<openmrs:require privilege="Form Entry" otherwise="/login.htm" redirect="/module/formentry/taskpane/location.htm" />

<h3><spring:message code="Location.title"/></h3>

<c:choose>
	<c:when test="${not empty param.nodePath}">
		<c:set var="nodePath" value="${param.nodePath}"/>
	</c:when>
	<c:otherwise>
		<c:set var="nodePath" value="//encounter.location_id"/>
	</c:otherwise>
</c:choose>

<script type="text/javascript">
	dojo.require("dojo.widget.openmrs.OpenmrsSearch");
	dojo.require("dojo.widget.openmrs.EncounterSearch");
	
	function miniObject(o) {
		this.key = o.locationId;
		this.value = o.name;
	}
	
	var searchWidget;
	
	dojo.addOnLoad( function() {
		
		searchWidget = dojo.widget.manager.getWidgetById("eSearch");			
		
		dojo.event.topic.subscribe("eSearch/select", 
			function(msg) {
				setObj('${nodePath}', new miniObject(msg.objs[0]));
			}
		);
		
		dojo.event.topic.subscribe("eSearch/objectsFound", 
			function(msg) {
				if (msg.objs.length == 1 && typeof msg.objs[0] == 'string')
					msg.objs.push('<p class="no_hit"><spring:message code="Location.missing" /></p>');
			}
		);
		
		searchWidget.doFindObjects = function(phrase) {
			DWREncounterService.findLocations(phrase, searchWidget.simpleClosure(searchWidget, "doObjectsFound"));
			return false;
		};
		
		searchWidget.getCellContent = function(loc) {
			if (typeof loc == 'string') return loc;
				return loc.name;
		}
		
		searchWidget.showHeaderRow = false;
		
		searchWidget.inputNode.focus();
		searchWidget.inputNode.select();
		
		// prefill locations on page load
		DWREncounterService.getLocations(searchWidget.simpleClosure(searchWidget, "doObjectsFound"));
		
	});

</script>

<div dojoType="OpenmrsSearch" widgetId="eSearch" inputWidth="10em" useOnKeyDown="true"></div>
<br />
<small><em><spring:message code="general.search.hint"/></em></small>

<br/><br/>

<%@ include file="/WEB-INF/template/footer.jsp" %>