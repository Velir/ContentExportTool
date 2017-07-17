﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentExport.aspx.cs" Inherits="ContentExportTool.ContentExport" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Content Export Tool</title>
    <style>
		.header {color: brown}
		.notes {color: GrayText; font-size: 12px}
		.container {margin-bottom: 10px; font-family: Arial}

        .advanced .advanced-inner {
            display: none;
            margin-top: 10px;
        }

        .advanced .advanced-btn {
            color: brown;
            font-weight: bold;
            padding-bottom: 10px;
            cursor:pointer;
        }

        .advanced .advanced-btn:after {
            border-style: solid;
	        border-width: 0.25em 0.25em 0 0;
	        content: '';
	        display: inline-block;
	        height: 0.45em;
	        left: 0.15em;
	        position: relative;
	        vertical-align: top;
	        width: 0.45em;
	        top: 0;
	        transform: rotate(135deg);
	        margin-left:5px
        }

        .advanced.open a.advanced-btn:after {
            top: 0.3em;
	        transform: rotate(-45deg);
        }

        .txtCustomDatabase {
            margin-left: 5px;
        }

        .include-ids {
            color: brown;
            font-size: 14px;
        }

        input[type='text'] {
            width: 500px;
            max-width: 80%;
        }

        a.clear-btn {
            cursor: pointer;
            color: brown;
            font-size: 11px;
            margin-left: 6px;
        }

	</style>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script>
        $(document).ready(function() {
            $(".advanced-btn").on("click", function() {
                if ($(this).parent().hasClass("open")) {
                    $(this).parent().removeClass("open");
                } else {
                    $(this).parent().addClass("open");
                }

                $(".advanced-inner").slideToggle();
            });

            $(".ddDatabase").on("change", function() {
                if ($(this).find("option:selected").val() === "custom") {
                    $(".txtCustomDatabase").show();
                } else {
                    $(".txtCustomDatabase").hide();
                }

                if ($(this).find("option:selected").val() !== "master") {
                    $(".workflowBox input").each(function() {
                        $(this).prop("checked", false);
                    });
                }
            });

            $(".workflowBox input").on("change", function () {
                if ($(this).is(":checked")) {
                    $(".ddDatabase").val("master");
                }
            });

            $(".clear-btn").on("click", function() {
                var id = $(this).attr("data-id");
                var input = $("#" + id);
                $(input).val("");
            });
        });

    </script>

</head>
<body>
   <form id="form1" runat="server">
        <div>
            <h2 id="headline" runat="server">Content Export Tool</h2>

            <div class="container" style="background-color: brown; border-width: 1px; color: white; width: 600px; padding: 2px 4px; font-size: 12px">
                <asp:Literal runat="server" ID="litFeedback"></asp:Literal>
            </div>

            <div class="controls">                              
                <asp:Button runat="server" ID="btnRunExport" OnClick="btnRunExport_OnClick" Text="Run Export"/><br/><br/>

                <div class="container">
                    
                    <span class="header">Database</span>
                    <asp:DropDownList runat="server" ID="ddDatabase" CssClass="ddDatabase"/><input runat="server" class="txtCustomDatabase" ID="txtCustomDatabase" style="display:none"/> <br/>
                    <span class="notes">Select database. Defaults to web</span><br/><br/>
                    
                    <asp:Checkbox runat="server" ID="chkIncludeIds"/><span class="header">Include IDs</span><br/>
                    <span class="notes">Check this box to include item IDs (guid) in the exported file. Item paths are already included.</span><br/><br/>

                    <span class="header">Start Item</span><a class="clear-btn" data-id="inputStartitem">clear</a><br/>
                     <span class="notes">Enter the path of the starting node. Only content beneath and including this node will be exported. If field is left blank, the starting node will be /sitecore/content</span><br/>
                    <input runat="server" ID="inputStartitem"/>
                    <br/>
                    <span>OR</span><br/>
                    <span class="header">Fast Query</span><a class="clear-btn" data-id="txtFastQuery">clear</a><br/>
                    <span class="notes">Enter a fast query to run a filtered export. You can use the Templates box as well.<br/> Example: fast:/sitecore/content/Home//*[@__Updated >= '20140610' and @__Updated <'20140611']</span><br/>
                    <input runat="server" ID="txtFastQuery"/>
                    <br/>
                   <br/>
                    
                    <span class="header">Templates</span><a class="clear-btn" data-id="inputTemplates">clear</a><br/>
                     <span class="notes">Enter template names separated by commas. Items will only be exported if their template name is in this list. If this field is left blank, all templates will be exported</span><br/>
                    <textarea runat="server" ID="inputTemplates" cols="60" row="5"></textarea>
                    <br/>
                   <br/>

                    <span class="header">Text Fields</span><a class="clear-btn" data-id="inputFields">clear</a><br/>
                    <span class="notes">Enter field names separated by commas</span><br/>
                    <textarea runat="server" ID="inputFields" cols="60" row="5"></textarea>
                    <br /><br/>
                    
                    
                    
                    
                    <div class="advanced">
                        <a class="advanced-btn">Advanced Fields</a>
                        <div class="advanced-inner">
                            <span class="header">Image Fields</span><a class="clear-btn" data-id="inputImageFields">clear</a><br/>
                            <span class="notes">Enter field names separated by commas</span><br/>
                            <textarea runat="server" ID="inputImageFields" cols="60" row="5"></textarea><br/>
                            <asp:Checkbox runat="server" ID="chkIncludeImageIds" /><span class="include-ids">Include image ID</span>
                            <br /><br/>
                    
                            <span class="header">Link Fields</span><a class="clear-btn" data-id="inputLinkFields">clear</a><br/>
                            <span class="notes">Enter field names separated by commas</span><br/>
                            <textarea runat="server" ID="inputLinkFields" cols="60" row="5"></textarea><br/>
                            <br /><br/>
                            
                            <span class="header">DropList Fields</span><a class="clear-btn" data-id="inputDroplistFields">clear</a><br/>
                            <span class="notes">Enter field names separated by commas</span><br/>
                            <textarea runat="server" ID="inputDroplistFields" cols="60" row="5"></textarea><br/>
                            <asp:Checkbox runat="server" ID="chkIncludeDroplistIds"/><span class="include-ids">Include selected item ID</span><br/>
                            <br /><br/>
                    
                            <span class="header">Multilist Fields</span><a class="clear-btn" data-id="inputMultiFields">clear</a><br/>
                            <span class="notes">Enter field names separated by commas</span><br/>
                            <textarea runat="server" ID="inputMultiFields" cols="60" row="5"></textarea><br/>
                            <asp:Checkbox runat="server" ID="chkIncludeMultilistIds" /><span class="include-ids">Include item IDs</span>
                            <br /><br/>
                            
                            <asp:CheckBox runat="server" CssClass="workflowBox" ID="chkWorkflowName"/><span class="header">Workflow</span><br/>
                            <asp:CheckBox runat="server" CssClass="workflowBox" ID="chkWorkflowState"/><span class="header">Workflow State</span>  <br />
                            <span class="notes">Workflow options require the database to be set to master</span>
                            <br/><br/>

                            <asp:CheckBox runat="server" ID="chkAllLanguages"/><span class="header">Get All Language Versions</span><br/>
                            <span class="notes">This will get the selected field values for all languages that each item has an existing version for</span>
                            <br/><br/>
                            
                            <asp:Button runat="server" ID="btnRunExportDupe" OnClick="btnRunExport_OnClick" Text="Run Export"/><br/><br/>
                        
                            <asp:Button runat="server" ID="btnWebformsExport" OnClick="btnWebformsExport_OnClick" Text="Webforms" /><br/>
                            <span class="notes">Download all Webforms for Marketers forms and fields</span>
                        </div>
                    </div>
                    
                </div>
                
                
            </div>

        </div>
    </form>
</body>
</html>
