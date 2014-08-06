// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var PT = PT || {};

PT.validateInputs = function($section){
  var inputs = Array.prototype.slice.call($section.find("textarea, input"));
  var emptyCount = 0;

  inputs.forEach(function(input){
    input.value === "" ? emptyCount += 1 : emptyCount;
  });

  return emptyCount;
};