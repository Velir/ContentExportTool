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

function selectTemplate(node) {
    $(".browse-modal.templates a").removeClass("selected");
    $(node).addClass("selected");
    $(".temp-selected").html($(node).html());
}

function addTemplate() {
    var name = $(".temp-selected").html();
    var node = $(".select-templates a[data-id='" + name + "']");
    $(node).hide();
    $(".selected-templates-list").append("<li><a class='addedTemplate' href='javascript:void(0);' onclick='selectAddedTemplate($(this))' data-id='" + name + "' >" + name + "</a></li>");
    $(".temp-selected").html("");

    $(".selected-templates .select-node-btn").removeClass("disabled");
}

function selectAddedTemplate(node) {
    $(".browse-modal.templates a").removeClass("selected");
    $(node).addClass("selected");
    $(".temp-selected-remove").html($(node).html());
}

function removeTemplate() {
    var name = $(".temp-selected-remove").html();
    var node = $(".selected-templates a.addedTemplate[data-id='" + name + "']");
    $(node).parent().remove();
    var origNode = $(".select-templates a[data-id='" + name + "']");
    origNode.show();

    enableDisableSelect();
}

function enableDisableSelect() {
    var selectedTemplates = $(".selected-templates ul li");
    if (selectedTemplates.length < 1) {
        $(".selected-templates .select-node-btn").addClass("disabled");
    }
}

function confirmTemplateSelection() {
    var templateString = "";
    var selectedTemplates = $(".selected-templates ul li");
    for (var i = 0; i < selectedTemplates.length; i++) {
        if (i > 0) {
            templateString += ", ";
        }
        templateString += $(selectedTemplates[i]).find("a").html();
    }
    $("#inputTemplates").html(templateString);
    closeTemplatesModal();
}

function closeTemplatesModal() {
    $(".browse-modal.templates").hide();
}