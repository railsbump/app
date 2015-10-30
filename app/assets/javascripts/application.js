//= require jquery
//= require jquery_ujs
//= require_tree .

$(document).on("page:change", function() {
  $('#gems-search').on("input", null, null, function() {
    var query = $(this).serialize();
    if(query.length > 0) {
      $.get($(this).attr('action'), query, null, 'script')
    }
    return false;
  });
});

//$(document).on 'page:change', ->
  //if window._gaq?
    //_gaq.push ['_trackPageview']
  //else if window.pageTracker?
    //pageTracker._trackPageview()

  //onReady()
