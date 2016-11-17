$(function(){
  $(".blame").hover(function() {
    if (!$(this).hasClass("load"))
      return;
    var classList = $(this).prop('classList');
    var blameSha1 = null;
    var sha1 = null;
    $.each(classList, function(i, v) {
      if (v.startsWith("blame-")) {
        blameSha1 = v;
        sha1 = v.substring(6);
        return false;
      }
    });
    $.getJSON("/commitHeader/" + sha1, function (commitHeader) {
      var title = commitHeader.date + "\n";
      title += commitHeader.author + "\n\n";
      title += commitHeader.message.trim();
      var blameSha1Class = "." + blameSha1;
      var withBlameSha1 = $(blameSha1Class);
      withBlameSha1.attr("title", title).removeClass("load");
    });
  }, function() {
      // unhover
  });
});
