$(document).ready(function() {
    $(".fixTable").tableHeadFixer({"left" : 1});

    var modal = $("#myModal");
    var selectedCell = null;
    $(".fixTable td").click(function() {
        if( $(".fixTable thead th").length > 2 ) {
            return;
        }
        modal.find("textarea").val($(this).text());
        var index = $(this).index();
        modal.find("h2").text($(".fixTable thead th").eq(index).text());
        var date = new Date($(this).data("date"));
        modal.find("h3").text(date.toLocaleDateString("ru-RU"));
        modal.find("#date").val($(this).data("date"));
        modal.find("#id").val($(this).data("rec-id"));
        modal.find("#empId").val($(this).data("empId"));
        modal.show();
        selectedCell = $(this);
    });

    $("#myModal .close").click(function() {
        modal.hide();
        selectedCell = null;
    });

    modal.find(".save").click(function(){
        var id = modal.find("#id").val();
        $.ajax({
            contentType: 'application/json',
            data: JSON.stringify(getFormData(modal.find(":input"))),
            dataType: 'json',
            success: function(data){
                updateData(data);
                $("#myModal .close").click();
            },
            error: function(){
                alert("Ошбика при сохранении");
            },
            processData: false,
            type: id == "" ? 'POST' : 'PATCH',
            url: id == "" ? '/times' : '/times/' + id
        });
    });
    modal.find(".delete").click(function(){
        var id = modal.find("#id").val();
        if(confirm("Удалить запись?")) {
            $.ajax({
                contentType: 'application/json',
                data: null,
                success: function(data){
                    selectedCell.data("rec-id", null);
                    selectedCell.text("");
                    $("#myModal .close").click();
                },
                error: function(){
                    alert("Ошбика при удалении");
                },
                processData: false,
                type: 'DELETE',
                url: '/times/' + id
            });
        }

    });

    function updateData(data) {
        selectedCell.data("date", data.date);
        selectedCell.data("rec-id", data.id);
        selectedCell.data("empId", data.employe_id);
        selectedCell.html(data.note.replace(/\n/gi, '<br />'));
    }

    function getFormData($form){
        var unindexed_array = $form.serializeArray();
        var indexed_array = {};

        $.map(unindexed_array, function(n, i){
            indexed_array[n['name']] = n['value'];
        });

        return indexed_array;
    }

    window.onclick = function(event) {
        if (event.target == modal.get(0)) {
            modal.hide();
            selectedCell = null;
        }
    }
});
