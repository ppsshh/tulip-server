$(document).on('click', '.remove-tag-link', function(){
  var tag_id = $(this).data("tag-id");
  var obj_type = $(this).data("parent-type");
  var obj_id = $(this).data("parent-id");
  var this_parent = $(this).parent();

  $.ajax({
    url: "/tag/remove",
    method: "POST",
    data: {obj_type: obj_type, obj_id: obj_id, tag_id: tag_id}
  }).done(function(data){
    this_parent.remove();
  });
});

$(document).on('click', '.tags-block', function(){
  $(this).find('.new-tag-input').focus();
});

$(document).on('click', '.cmus-link', function(){
  var album_id = $(this).data("album-id");
  var url = $(this).data("url");

  $.ajax({
    url: url,
    method: "POST",
    data: {id: album_id}
  });
});

$(document).on('click', '.release-edit-button', function(){
  var id = $(this).data("release-id");
  $.ajax({
    url: $(this).data("url"),
    method: "GET"
  }).done(function(data){
    $("#release-line-" + id).html(data);
  });
});

$(document).on('click', '.release-cancel-button', function(){
  var id = $(this).data("release-id");
  $.ajax({
    url: $(this).data("url"),
    method: "GET"
  }).done(function(data){
    $("#release-line-" + id).html(data);
  });
});

$(document).on('click', '.release-save-button', function(){
  var id = $(this).data("release-id");
  var serialized_form = $(this).parent().serialize();
  $("#release-line-" + id + " input").prop("disabled", true);

  $.ajax({
    url: $(this).data("url"),
    method: "POST",
    data: serialized_form
  }).done(function(data){
    $("#release-line-" + id).html(data);
  });
});

$(document).on('mouseenter', '.release-line', function(){
  var textArea = $(this).find('.title-romaji');
  textArea.text(textArea.data("romaji"));
});

$(document).on('mouseleave', '.release-line', function(){
  var textArea = $(this).find('.title-romaji');
  textArea.text(textArea.data("title"));
});

