using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Glass.Sitecore.Mapper;
using Sitecore.Data;
using Sitecore.Data.Fields;
using Sitecore.Data.Items;
using Field = Sitecore.Forms.Data.Field;

namespace ContentExportTool
{
    public partial class ContentExport : Sitecore.sitecore.admin.AdminPage
    {
        private readonly Database _db = Sitecore.Configuration.Factory.GetDatabase("web");

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected override void OnInit(EventArgs e)
        {
            base.CheckSecurity(true); //Required!
            base.OnInit(e);
        }

        protected void btnRunExport_OnClick(object sender, EventArgs e)
        {
            try
            {
                var fieldString = inputFields.Value;
                var imageFieldString = inputImageFields.Value;
                var linkFieldString = inputLinkFields.Value;
                var multiFieldString = inputMultiFields.Value;
                if (String.IsNullOrEmpty(fieldString) && String.IsNullOrEmpty(imageFieldString) && String.IsNullOrEmpty(linkFieldString) && String.IsNullOrEmpty(multiFieldString))
                {
                    litFeedback.Text = "You must enter at least one field";
                    return;
                }
                var fields = fieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));
                var imageFields = imageFieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));
                var linkFields = linkFieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));
                var multiFields = multiFieldString.Split(',').Select(x => x.Trim()).Where(x => !String.IsNullOrEmpty(x));

                var includeIds = chkIncludeIds.Checked;

                var startNode = inputStartitem.Value;
                if (String.IsNullOrEmpty(startNode)) startNode = "/sitecore/content";

                var templateString = inputTemplates.Value;
                var templates = templateString.ToLower().Split(',').Select(x => x.Trim());

                Item startItem = _db.GetItem(startNode);

                var exportItems = new List<Item>() {startItem};
                var descendants = startItem.Axes.GetDescendants();

                exportItems.AddRange(descendants);

                List<Item> items = new List<Item>();
                if (!String.IsNullOrEmpty(templateString))
                {
                    foreach (var template in templates)
                    {
                        var templateItems = exportItems.Where(x => x.TemplateName.ToLower() == template);
                        items.AddRange(templateItems);
                    }
                }
                else
                {
                    items = descendants.ToList();
                }

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", String.Format("attachment;filename={0}.xls", "ContentExport"));
                Response.Charset = "";
                Response.ContentType = "application/vnd.ms-excel";

                using (StringWriter sw = new StringWriter())
                {
                    var headingString = "Item\t" + (includeIds ? "Item ID (guid)\t" : string.Empty) + fields.Aggregate("", (current, field) => current + (field + "\t"))
                    + imageFields.Aggregate("", (current, field) => current + (field + "\t"))
                    + linkFields.Aggregate("", (current, field) => current + (field + "\t"))
                    + multiFields.Aggregate("", (current, field) => current + (field + "\t"));
                    sw.WriteLine(headingString);

                    foreach (var item in items)
                    {
                        var itemPath = item.Paths.ContentPath;
                        var itemLine = itemPath + "\t";

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
                                }
                                else if (itemField.MediaItem == null)
                                {

                                    itemLine += "\t";
                                }
                                else
                                {
                                    itemLine += itemField.MediaItem.Paths.MediaPath + "\t";
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
                                }
                                else
                                {
                                    itemLine += itemField.Url + "\t";
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
                                }
                            }
                        }

                        sw.WriteLine(itemLine);

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

        public string RemoveLineEndings(string value)
        {
            if (String.IsNullOrEmpty(value))
            {
                return value;
            }
            string lineSeparator = ((char)0x2028).ToString();
            string paragraphSeparator = ((char)0x2029).ToString();

            return value.Replace("\r\n", string.Empty).Replace("\n", string.Empty).Replace("\r", string.Empty).Replace(lineSeparator, string.Empty).Replace(paragraphSeparator, string.Empty).Replace("<br/>", string.Empty).Replace("<br />", string.Empty);
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
    }
}
