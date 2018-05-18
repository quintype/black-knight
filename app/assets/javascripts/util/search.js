module.exports = function searchPub(e){
  var inputText = e?e.target.value:0;
  var allElements = document.querySelectorAll('.leftbar-publisher');
  var targetElements = document.querySelectorAll(inputText?'a[data-publisher*='+inputText+']':'.leftbar-publisher-name');
  allElements
    .forEach(function(el){
      el.classList.add('hide-item');
    })
  targetElements
    .forEach(function(el){
      el.parentElement.classList.remove('hide-item');
    })
  
}
