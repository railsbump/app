#= require jquery
#= require jquery_ujs
#= require turbolinks
#= require_tree .

onReady = ->
  $('#gems-search').keyup ->
    if $("#query").val().length
      $.get $(this).attr('action'), $(this).serialize(), null, 'script'
      false

$(document).ready onReady

$(document).on 'page:change', ->
  if window._gaq?
    _gaq.push ['_trackPageview']
  else if window.pageTracker?
    pageTracker._trackPageview()

  onReady()
