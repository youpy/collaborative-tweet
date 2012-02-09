$(function() {
  var result = $('#result');
  var C = function(element) {
    this.element = element;
    element.css({color: '#ccc'});
  };
  C.prototype.update = function() {
    var that = this;
    return $.post('/update', {
      status: this.element.text(),
      _csrf: $('input[name="_csrf"]').val()
    }, function(json){
      if(json.status == 'success') {
        that.element.find('a').attr('href', json.url).css({color: '#0f0'});
      } else {
        that.element.css({color: '#f00'});
      }
    });
  };
  
  $('#tweet_form').submit(function(e) {
    $(this).hide();
    e.preventDefault();

    var cs = [];
    var textarea = $('textarea[name="status"]');
    var text = textarea.val();

    textarea.val('');
    $.each(text.split(''), function(i, value) {
      var element = $('<span><a>' + value + '</a></span>');

      result.append(element);
      cs.push(new C(element));
    });

    tweet(cs);
  });

  function tweet(cs) {
    var d = $.when();

    $.each(cs.reverse(), function(i, c) {
      d = d.pipe(function() {
        return c.update();
      });
    });
  }
});
