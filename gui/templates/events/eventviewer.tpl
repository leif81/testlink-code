{*
TestLink Open Source Project - http://testlink.sourceforge.net/
$Id: eventviewer.tpl,v 1.19 2008/10/30 20:00:08 franciscom Exp $

Event Viewer

rev: 20080207 - franciscom - cleaup

//SCHLUNDUS: i will cleanup this file, when i'm finished

*}
{assign var="cfg_section" value=$smarty.template|basename|replace:".tpl":"" }
{config_load file="input_dimensions.conf" section=$cfg_section}

{lang_get var='labels'
          s='event_viewer,th_loglevel,th_timestamp,th_description,title_eventdetails,
             title_eventinfo,label_startdate,label_enddate,btn_apply,click_on_event_info,
             btn_clear_events,th_event_description,
             message_please_wait,btn_close,th_role_description,th_user'}


{include file="inc_head.tpl" openHead="yes" jsValidate="yes" enableTableSorting="yes"}
{include file="inc_ext_js.tpl"}

<script type="text/javascript">
var strPleaseWait = "{$labels.message_please_wait|escape:javascript}";
var strCloseButton = "{$labels.btn_close|escape:javascript}";
{literal}
var prgBar = null;

function showEventDetails(id)
{
	prgBar = Ext.Msg.wait(strPleaseWait);
	Ext.Ajax.request(
				{
					url : 'lib/events/eventinfo.php' ,
					params : { id : id },
					method: 'POST',
					success: function(result, request)
							 {
								showDetailWindow(result.responseText);
							 },
					failure: function (result, request)
						{
							if (prgBar)
								prgBar.hide();
						}
				}
			);
}
var infoWin;
function showDetailWindow(info)
{
	var item = document.getElementById('eventDetails');
	item.innerHTML = info;
	if (prgBar)
		prgBar.hide();
	if(!infoWin)
	{
		infoWin = new Ext.Window({
					el:'eventDetailWindow',
					modal:true,
					autoTabs: true,
					layout:'fit',
					width:700,
					height:500,
					items: new Ext.TabPanel({
						el: 'detailTabs',
						autoTabs:true,
						activeTab:0,
						deferredRender:false,
						border:false
					}),
					closeAction:'hide',
					plain: true,
					buttons: [{
						text: strCloseButton,
						handler: function(){
							infoWin.hide();
						}
					}]
			});
	}
	infoWin.show();
}
</script>
<style type="text/css">
fieldset
{
	height:100%;

}
#eventviewer
{
	white-space:nowrap;
	cursor: hand;
	cursor: pointer;
}

#eventviewer tr.AUDIT
{
	color:blue;
}
#eventviewer tr.ERROR
{
	color:red;
	font-weight:bold;
	border: 1px solid red;
	white-space: pre;
}
#eventviewer tr.WARNING
{
	color:black;
	font-weight:bold;
}
#eventviewer tr.INFO
{
	color:green;
}
</style>
{/literal}

</head>



<body {$body_onload}>
<h1 class="title">{$labels.event_viewer}</h1>

<div class="workBack">
		<form method="post" action="lib/events/eventviewer.php">
			<input type="hidden" name="object_id" value="{$object_id}"/>
			<input type="hidden" name="object_type" value="{$object_type|escape}"/>
			<input type="hidden" name="doAction" id="doAction" value="filter"/>
			
			<div style="height:125px;">
			<fieldset class="x-fieldset" style="float:left"><legend>{$labels.th_loglevel}</legend>
				<select size="5" multiple="multiple" name="logLevel[]">
					{foreach from=$logLevels item=desc key=value}
					{if in_array((string)$value,$selectedLogLevels) neq false}
						<option selected="selected" value="{$value}">{$desc}</option>
					{else}
						<option value="{$value}">{$desc}</option>
					{/if}
					{/foreach}
				</select>
			</fieldset>
			<fieldset class="x-fieldset"><legend>{$labels.th_timestamp}</legend>
			{$labels.label_startdate}:&nbsp;<input type="text" name="startDate" id="startDate" value="{$startDate}" />
			<input type="button" style="cursor:pointer" onclick="showCal('startDate-cal','startDate');" value="^" />
			<div id="startDate-cal" style="position:absolute;width:240px;left:300px"></div>
			{$labels.label_enddate}:&nbsp;<input type="text" name="endDate" id="endDate" value="{$endDate}" />
			<input type="button" style="cursor:pointer" onclick="showCal('startDate-cal','endDate');" value="^" />
			<input type="submit" value="{$labels.btn_apply}" onclick="doAction.value='filter'">
			<br />
			{if $gui->canDelete}
			  <br />
			  <input type="submit" value="{$labels.btn_clear_events}" onclick="doAction.value='clear'">
			{/if}
			</fieldset>
			<br />
			</div>
		</form>
		<br/>
		<br/>
		<span class="italic">{$labels.click_on_event_info}</span>
		<table class="common sortable" width="95%" id="eventviewer">
			<tr>
				<th>{$sortHintIcon}{$labels.th_timestamp}</th>
				<th>{$sortHintIcon}{$labels.th_loglevel}</th>
				<th>{$sortHintIcon}{$labels.th_event_description}</th>
				<th>{$sortHintIcon}{$labels.th_user}</th>
			</tr>
			{assign var=transID value="-1"}
			{foreach from=$events item=event}
			{assign var=userID value=$event->userID}
			{if $event->transactionID neq $transID}
				{assign var=transID value=$event->transactionID}
				{assign var=padding value=""}
			{/if}

			<tr onClick="showEventDetails({$event->dbID})" class="{$event->getLogLevel()|escape}">
					<td style="white-space:nowrap;{$padding}">{localize_timestamp ts=$event->timestamp}</td>
					<td>{$event->getLogLevel()|escape}</td>
					<td>{$event->description|escape|truncate:#EVENT_DESCRIPTION_TRUNCATE_LEN#}</td>
					<td>
					{if $users[$userID] neq false}
						{$users[$userID]|escape}
					{else}
						&nbsp;
					{/if}
					</td>
			</tr>
				{assign var=padding value="padding-left:20px"}
		{/foreach}
		</table>
</div>
<div id="eventDetailWindow" class="x-hidden">
	<div class="x-window-header">{$labels.title_eventinfo}</div>
	<div id="detailTabs">
		<div class="x-tab" title="{$labels.title_eventdetails}">
			<div id="eventDetails" class="inner-tab"></div>
		</div>
	</div>
</div>
</body>