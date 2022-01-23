(function() {

  $(function() {
    var C, result, tweet;
    result = $('#result');
    tweet = function(cs) {
      var d;
      d = $.when();
      return $.each(cs.reverse(), function(i, c) {
        return d = d.pipe(function() {
          return c.update();
        });
      });
    };
    C = (function() {

      function C(element) {
        this.element = element;
        this.element.css({
          color: '#ccc'
        });
      }

      C.prototype.update = function() {
        var element;
        element = this.element;
        return $.post('/update', {
          status: this.element.text(),
          _csrf: $('input[name="_csrf"]').val()
        }, function(json) {
          if (json.status === 'success') {
            return element.find('a').attr('href', json.url).css({
              color: '#0f0'
            });
          } else {
            return element.css({
              color: '#f00'
            });
          }
        });
      };

      return C;

    })();
    return $('#tweet_form').submit(function(e) {
      var cs, text, textarea;
      cs = [];
      textarea = $('textarea[name="status"]');
      text = textarea.val();
      console.log(text)
      chars = [...text]
      console.log(chars)
      $(this).hide();
      e.preventDefault();
      textarea.val('');
      $.each(chars, function(i, value) {
        var element;
        element = $("<span><a>" + value + "</a></span>");
        result.append(element);
        return cs.push(new C(element));
      });
      return tweet(cs);
    });
  });

}).call(this);
