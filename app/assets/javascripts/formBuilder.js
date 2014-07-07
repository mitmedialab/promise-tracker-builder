$(document).ready(function(){
});

var PT = PT || {};

/// Input type defaults
PT.defaultControls = {
  inputText: {
    input_type: "string"
  },

  inputNumber: {
    input_type: "decimal"
  },

  inputDate: {
    input_type: "date"
  },

  inputLocation: {
    input_type: "geopoint"
  },

  inputImage: {
    input_type: "binary",
    media_type: "image/*"
  },

  inputSelectMany: {
    input_type: "select"
  },

  inputSelectOne: {
    input_type: "select1"
  }
};

/// Input constructor
PT.Input = function(){
  var self = this;

  self.id = "";
  self.form_id = PT.form.id;
  self.label = ko.observable();
  self.input_type = ko.observable();
  self.media_type = ko.observable();
  self.required = ko.observable(false);
  self.options = ko.observableArray([]);
  self.order = "";
  self.inEdit = ko.observable();

  self.save = function(self, event){
    // self.saveOptions(event);

    if(self.label()){
      $("#message").fadeOut();
      self.inEdit(false);

      $.ajax({
        url: "/forms/" + PT.form.id + "/inputs",
        type: "POST",
        contentType: "application/json",
        dataType: "json",
        data: ko.toJSON(self)
      })
      .done(function(response) {
        console.log(response);
        $("#newFormModal").modal("hide");

        if(self.id === ""){
          self.id = response.id;
        }
      });
    } else {
      var input = $(event.target).closest(".input");
      PT.flashMessage("Please enter question text", input);
    }
  };

  self.map = function(data){
    self.id = data.id;
    self.form_id = data.form_id;
    self.label = ko.observable(data.label);
    self.input_type = ko.observable(data.input_type);
    self.media_type = ko.observable(data.media_type);
    self.required = ko.observable(data.required);
    self.options = ko.observableArray(_.values(data.options));
    self.order = data.order;
    self.inEdit = ko.observable(false);
  }; 

  self.edit = function(){
    self.inEdit(true);
  };

  // self.saveOptions = function(event){
  //   var options = Array.prototype.slice.call($(event.target).parent().siblings('.options').children('input'));
  //   options.forEach(function(option){
  //     self.options().push(option.value);
  //   });
  // };

  self.addOption = function(){
    self.options.push("");
  };

  self.deleteOption = function(option, event){
    self.options.remove(option);
  };
};


/// Form Constructor
PT.FormModel = function(){
  var self = this;

  self.id = "";
  self.title = ko.observable();
  self.inputs = ko.observableArray([]);

  self.addInput = function(event){
    var type = $(event.target).attr("rel");
    var input = new PT.Input();
    input.inEdit(true);
    input.input_type(PT.defaultControls[type]["input_type"]);
    input.media_type(PT.defaultControls[type]["media_type"]);
    self.inputs.push(input);
  };

  self.removeInput = function(){
    self.inputs.remove(this);

    $.ajax({
      url: "/forms/" + PT.form.id + "/inputs/" + this.id,
      type: "DELETE",
      contentType: "application/json",
      dataType: "json"
    })
    .done(function(response){
      console.log(response);
    });  
  };

  /// Update order of all inputs
  self.saveOrder = function(){
    $.ajax({
      url: "/forms/" + PT.form.id,
      type: "PUT",
      contentType: "application/json",
      dataType: "json",
      data: ko.toJSON(self)
    })
    .done(function(response){
      console.log(response);
    });
  };

  /// Add/update form name
  self.saveName = function(){
    if(self.title()){
      $.post("/forms", {id: self.id, title: self.title}, function(response){
        console.log(response);
        if(self.id === ""){
          self.id = response.id;
        }

        $("#newFormModal").modal("hide");
      });
    } else {
      PT.flashMessage("Please enter a title", $("#newFormTitle"));
    }
  };

  self.populateInputs = function(data){
    data.forEach(function(input){
      var newInput = new PT.Input();
      newInput.map(input);
      self.inputs.push(newInput);
    });

    self.inputs.sort(function(a,b){return a.order - b.order;});
  };
};

PT.getForm = function(url){
  $.getJSON(url, null, function(response, textStatus) {
    PT.form = new PT.FormModel();

    PT.form.id = response.id;
    PT.form.title = ko.observable(response.title);
    PT.form.populateInputs(response.inputs);
    ko.applyBindings(PT.form);

    $(document).on("click", "#toolPalette li", PT.form.addInput);
  });
};

PT.flashMessage = function(message, element){
  $("#message").remove();
  element.after(HandlebarsTemplates["flash_message"]({text: message})).fadeIn();
  $("#message").delay(2000).fadeOut();
};
