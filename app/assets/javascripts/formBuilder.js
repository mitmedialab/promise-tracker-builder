$(document).ready(function(){
});

var PT = PT || {};

/// Input type defaults
PT.defaultControls = {
  inputText: {
    input_type: "string"
  },

  inputNumber: {
    input_type: "int"
  },

  inputDate: {
    input_type: "date"
  },

  inputLocation: {
    input_type: "geopoint"
  }
};

/// Input constructor
PT.Input = function(){
  var self = this;

  self.id = "";
  self.form_id = PT.form.id;
  self.label = ko.observable();
  self.input_type = ko.observable();
  self.required = ko.observable(false);
  self.options = ko.observable();
  self.order = "";
  self.inEdit = ko.observable();

  self.save = function(self, event){
    console.log(event);

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
  };

  self.map = function(data){
    self.id = data.id;
    self.form_id = data.form_id;
    self.label = ko.observable(data.label);
    self.input_type = ko.observable(data.input_type);
    self.required = ko.observable(data.required);
    self.options = ko.observable(data.options);
    self.order = data.order;
    self.inEdit = ko.observable(false);
  }; 

  self.edit = function(){
    self.inEdit(true);
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
    .done(function(response) {
      console.log(response);
    });  
  };

  /// Update order of all inputs
  self.save = function(){
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
    $.post("/forms", {id: self.id, title: self.title}, function(response) {
      console.log(response);
      if(self.id === ""){
        self.id = response.id;
      }

      $("#newFormModal").modal("hide");
    });
  };

  self.populateInputs = function(data) {
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
