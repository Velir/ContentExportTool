<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentExport.aspx.cs" Inherits="ContentExportTool.ContentExport" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Content Export Tool</title>
    <style>
		.header {color: brown}
		.notes {color: GrayText; font-size: 12px}
		.container {margin-bottom: 10px; font-family: Arial}
	</style>

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
                    
                    <asp:Checkbox runat="server" ID="chkIncludeIds"/><span class="header">Include IDs</span><br/>
                    <span class="notes">Check this box to include item IDs (guid) in the exported file. Item paths are already included.</span><br/><br/>

                    <span class="header">Start Item</span><br/>
                     <span class="notes">Enter the path of the starting node. Only content beneath and including this node will be exported. If field is left blank, the starting node will be /sitecore/content</span><br/>
                    <input runat="server" ID="inputStartitem"/>
                    <br/>
                   <br/>
                    
                    <span class="header">Templates</span><br/>
                     <span class="notes">Enter template names separated by commas. Items will only be exported if their template name is in this list. If this field is left blank, all templates will be exported</span><br/>
                    <textarea runat="server" ID="inputTemplates" cols="40" rows="10"></textarea>
                    <br/>
                   <br/>

                    <span class="header">Text Fields</span><br/>
                    <span class="notes">Enter field names separated by commas</span><br/>
                    <textarea runat="server" ID="inputFields" cols="40" rows="10"></textarea>
                    <br /><br/>
                    
                    <span class="header">Image Fields</span><br/>
                    <span class="notes">Enter field names separated by commas</span><br/>
                    <textarea runat="server" ID="inputImageFields" cols="40" rows="10"></textarea>
                    <br /><br/>
                    
                    <span class="header">Link Fields</span><br/>
                    <span class="notes">Enter field names separated by commas</span><br/>
                    <textarea runat="server" ID="inputLinkFields" cols="40" rows="10"></textarea>
                    <br /><br/>
                    
                    <span class="header">Multilist Fields</span><br/>
                    <span class="notes">Enter field names separated by commas</span><br/>
                    <textarea runat="server" ID="inputMultiFields" cols="40" rows="10"></textarea>
                    <br />
                    
                </div>
                
                
            </div>

        </div>
    </form>
</body>
</html>
