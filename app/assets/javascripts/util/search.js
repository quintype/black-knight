module.exports = function searchPub(e){
  var inputText = e?e.target.value:0;
  var allElements = document.querySelectorAll('.leftbar-publisher');
  var targetElements = document.querySelectorAll(inputText?'a[data-publisher*='+inputText+']':'.leftbar-publisher-name');
  allElements
    .forEach(function(el){
      el.style.display = "none";
    })
  targetElements
    .forEach(function(el){
      el.parentElement.style.display = 'list-item';
    })
  
}
