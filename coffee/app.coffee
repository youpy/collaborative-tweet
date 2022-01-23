$ () ->
  result = $('#result')

  tweet = (cs) ->
    d = $.when()
    $.each(cs.reverse()
      (i, c) ->
        d = d.pipe () ->
          c.update())

  class C
    constructor: (@element) ->
      @element.css color: '#ccc'
    update: () ->
      element = @element
      $.post '/update'
        status: @element.text()
        _csrf: $('input[name="_csrf"]').val()
        (json) ->
          if json.status == 'success'
            element.find('a').attr('href', json.url).
            css color: '#0f0'
          else
            element.css color: '#f00'

  $('#tweet_form').submit (e) ->
    cs = []
    textarea = $('textarea[name="status"]');
    text = textarea.val()
    chars = [...text]
    $(this).hide()
    e.preventDefault();
    textarea.val('')
    $.each(chars
      (i, value) ->
        element = $("<span><a>#{value}</a></span>")
        result.append element
        cs.push new C(element))

    tweet cs
