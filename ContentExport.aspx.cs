using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using Sitecore.Data;
using Sitecore.Data.Fields;
using Sitecore.Data.Items;

namespace ContentExportTool
{
    public partial class ContentExport : Sitecore.sitecore.admin.AdminPage
    {
        private Database _db;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                var databases = new List<string>() {"web", "master", "custom"};
                ddDatabase.DataSource = databases;
                ddDatabase.DataBind();
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.CheckSecurity(true); //Required!
            base.OnInit(e);
        }

        protected bool SetDatabase()
        {
            var databaseName = ddDatabase.SelectedValue;
            if (chkWorkflowName.Checked || chkWorkflowState.Checked)
            {
                databaseName = "master";
            }
            else if (databaseName == "custom")
            {
                databaseName = txtCustomDatabase.Value;
            }

            if (String.IsNullOrEmpty(databaseName))
            {
                return false;
            }

            _db = Sitecore.Configuration.Factory.GetDatabase(databaseName);
            return true;
        }

        protected void SetDatabase(string databaseName)
        {
            _db = Sitecore.Configuration.Factory.GetDatabase(databaseName);
        }

        protected void btnRunExport_OnClick(object sender, EventArgs e)
        {
            litFastQueryTest.Text = "";

            try
            {
                var fieldString = inputFields.Value;
                var imageFieldString = inputImageFields.Value;
                var linkFieldString = inputLinkFields.Value;
                var multiFieldString = inputMultiFields.Value;
                var droplistFieldString = inputDroplistFields.Value;              

                var includeWorkflowState = chkWorkflowState.Checked;
                var includeworkflowName = chkWorkflowName.Checked;
               
                if (!SetDatabase())
                {
                    litFeedback.Text = "You must enter a custom database name, or select a database from the dropdown";
                    return;
                }

                
                if (_db == null)
                {
                    litFeedback.Text = "Invalid database. Selected database does not exist.";
                    return;
                }

                var fields = fieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));
                var imageFields = imageFieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));
                var linkFields = linkFieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));
                var multiFields = multiFieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));  
                var droplistFields = droplistFieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));

                var includeIds = chkIncludeIds.Checked;
                var includeImageIds = chkIncludeImageIds.Checked;
                var includeDroplistIds = chkIncludeDroplistIds.Checked;
                var includeMultilistIds = chkIncludeMultilistIds.Checked;
                var includeRawImages = chkIncludeRawImages.Checked;
                var includeRawLinks = chkIncludeRawLinks.Checked;

                var allLanguages = chkAllLanguages.Checked;               

                var templateString = inputTemplates.Value;
                var templates = templateString.ToLower().Split(',').Select(x => x.Trim());

                var startNode = inputStartitem.Value;
                if (String.IsNullOrEmpty(startNode)) startNode = "/sitecore/content";

                var fastQuery = txtFastQuery.Value;

                var exportItems = new List<Item>() { };

                if (!String.IsNullOrEmpty(fastQuery))
                {
                    var queryItems = _db.SelectItems(fastQuery);
                    exportItems = queryItems.ToList();
                }
                else
                {
                    Item startItem = _db.GetItem(startNode);
                    var descendants = startItem.Axes.GetDescendants();
                    exportItems.Add(startItem);
                    exportItems.AddRange(descendants);
                }                              
             
                List<Item> items = new List<Item>();
                if (!String.IsNullOrEmpty(templateString))
                {
                    foreach (var template in templates)
                    {
                        var templateItems = exportItems.Where(x => x.TemplateName.ToLower() == template || x.TemplateID.ToString().ToLower().Replace("{", string.Empty).Replace("}", string.Empty) == template.Replace("{", string.Empty).Replace("}", string.Empty));
                        items.AddRange(templateItems);
                    }
                }
                else
                {
                    items = exportItems.ToList();
                }

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}.xls", "ContentExport"));
                Response.Charset = "";
                Response.ContentType = "application/vnd.ms-excel";

                using (StringWriter sw = new StringWriter())
                {
                    var headingString = "Item\t" + (includeIds ? "Item ID (guid)\t" : string.Empty) 
                    + (allLanguages ? "Language\t" : string.Empty)
                    + GetExcelHeaderForFields(fields, false)
                    + GetExcelHeaderForFields(imageFields, includeImageIds, includeRawImages)
                    + GetExcelHeaderForFields(linkFields, false, includeRawLinks)
                    + GetExcelHeaderForFields(droplistFields, includeDroplistIds)
                    + GetExcelHeaderForFields(multiFields, includeMultilistIds)
                    + (includeworkflowName ? "Workflow\t" : string.Empty)
                    + (includeWorkflowState ? "Workflow State\t" : string.Empty );
                    sw.WriteLine(headingString);

                    foreach (var baseItem in items)
                    {
                        var itemVersions = new List<Item>();
                        if (allLanguages)
                        {
                            foreach (var language in baseItem.Languages)
                            {
                                var languageItem = baseItem.Database.GetItem(baseItem.ID, language);
                                if (languageItem.Versions.Count > 0)
                                {
                                    itemVersions.Add(languageItem);
                                }
                            }
                        }
                        else
                        {
                            itemVersions.Add(baseItem);
                        }

                        foreach (var item in itemVersions)
                        {
                            var itemPath = item.Paths.ContentPath;
                            var itemLine = itemPath + "\t";

                            if (allLanguages)
                            {
                                itemLine += item.Language.GetDisplayName() + "\t";
                            }

                            if (includeIds)
                            {
                                itemLine += item.ID + "\t";
                            }

                            foreach (var field in fields)
                            {
                                if (!String.IsNullOrEmpty(field))
                                {
                                    var itemField = item.Fields[field];
                                    if (itemField == null)
                                    {
                                        itemLine += "n/a\t";
                                    }
                                    else
                                    {
                                        itemLine += RemoveLineEndings(itemField.Value) + "\t";
                                    }
                                }
                            }

                            foreach (var field in imageFields)
                            {
                                if (!string.IsNullOrEmpty(field))
                                {
                                    ImageField itemField = item.Fields[field];
                                    if (itemField == null)
                                    {
                                        itemLine += "n/a\t";

                                        if (includeImageIds)
                                        {
                                            itemLine += "n/a\t";
                                        }

                                        if (includeRawImages)
                                        {
                                            itemLine += "n/a\t";
                                        }
                                    }
                                    else if (itemField.MediaItem == null)
                                    {

                                        itemLine += "\t";
                                        if (includeImageIds)
                                        {
                                            itemLine += "\t";
                                        }

                                        if (includeRawImages)
                                        {
                                            itemLine += "\t";
                                        }
                                    }
                                    else
                                    {
                                        itemLine += itemField.MediaItem.Paths.MediaPath + "\t";
                                        if (includeImageIds)
                                        {
                                            itemLine += itemField.MediaItem.ID + "\t";
                                        }

                                        if (includeRawImages)
                                        {
                                            itemLine += itemField.Value + "\t";
                                        }
                                    }
                                }
                            }

                            foreach (var field in linkFields)
                            {
                                if (!string.IsNullOrEmpty(field))
                                {
                                    LinkField itemField = item.Fields[field];
                                    if (itemField == null)
                                    {
                                        itemLine += "n/a\t";

                                        if (includeRawLinks)
                                        {
                                            itemLine += "n/a\t";
                                        }
                                    }
                                    else
                                    {
                                        itemLine += itemField.Url + "\t";

                                        if (includeRawLinks)
                                        {
                                            itemLine += itemField.Value + "\t";
                                        }
                                    }
                                }
                            }

                            foreach (var field in droplistFields)
                            {
                                ReferenceField fieldLink = item.Fields[field];
                                if (fieldLink == null)
                                {
                                    itemLine += "n/a\t";
                                    if (includeDroplistIds)
                                    {
                                        itemLine += "n/a\t";
                                    }
                                }
                                else if (fieldLink.TargetItem == null)
                                {
                                    itemLine += "\t";
                                    if (includeDroplistIds)
                                    {
                                        itemLine += "\t";
                                    }
                                }
                                else
                                {
                                    itemLine += fieldLink.TargetItem.DisplayName + "\t";
                                    if (includeDroplistIds)
                                    {
                                        itemLine += fieldLink.TargetID + "\t";
                                    }
                                }
                            }

                            foreach (var field in multiFields)
                            {
                                if (!string.IsNullOrEmpty(field))
                                {
                                    MultilistField itemField = item.Fields[field];
                                    if (itemField == null)
                                    {
                                        itemLine += "n/a\t";
                                        if (includeMultilistIds)
                                        {
                                            itemLine += "n/a\t";
                                        }
                                    }
                                    else
                                    {
                                        var multiItems = itemField.GetItems();
                                        var data = "";
                                        var first = true;
                                        foreach (var i in multiItems)
                                        {
                                            if (!first)
                                            {
                                                data += "\n";
                                            }
                                            var url = i.Paths.ContentPath;
                                            data += url + ";";
                                            first = false;
                                        }
                                        itemLine += "\"" + data + "\"" + "\t";

                                        if (includeMultilistIds)
                                        {
                                            first = true;
                                            var idData = "";
                                            foreach (var i in multiItems)
                                            {
                                                if (!first)
                                                {
                                                    idData += "\n";
                                                }
                                                idData += i.ID + ";";
                                                first = false;
                                            }
                                            itemLine += "\"" + idData + "\"" + "\t";
                                        }
                                    }
                                }
                            }

                            if (includeWorkflowState || includeworkflowName)
                            {
                                var workflowProvider = item.Database.WorkflowProvider;
                                if (workflowProvider == null)
                                {
                                    if (includeworkflowName && includeWorkflowState)
                                    {
                                        itemLine += "\t";
                                    }
                                    itemLine += "\t";
                                }
                                else
                                {
                                    var workflow = workflowProvider.GetWorkflow(item);
                                    if (workflow == null)
                                    {
                                        if (includeworkflowName && includeWorkflowState)
                                        {
                                            itemLine += "\t";
                                        }
                                        else
                                        {
                                            itemLine += "\t";
                                        }
                                    }
                                    else
                                    {
                                        if (includeworkflowName)
                                        {
                                            itemLine += workflow + "\t";
                                        }
                                        if (includeWorkflowState)
                                        {
                                            var workflowState = workflow.GetState(item);
                                            itemLine += workflowState.DisplayName + "\t";
                                        }
                                    }
                                }
                            }

                            sw.WriteLine(itemLine);
                        }                     
                    }

                    Response.Output.Write(sw.ToString());
                    Response.Flush();
                    Response.End();

                    litFeedback.Text = "";
                }
            }
            catch (Exception ex)
            {
                litFeedback.Text = ex.Message;
            }
        }

        public string GetFieldNameIfGuid(string field)
        {
            Guid guid;
            if (Guid.TryParse(field, out guid))
            {
                var fieldItem = _db.GetItem(field);
                if (fieldItem == null) return field;
                return fieldItem.Name;
            }
            else
            {
                return field;
            }
        }

        public string GetExcelHeaderForFields(IEnumerable<string> fields, bool includeId = false, bool includeRaw = false)
        {
            var header = "";
            foreach (var field in fields)
            {
                var fieldName = GetFieldNameIfGuid(field);

                header += fieldName + "\t";
                if (includeId)
                {
                    header += String.Format("{0} ID", fieldName) + "\t";
                }

                if (includeRaw)
                {
                    header += String.Format("{0} HTML", fieldName) + "\t";
                }
            }
            return header;
        }

        public string RemoveLineEndings(string value)
        {
            if (String.IsNullOrEmpty(value))
            {
                return value;
            }
            string lineSeparator = ((char)0x2028).ToString();
            string paragraphSeparator = ((char)0x2029).ToString();

            return value.Replace("\r\n", string.Empty).Replace("\n", string.Empty).Replace("\r", string.Empty).Replace(lineSeparator, string.Empty).Replace(paragraphSeparator, string.Empty).Replace("<br/>", string.Empty).Replace("<br />", string.Empty).Replace("\t", "   ");
        }

        protected void btnWebformsExport_OnClick(object sender, EventArgs e)
        {
            var startPath = "/sitecore/system/Modules/Web Forms for Marketers";
            Item startItem = _db.GetItem(startPath);

            var descendants = startItem.Axes.GetDescendants().Where(x => x.TemplateName == "Form");

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", String.Format("attachment;filename={0}.xls", "WebformsFieldData"));
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                sw.WriteLine("Form Name\tForm ID\tField Name\tField ID\tHTML ID\tField Type");

                foreach (var form in descendants)
                {
                    var formName = form.Name;
                    var fields = form.Axes.GetDescendants().Where(x => x.TemplateName == "Field");
                    var firstField = true;
                    foreach (var field in fields)
                    {
                        var fieldName = field.Name;
                        var fieldHtmlId = String.Format("form_{0}_field_{1}", FormatGuidForHtmlId(form.ID), FormatGuidForHtmlId(field.ID));
                        var fieldLink = GetFieldLink(field);

                        sw.WriteLine(String.Format("{0}\t{1}\t{2}\t{3}\t{4}\t{5}", (firstField ? formName : string.Empty), (firstField ? form.ID.ToString() : string.Empty), fieldName, field.ID.ToString(), fieldHtmlId, fieldLink));

                        firstField = false;
                    }
                }

                Response.Output.Write(sw.ToString());
                Response.Flush();
                Response.End();
            }
        }

        protected string FormatGuidForHtmlId(ID id)
        {
            return id.ToString().Replace("{", string.Empty).Replace("}", string.Empty).Replace("-", string.Empty);
        }

        protected string GetFieldLink(Item field)
        {
            ReferenceField fieldLink = field.Fields["Field Link"];
            if (fieldLink == null || fieldLink.TargetItem == null) return string.Empty;

            var val = fieldLink.TargetItem.DisplayName;
            var splitval = val.Split('/');
            return splitval[splitval.Length - 1];
        }

        protected void btnTestFastQuery_OnClick(object sender, EventArgs e)
        {
            if (!SetDatabase()) SetDatabase("web");

            var fastQuery = txtFastQuery.Value;
            if (String.IsNullOrEmpty(fastQuery)) return;

            try
            {
                var results = _db.SelectItems(fastQuery);
                if (results == null)
                {
                    litFastQueryTest.Text = "Query returned null";
                }
                else
                {
                    litFastQueryTest.Text = String.Format("Query returned {0} items", results.Length);
                }
            }
            catch (Exception ex)
            {
                litFastQueryTest.Text = "Error: " + ex.Message;
            }
            
        }
    }
}
