/*
 * Returns css value for given attribute of a given css class.
 * 
 */
 
function getCSS(css_class, attribute){
  var value;
  var mocc;
  
  for (var s = document.styleSheets.length-1; s > 0; s--) {          
    var rules = document.styleSheets[s].rules || document.styleSheets[s].cssRules
    for (var x = 0; x < rules.length; x++) {
      if (rules[x].selectorText && rules[x].selectorText.toLowerCase() == css_class.toLowerCase()) {
        value = eval('rules[x].style.' + attribute);
        
        // fix by seeger@meso.net: IE6 returns undefined, which will break below
        value = value || '';
        
        // workaround: firefox seems to return values 4 times in a row (separated by 3 spaces)
        // sometimes. if this is the case, just use the first partial
        mocc = value.substring(0, (value.length - 3) / 4)
        if ([mocc,mocc,mocc,mocc].join(' ') == value)
          value = mocc;
          
        return value;
      }
    }
  }
}