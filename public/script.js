$(function(){
  $(".blame").hover(function() {
    if (!$(this).hasClass("load"))
      return;
    var sha1 = $(this).attr("data-blame-sha1");
    $.getJSON("/commitHeader/" + sha1, function (commitHeader) {
      var title = commitHeader.date + "\n";
      title += commitHeader.author + "\n\n";
      title += commitHeader.message.trim();
      var dataBlameSha1Selector = '*[data-blame-sha1="' + sha1 + '"]';
      $(dataBlameSha1Selector).attr("title", title).removeClass("load");
    });
  }, function() {
      // unhover
  });
});
