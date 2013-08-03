$(document).ready(function() {
    $('.datetime_select').datetimepicker({
        dateFormat: 'yy-mm-dd',
    timeFormat: 'hh:mm tt'
    });

    $('.search-c').searchbox({
        url: '/event_search.html',
        param: 'q',
        dom_id: '#search-data',
        delay: 100
    })

});
