
<%
    ui.decorateWith("appui", "standardEmrPage")

    def idCardPrinterOptions = []

    idCardPrinters.sort { it.name }.each {
        idCardPrinterOptions.push([ label: ui.format(it.name) + ' (' + ui.format(it.physicalLocation) + ')', value: it.id ])
    }

    def labelPrinterOptions = []

    labelPrinters.sort { it.name }.each {
        labelPrinterOptions.push([ label: ui.format(it.name) + ' (' + ui.format(it.physicalLocation) + ')', value: it.id ])
    }
%>

<script type="text/javascript">
    jq(function() {

        jq('select').change(function() {

            var name = jq(this).attr('name').split("-");

            var data = { location: name[1],
                         type: name[0],
                         printer: jq(this).val() };

            jq.ajax({
                url: '${ ui.actionLink('emr','printer/defaultPrinters','saveDefaultPrinter') }',
                data: data,
                dataType: 'json',
                type: 'POST'
            })
                    .success(function(data) {
                        emr.successMessage(data.message);
                    })
                    .error(function(xhr, status, err) {
                        emr.errorMessage('${ ui.message("emr.printer.error.defaultUpdate") }')
                    })

        });
    });


</script>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("emr.app.systemAdministration.label")}", link: '${ui.pageLink("emr", "systemAdministration")}' },
        { label: "${ ui.message("emr.printer.defaultPrinters")}" }
    ];
</script>

<h3>${ ui.message("emr.printer.defaultPrinters") }</h3>

<table class="bordered">

    <tr>
        <th>
            ${ ui.message("emr.printer.defaultPrinterTable.loginLocation.label") }
        </th>
        <th>
            ${ ui.message("emr.printer.defaultPrinterTable.idCardPrinter.label") }
        </th>
        <th>
            ${ ui.message("emr.printer.defaultPrinterTable.labelPrinter.label") }
        </th>
    </tr>


    <% locationsToPrintersMap.sort { ui.format(it.key) }.each {   %>
            <tr>
                <td>${ ui.format(it.key) }</td>

                <td>
                    ${ ui.includeFragment("uicommons", "field/dropDown", [ id: "ID_CARD-" + it.key.id, formFieldName: "ID_CARD-" + it.key.id, emptyOptionLabel: ui.message("emr.printer.defaultPrinterTable.emptyOption.label"), initialValue: it.value.idCardPrinter?.id ?: '', options: idCardPrinterOptions ])}
                </td>

                <td>
                    ${ ui.includeFragment("uicommons", "field/dropDown", [ id: "LABEL-" + it.key.id, formFieldName: "LABEL-" + it.key.id, emptyOptionLabel: ui.message("emr.printer.defaultPrinterTable.emptyOption.label"), initialValue: it.value.labelPrinter?.id ?: '', options: labelPrinterOptions ])}
                </td>
            </tr>


    <% } %>



</table>