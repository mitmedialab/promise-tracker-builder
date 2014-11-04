/*
  Dispatcher module
  by: wangyu (bigeyex@gmail.com)
  dispatch global event
  usage:
  - fire an event:
  dispatcher.dispatch('example.event.name', arg1, arg2...)
  - subscribe an event:
  dispatcher.subscribe('example.event.name', function(arg1, arg2...){}); 
*/

function Dispatcher(){
  this.eventList = {};
  var self = this;
  this.subscribe = function(eventName, eventHandler){
    if(self.eventList[eventName]===undefined){
      self.eventList[eventName] = [];
    }
    self.eventList[eventName].push(eventHandler);
  };

  this.dispatch = function(eventName){
    var args = Array.prototype.slice.call(arguments);
    args.shift();
    var eventList = self.eventList[eventName];
    if(eventList!==undefined){
      for(var i in eventList){
      eventList[i].apply(this, args);
      }
    }
  };
}

window.dispatcher = new Dispatcher();