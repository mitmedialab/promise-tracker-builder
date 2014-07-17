$(document).ready(function() {
  $(".modal").on('shown.bs.modal', function() {
    $(this).find("[autofocus]:first").focus();
  });
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
  self.survey_id = PT.survey.id;
  self.label = ko.observable();
  self.input_type = ko.observable();
  self.media_type = ko.observable();
  self.required = ko.observable(false);
  self.options = ko.observableArray([]);
  self.order = "";
  self.inEdit = ko.observable();

  self.save = function(self, event){

    if(self.label()){
      $("#message").fadeOut();
      self.inEdit(false);

      $.ajax({
        url: "/surveys/" + PT.survey.id + "/inputs",
        type: "POST",
        contentType: "application/json",
        dataType: "json",
        data: ko.toJSON(self)
      })
      .done(function(response) {
        console.log(response);
        $("#new-survey-modal").modal("hide");

        if(self.id === ""){
          self.id = response.id;
        }
      });
    } else {
      var input = $(event.target).closest(".input");
      PT.flashMessage(PT.flash["no_question_text"], input);
    }
  };

  self.map = function(data){
    self.id = data.id;
    self.survey_id = data.survey_id;
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

  self.addOption = function(){
    self.options.push("");
  };

  self.deleteOption = function(option, event){
    self.options.remove(option);
  };
};


/// Survey Constructor
PT.SurveyModel = function(){
  var self = this;

  self.id = "";
  self.title = ko.observable();
  self.inputs = ko.observableArray([]);
  self.status= ko.observable("editing");

  self.addInput = function(event){
    event.stopPropagation();
    var type = $(event.target).attr("rel");
    var input = new PT.Input();
    input.inEdit(true);
    input.input_type(PT.defaultControls[type]["input_type"]);
    input.media_type(PT.defaultControls[type]["media_type"]);
    self.inputs.push(input);
  };

  self.removeInput = function(){

    if(this.id === ""){
      self.inputs.remove(this);
    } else {
      var confirmed = window.confirm("Are you sure you want to delete this question?");
      
      if(confirmed){
        self.inputs.remove(this);
        $.ajax({
          url: "/surveys/" + PT.survey.id + "/inputs/" + this.id,
          type: "DELETE",
          contentType: "application/json",
          dataType: "json"
        })
        .done(function(response){
          console.log(response);
        });  
      }
    }
  };

  /// Update order of all inputs
  self.saveOrder = function(){
    // Hack
    window.location.pathname = Routes.user_path(PT.survey.user_id);
    
    $.ajax({
      url: "/surveys/" + PT.survey.id,
      type: "PUT",
      contentType: "application/json",
      dataType: "json",
      data: ko.toJSON(self)
    });

  };

  /// Add/update survey name
  self.saveName = function(){
    if($("#new-survey-title").val()){
      $.post("/surveys/", {id: self.id, title: self.title}, function(response){

        if(self.id === ""){
          self.id = response.id;
          self.user_id = response.user_id;
        }

        $("#new-survey-modal").modal("hide");
      });
    } else {
      PT.flashMessage(PT.flash["no_title"], $("#new-survey-title"));
    }
  };

  self.populateInputs = function(data){
    data.forEach(function(input){
      var newInput = new PT.Input();
      newInput.map(input);
      self.inputs.push(newInput);
    });

    self.inputs.sort(function(a,b){return a.order - b.order;});
    PT.selectedInput = ko.observable(self.inputs()[0]);
  };
};

PT.getSurvey = function(url){
  $.getJSON(url, null, function(response, textStatus) {
    PT.survey = new PT.SurveyModel();

    PT.survey.id = response.id;
    PT.survey.user_id = response.user_id;
    PT.survey.title = ko.observable(response.title);
    PT.survey.status = ko.observable(response.status);
    PT.survey.populateInputs(response.inputs);
    ko.applyBindings(PT.survey);

    $("#tool-palette .tool-button").on("click", PT.survey.addInput);
  });
};

PT.flashMessage = function(message, element){
  $("#message").remove();
  element.after(HandlebarsTemplates["flash_message"]({text: message})).fadeIn();
  $("#message").delay(2000).fadeOut();
};

PT.launchSurvey = function(){
  if(PT.form.inputs() > 0){
    window.location.pathname = Routes.launch_survey_path(PT.survey.id);
  } else {
    PT.flashMessage(PT.flash["no_questions"], $("#new-survey-title"));
  }
};
