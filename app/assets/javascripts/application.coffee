#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_tree .

$ ->
  $('#gems-search').keyup ->
    $.get $(this).attr("action"), $(this).serialize(), null, "script"
    false
