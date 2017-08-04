<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ContentExport.aspx.cs" Inherits="ContentExportTool.ContentExport" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Content Export Tool</title>
    <style>
        body {
            background: white !important;
            padding: 10px;
        }

        .header {
            color: brown;
        }

        .notes {
            color: GrayText;
            font-size: 12px;
        }

        .container {
            margin-bottom: 10px;
            font-family: Arial;
        }

        .advanced .advanced-inner {
            display: none;
            margin-top: 10px;
        }

        .advanced .advanced-btn {
            color: brown;
            font-weight: bold;
            padding-bottom: 10px;
            cursor: pointer;
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
                margin-left: 5px;
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

        a.clear-btn, .show-hints {
            cursor: pointer;
            color: brown;
            font-size: 11px;
            margin-left: 6px;
        }

        .show-hints {
            margin-left: 0;
            display: block;
        }

        .lit-fast-query {
            color: brown;
            font-size: 12px;
        }

        .hints .notes {
            display: block;
            display: none;
            width: 750px;
            max-width: 80%;
        }

        .browse-btn {
            margin-left: 5px;
        }

        .modal.browse-modal {
            z-index: 999;
            position: absolute;
            background: white;
            border: 2px solid brown;
            width: 700px;
            margin-left: 20%;
            height: 60%;
        }

        .selector-box {
            width: 450px;
            overflow: scroll;
            height: 100%;
            float: left;
        }

        .selection-box {
            display: inline-block;
            width: 250px;
            height: 100%;
        }

        .modal.browse-modal ul {
            list-style: none;
            width: 100%;
        }

            .modal.browse-modal ul li {
                position: relative;
                left: -20px;
            }

        .modal.browse-modal li ul {
            display: none;
        }

        .modal.browse-modal li.expanded > ul {
            display: block;
        }

        .modal.browse-modal a {
            cursor: pointer;
            font-weight: bold;
            text-decoration: none;
            color: black;
        }

        .modal.browse-modal .browse-expand {
            color: brown;
            position: absolute;
        }

        .modal.browse-modal .sitecore-node {
            margin-left: 12px;
        }

        .main-btns .right {
            float: right;
        }

        .main-btns {
            width: 600px;
            display: inline-block;
            height: auto;
        }

            .main-btns .left {
                float: left;
            }

        .save-settings-box {
            border: 1px solid;
            background: #eee;
            padding: 5px;
            left: 20%;
        }

            .save-settings-box input[type="text"] {
                width: 200px;
            }

        .save-settings-close {
            position: absolute;
            right: 2px;
            cursor: pointer;
            top: 2px;
        }

        #btnSaveSettings {
            display: none;
        }

        .error-message {
            color: red;
            font-size: 12px;
            display: none;
        }

            .error-message.server {
                display: block;
            }

        span.save-message {
            color: brown;
            margin-left: 2px;
            display: inline-block;
        }

        .row:not(:last-child) {
            margin-bottom: 5px;
        }

        .btn-clear-all {
            background: none;
            border: none;
            color: brown;
            margin-top: 10px;
            font-size: 14px;
            padding: 0;
            cursor: pointer;
        }

        .selection-box-inner {
            padding: 10px;
        }

        a.btn {
            font-weight: normal !important;
            padding: 1px 6px;
            align-items: flex-start;
            text-align: center;
            cursor: default !important;
            color: buttontext !important;
            background-color: buttonface;
            box-sizing: border-box;
            border-width: 2px;
            border-style: outset;
            border-color: buttonface;
            border-image: initial;
            text-rendering: auto;
            letter-spacing: normal;
            word-spacing: normal;
            text-transform: none;
            text-shadow: none;
            -webkit-appearance: button;
            -webkit-writing-mode: horizontal-tb;
            font: 13.3333px Arial;
        }

        .btn.disabled {
            pointer-events: none;
            color: graytext !important;
        }

        span.selected-node {
            width: 100%;
            word-wrap: break-word;
            display: inline-block;
            font-size: 14px;
        }

        .browse-btns {
            margin-top: 10px;
        }
    </style>
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
    <script>
        $(document).ready(function () {
            $(".advanced-btn").on("click", function () {
                if ($(this).parent().hasClass("open")) {
                    $(this).parent().removeClass("open");
                } else {
                    $(this).parent().addClass("open");
                }

                $(".advanced-inner").slideToggle();
            });

            $(".ddDatabase").on("change", function () {
                if ($(this).find("option:selected").val() === "custom") {
                    $(".txtCustomDatabase").show();
                } else {
                    $(".txtCustomDatabase").hide();
                }

                if ($(this).find("option:selected").val() !== "master") {
                    $(".workflowBox input").each(function () {
                        $(this).prop("checked", false);
                    });
                }
            });

            $(".workflowBox input").on("change", function () {
                if ($(this).is(":checked")) {
                    $(".ddDatabase").val("master");
                }
            });

            $(".clear-btn").on("click", function () {
                var id = $(this).attr("data-id");
                var input = $("#" + id);
                $(input).val("");
                removeSavedMessage();
            });

            $("#clear-fast-query").on("click", function () {
                $(".lit-fast-query").html("");
            });

            $(".show-hints").on("click", function () {
                $(this).next(".notes").slideToggle();
            });

            $(".save-btn-decoy").on("click", function () {
                var saveName = $("#txtSaveSettingsName").val();
                if (saveName === "") {
                    $(".error-message").show();
                    $(".save-settings-box input[type='text']").css("border", "1px solid red");
                } else {
                    $("#btnSaveSettings").click();
                }
            });

            $("input").on("change", function () {
                removeSavedMessage();
            });

            $("select").on("change", function () {
                removeSavedMessage();
            });
        });

        function expandNode(node) {
            if ($(node).parent().hasClass("expanded")) {

                var children = $(node).parent().find("li");
                $(children).removeClass("expanded");
                var childBtns = $(node).parent().find(".browse-expand");
                $(childBtns).html("+");

                $(node).parent().removeClass("expanded");
                $(node).html("+");
            } else {
                $(node).parent().addClass("expanded");
                $(node).html("-");
            }
        }

        function selectNode(node) {
            $(".select-node-btn").removeClass("disabled");
            var nodePath = $(node).attr("data-path");
            $(".selected-node").html(nodePath);
        }

        function confirmSelection() {
            var nodePath = $(".selected-node").html();
            closeTreeBox();
            $("#inputStartitem").val(nodePath);
        }

        function closeTreeBox() {
            $(".browse-modal").hide();
        }

        function removeSavedMessage() {
            $(".save-message").html("");
        }



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



                <div class="main-btns">
                    <div class="left">
                        <asp:Button runat="server" ID="btnRunExport" OnClick="btnRunExport_OnClick" Text="Run Export" /><br />
                        <asp:Button runat="server" ID="btnClearAll" Text="Clear All" OnClick="btnClearAll_OnClick" CssClass="btn-clear-all" />
                    </div>

                    <div class="right">
                        <div class="save-settings-box">
                            <div class="row">
                                <span class="header">Enter a name to save: </span>
                                <input runat="server" id="txtSaveSettingsName" />
                                <input type="button" class="save-btn-decoy" value="Save Settings" />
                                <asp:Button runat="server" ID="btnSaveSettings" OnClick="btnSaveSettings_OnClick" Text="Save Settings" /><span class="save-message">
                                    <asp:Literal runat="server" ID="litSavedMessage"></asp:Literal></span><span class="error-message server"><asp:Literal runat="server" ID="litErrorMessage"></asp:Literal></span>

                                <span class="error-message">You must enter a name for this configuration<br />
                                </span>
                            </div>
                            <div class="row">
                                <span class="header">Saved settings: </span>
                                <asp:DropDownList runat="server" ID="ddSavedSettings" AutoPostBack="True" OnSelectedIndexChanged="ddSavedSettings_OnSelectedIndexChanged" /><br />
                            </div>
                        </div>
                    </div>
                </div>
                <br />
                <br />

                <div class="container">

                    <asp:PlaceHolder runat="server" ID="PhBrowseTree">
                        <div class="modal browse-modal">
                            <div class="selector-box">
                                <asp:Literal runat="server" ID="litSitecoreContentTree"></asp:Literal>
                            </div>
                            <div class="selection-box">
                                <div class="selection-box-inner">
                                    <span class="header">Selected node:</span><br />
                                    <span class="selected-node">(No node selected)</span>
                                    <div class="browse-btns">
                                        <a href="javascript:void(0)" class="btn disabled select-node-btn" onclick="confirmSelection();">Select</a>
                                        <a class="btn close-modal" onclick="closeTreeBox()">Cancel</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </asp:PlaceHolder>

                    <span class="header">Database</span>
                    <asp:DropDownList runat="server" ID="ddDatabase" CssClass="ddDatabase" /><input runat="server" class="txtCustomDatabase" id="txtCustomDatabase" style="display: none" />
                    <br />
                    <span class="notes">Select database. Defaults to web</span><br />
                    <br />

                    <asp:CheckBox runat="server" ID="chkIncludeIds" /><span class="header">Include IDs</span><br />
                    <span class="notes">Check this box to include item IDs (guid) in the exported file. Item paths are already included.</span><br />
                    <br />

                    <span class="header">Start Item</span><a class="clear-btn" data-id="inputStartitem">clear</a><br />
                    <span class="notes">Enter the path or ID of the starting node. Only content beneath and including this node will be exported. If field is left blank, the starting node will be /sitecore/content</span><br />
                    <input runat="server" id="inputStartitem" /><asp:Button runat="server" ID="btnBrowse" OnClick="btnBrowse_OnClick" CssClass="browse-btn" Text="Browse" />
                    <br />
                    <span>OR</span><br />
                    <span class="header">Fast Query</span><a class="clear-btn" id="clear-fast-query" data-id="txtFastQuery">clear</a><br />
                    <span class="notes">Enter a fast query to run a filtered export. You can use the Templates box as well.<br />
                        Example: fast:/sitecore/content/Home//*[@__Updated >= '20140610' and @__Updated <'20140611']</span><br />
                    <input runat="server" id="txtFastQuery" />
                    <asp:Button runat="server" ID="btnTestFastQuery" OnClick="btnTestFastQuery_OnClick" Text="Test" />
                    <span class="lit-fast-query">
                        <asp:Literal runat="server" ID="litFastQueryTest"></asp:Literal></span>
                    <br />
                    <br />

                    <span class="header">Templates</span><a class="clear-btn" data-id="inputTemplates">clear</a><br />
                    <span class="notes">Enter template names and/or IDs separated by commas. Items will only be exported if their template is in this list. If this field is left blank, all templates will be included</span><br />
                    <textarea runat="server" id="inputTemplates" cols="60" row="5"></textarea>
                    <br />

                    <div class="hints">
                        <a class="show-hints">Hints</a>
                        <span class="notes">Example: Standard Page, {12345678-901-2345-6789-012345678901}
                        </span>
                    </div>
                    <asp:CheckBox runat="server" ID="chkIncludeTemplate" />
                    <span class="header">Include Template Name</span><br />
                    <span class="notes">Check this box to include the template name with each item</span><br />
                    <br />


                    <span class="header">Fields</span><a class="clear-btn" data-id="inputFields">clear</a><br />
                    <span class="notes">Enter field names or IDs separated by commas</span><br />
                    <textarea runat="server" id="inputFields" cols="60" row="5"></textarea>
                    <br />
                    <br />




                    <div class="advanced">
                        <a class="advanced-btn">Advanced Options</a>
                        <div class="advanced-inner">

                            <asp:CheckBox runat="server" ID="chkIncludeLinkedIds" /><span class="header">Include linked item IDs </span><span class="notes">(images, links, droplists, multilists)</span><br />
                            <asp:CheckBox runat="server" ID="chkIncludeRawHtml" /><span class="header">Include raw HTML </span><span class="notes">(images and links)</span><br />

                            <asp:CheckBox runat="server" CssClass="workflowBox" ID="chkWorkflowName" /><span class="header">Workflow</span><br />
                            <asp:CheckBox runat="server" CssClass="workflowBox" ID="chkWorkflowState" /><span class="header">Workflow State</span>
                            <br />
                            <span class="notes">Workflow options require the database to be set to master</span>
                            <br />
                            <br />

                            <asp:CheckBox runat="server" ID="chkAllLanguages" /><span class="header">Get All Language Versions</span><br />
                            <span class="notes">This will get the selected field values for all languages that each item has an existing version for</span>
                            <br />
                            <br />

                            <asp:Button runat="server" ID="btnRunExportDupe" OnClick="btnRunExport_OnClick" Text="Run Export" /><br />
                            <br />

                            <asp:Button runat="server" ID="btnWebformsExport" OnClick="btnWebformsExport_OnClick" Text="Webforms" /><br />
                            <span class="notes">Download all Webforms for Marketers forms and fields</span>

                            <asp:CheckBox runat="server" ID="test" />
                        </div>
                    </div>
                    <br />

                    <span class="header">Content Import</span><br />
                    <span class="notes">Import an Excel sheet to make bulk content changes.
                        <br />
                        Recommended method is to run an export of all files you want to change, edit the fields in the downloaded file, and then import the edited file.<br />
                        Required columns are Item Path or Item ID</span><br />
                    <asp:FileUpload runat="server" ID="btnUploadImportFile" /><br />
                    <asp:Button runat="server" ID="btnRunImport" Text="Import" OnClick="btnRunImport_OnClick" />
                    <asp:Literal runat="server" ID="litImportMessage"></asp:Literal>

                </div>


            </div>

        </div>
    </form>
</body>
</html>
