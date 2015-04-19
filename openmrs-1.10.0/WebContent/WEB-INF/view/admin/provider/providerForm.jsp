<%@ include file="/WEB-INF/template/include.jsp" %>

<openmrs:require privilege="View Providers" otherwise="/login.htm" redirect="/admin/provider/provider.form" />

<%@ include file="/WEB-INF/template/header.jsp" %>
<%@ include file="localHeader.jsp" %>

<openmrs:htmlInclude file="/scripts/calendar/calendar.js" />
<openmrs:htmlInclude file="/scripts/dojoConfig.js" />
<openmrs:htmlInclude file="/scripts/dojo/dojo.js" />

<script type="text/javascript">
function toggleProviderDetails(){
	
	$j('.providerDetails').toggle();
	
	if($j('#providerName').is(":visible"))
		$j('#linkToPerson').removeAttr('checked');
	else
		$j('#linkToPerson').attr('checked', 'checked');
		
		
}
</script>

<style>
	#table th { text-align: left; }
	td.fieldNumber { 
		width: 5px;
		white-space: nowrap;
	}
</style>

<h2><openmrs:message code="Provider.manage.title"/></h2>

<spring:hasBindErrors name="provider">
	<openmrs:message code="fix.error"/>
	<br />
</spring:hasBindErrors>

<b class="boxHeader">
<c:if test="${provider.providerId == null}">
	<openmrs:message code="Provider.create"/>
</c:if>
<c:if test="${provider.providerId != null}">
	<openmrs:message code="Provider.edit"/>
</c:if>
</b>

<div class="box">
	<form method="post">
		
		<table cellpadding="3" cellspacing="0">
			<tr>
				<th><openmrs:message code="Provider.identifier"/></th>
				<td colspan="4">
					<spring:bind path="provider.identifier">			
						<input type="text" name="${status.expression}" size="10" 
							   value="${status.value}" />
					   
						<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if> 
					</spring:bind>
				</td>
			</tr>
			<c:choose>
			<c:when test="${provider.providerId == null}">
			<tr>
				<th><openmrs:message code="Provider.person"/></th>
				<td>
					<spring:bind path="provider.person">
					<openmrs:fieldGen type="org.openmrs.Person" formFieldName="${status.expression}" val="${status.editor.value}"/>
						<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
					</spring:bind>
				</td>
				<td>&nbsp;&nbsp;&nbsp;<openmrs:message code="general.or" />&nbsp;&nbsp;&nbsp;</td>
				<th><openmrs:message code="Provider.name"/></th>
				<td>
					<spring:bind path="provider.name">			
						<input type="text" name="${status.expression}" size="25" 
							   value="${status.value}" />
					   
						<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if> 
					</spring:bind>
				</td>
			</tr>
			</c:when>
			<c:otherwise>
			<tr>
				<th><openmrs:message code="Provider.name"/></th>
				<td>
					<div class="providerDetails" <c:if test="${provider.person != null}">style="display:none"</c:if>>
						<form:input id="providerName" path="provider.name" /> <form:errors path="provider.name" cssClass="error" /> <openmrs:message code="general.or" /> 
						<a href="javascript:void(0)" onclick="toggleProviderDetails()"> <openmrs:message code="Provider.linkToPerson"/></a>
					</div>
					<div class="providerDetails" <c:if test="${provider.person == null}">style="display:none"</c:if>>
						${provider.person.personName} 
						<span <c:if test="${provider.person != null}">style="display:none"</c:if>>
						<spring:bind path="provider.person">
						<openmrs_tag:personField formFieldName="${status.expression}" initialValue="${status.value}" />
						<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>	
						</spring:bind>
						</span>
						<a href="javascript:void(0)" onclick="toggleProviderDetails()">(<openmrs:message code="Provider.unLinkFromPerson"/>)</a>
					 </div>
					 <input id="linkToPerson" name="linkToPerson" type="checkbox" value="true" style="display:none" 
					 	<c:if test="${provider.person != null}">checked="checked"</c:if> />
				</td>
			</tr>
			</c:otherwise>
			</c:choose>

			<spring:bind path="provider.activeAttributes">
				<c:if test="${status.error}">
					<tr>
						<th></th>
						<td>
							<span class="error">
								<c:forEach var="err" items="${status.errorMessages}">
									${ err }<br/>
								</c:forEach>
							</span>
						</td>
					</tr>
				</c:if>
			</spring:bind>
            <c:if test="${ not empty providerAttributeTypes }">
				<c:forEach var="attrType" items="${ providerAttributeTypes }">
					<openmrs_tag:attributesForType attributeType="${ attrType }" customizable="${ provider }" formFieldNamePrefix="attribute.${ attrType.providerAttributeTypeId }"/>
				</c:forEach>
			</c:if>

		</table>

		<br/>
	
	<input type="hidden" name="phrase" value='<request:parameter name="phrase" />'/>
	<input type="submit" name="saveProviderButton" value='<openmrs:message code="Provider.save"/>'>
	&nbsp;
	<input type="button" value='<openmrs:message code="general.cancel"/>' onclick="document.location='index.htm'">
	
	</form>
	</div>
	
	<br/>
    <br/>

	<c:if test="${provider.providerId != null}">
		<div class="box">
			<form method="post">
				<table cellpadding="3" cellspacing="0">
					<tr>
						<th><openmrs:message code="general.createdBy" /></th>
						<td>
							<a href="#View User" onclick="return gotoUser(null, '${provider.creator.userId}')">${provider.creator.personName}</a> -
							<openmrs:formatDate date="${provider.dateCreated}" type="medium" />
						</td>
					</tr>
					<c:if test="${provider.retiredBy == null}">
						<tr id="retiredReason">
							<th><openmrs:message code="general.retiredReason" /></th>
							<td>
								<spring:bind path="provider.retired">
									<input type="hidden" name="${status.expression}" value="true"/>
								</spring:bind>

								<spring:bind path="provider.retireReason">
									<input type="text" id="retire" value="${status.value}" name="${status.expression}" size="40" />
									<c:if test="${status.errorMessage != ''}"><span class="error">${status.errorMessage}</span></c:if>
								</spring:bind>
							</td>
						</tr>
						<tr>
							<td><input type="submit" name="retireProviderButton"
								value='<openmrs:message code="Provider.retire"/>'></td>
						</tr>
					</c:if>	
														
					<c:if test="${provider.retiredBy != null}">
						<tr id="retiredBy">
							<th><openmrs:message code="general.retiredBy" /></th>
							<td>
								<a href="#View User" onclick="return gotoUser(null, '${provider.retiredBy.userId}')">${provider.retiredBy.personName}</a> -
								<openmrs:formatDate date="${provider.dateRetired}" type="medium" />
							</td>
						</tr>
						<tr>
							<th><openmrs:message code="general.retiredReason" /></th>
							<td><c:out value="${provider.retireReason}"/></td>
						</tr>
						<tr>
							<td><input type="submit" name="unretireProviderButton"
								value='<openmrs:message code="Provider.unretire"/>'></td>
						</tr>
					</c:if>		
				</table>
			</form>
		</div>
	</c:if>

<%@ include file="/WEB-INF/template/footer.jsp" %>