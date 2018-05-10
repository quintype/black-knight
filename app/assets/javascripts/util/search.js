module.exports = function searchPub(e){
  var inputText = e?e.target.value:'';
  var allElements = document.querySelectorAll('.leftbar-publisher');
  if(inputText.length > 2){
    var targetElements = document.querySelectorAll('a[data-publisher*='+inputText+']');
    allElements
      .forEach(function(el){
        el.style.display = "none";
      })
    targetElements
      .forEach(function(el){
        el.parentElement.style.removeProperty('display');
      })
  }
  else{
    allElements
      .forEach(function(el){
        el.style.removeProperty('display');
      }) 
  }
}
