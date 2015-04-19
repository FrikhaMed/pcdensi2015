<%
    ui.decorateWith("appui", "standardEmrPage")
	ui.includeCss("mirebalaisreports", "reports.css")
%>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("mirebalaisreports.home.title") }", link: "${ ui.pageLink("mirebalaisreports", "home") }" }
    ];
</script>

<div class="reportBox">
	<p>${ ui.message("mirebalaisreports.categories.overviewReports") }</p>
	<ul>
		<li><a id="mirebalaisreports-basicStatisticsReport-link" href="${ ui.pageLink("mirebalaisreports", "basicStatistics") }">${ basicStatisticsReport.name }</a></li>
	</ul>
</div>
<div class="reportBox">
	<p>${ ui.message("mirebalaisreports.categories.dataQualityReports") }</p>
	<ul>
		<li><a id="mirebalaisreports-nonCodedDiagnosesReport-link" href="${ ui.pageLink("mirebalaisreports", "nonCodedDiagnoses") }">${ nonCodedDiagnosesReport.name }</a></li>
	</ul>
</div>

<div style="padding-top:20px;">
	<% if (context.hasPrivilege(weeklyDiagnosisSurveillanceReport.requiredPrivilege)) { %>
	<div class="reportBox">
		<p>${ ui.message("mirebalaisreports.categories.msppReports") }</p>
		<ul>
			<li><a id="mirebalaisreports-weeklyDiagnosisSurveillanceReport-link" href="${ ui.pageLink("mirebalaisreports", "weeklyDiagnosisSurveillance") }">${ weeklyDiagnosisSurveillanceReport.name }</a></li>
		</ul>
	</div>
	<% } %>
	<% if (context.hasPrivilege(fullDataExportReport.requiredPrivilege)) { %>
	<div class="reportBox">
		<p>${ ui.message("mirebalaisreports.categories.dataExports") }</p>
		<ul>
			<li><a id="mirebalaisreports-fullDataExportReport-link" href="${ ui.pageLink("mirebalaisreports", "fullDataExport") }">${ fullDataExportReport.name }</a></li>
            <li><a id="mirebalaisreports-lqasDiagnosesReport-link" href="${ ui.pageLink("mirebalaisreports", "lqasDiagnoses") }">${ lqasDiagnosesReport.name }</a></li>
            <li><a id="mirebalaisreports-allPatientsWithIdsReport-link" href="${ ui.pageLink("mirebalaisreports", "allPatientsWithIds") }">${ allPatientsWithIdsReportManager.name }</a></li>
		</ul>
	</div>
	<% } %>
</div>