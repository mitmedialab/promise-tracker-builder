$(document).ready(function() {

  // $('.modal').on('shown.bs.modal', function() {
  //   $(this).find('[autofocus]').focus();
  // });

  $(document).on("focus", "input", function(){
    $(this).on("mouseup.a keyup.a", function(e){      
      $(this).off("mouseup.a keyup.a").select();
    });
  });

  // Make input buttons draggable

  $(".tool-button").draggable({ 
    helper: function(event){
      return $(event.target).clone().addClass("drag-insert").css({
        "list-style-type": "none",
        background: "white",
        width: $(event.target).width() + 20,
        border: "1px solid grey"
      });},  
    appendTo: 'body',
    revert: 'invalid',
    connectToSortable: '#input-list'
  });

  $("#input-list").sortable({
    stop: function(event, ui){
      ui.item.addClass("drag-insert");
      ui.item.trigger("click");
    }
  });
});

var PT = PT || {};

/// Input type defaults
PT.defaultControls = {
  inputText: {
    label: "Text",
    input_type: "string"
  },

  inputNumber: {
    label: "Number",
    input_type: "int"
  },

  inputDate: {
    label: "Date",
    input_type: "date"
  },

  inputLocation: {
    label: "Location",
    input_type: "geopoint"
  },

  inputImage: {
    label: "Image",
    input_type: "binary",
    media_type: "image/*"
  },

  inputSelectMany: {
    label: "Select one",
    input_type: "select1"
  },

  inputSelectOne: {
    label: "Select many",
    input_type: "select"
  },
};

/// Input constructor
PT.Input = function(){
  var self = this;

  self.id = ko.observable("");
  self.survey_id = PT.survey.id;
  self.label = ko.observable("");
  self.input_type = ko.observable();
  self.decimal = false;
  self.media_type = ko.observable();
  self.annotate = ko.observable(false);
  self.required = ko.observable(false);
  self.options = ko.observableArray(["Option 1"]);
  self.order = "";
  self.inEdit = ko.observable(true);

  self.save = function(self, event){

    if(self.label()){
      $("#message").fadeOut();
      self.inEdit(false);
      self.options(self.options().filter(function(option) { return option.length > 0;}));

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

        if(self.id() === ""){
          self.id(response.id);
        }
      });
    } else {
      var input = $(event.target).closest(".input");
      PT.flashMessage(PT.flash["no_question_text"], input);
    }
  };

  self.map = function(data){
    self.id = ko.observable(data.id);
    self.survey_id = data.survey_id;
    self.label = ko.observable(data.label);
    self.input_type = ko.observable(data.input_type);
    self.decimal = data.input_type === 'decimal';
    self.media_type = ko.observable(data.media_type);
    self.required = ko.observable(data.required);
    self.options = ko.observableArray(_.values(data.options));
    self.order = data.order;
    self.inEdit = ko.observable(false);
  }; 

  self.edit = function(){
    self.inEdit(true);
    PT.selectedInput(self);
  };

  self.addOption = function(input, event){
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
  self.status= ko.observable("draft");

  self.addInput = function(event){
    event.stopPropagation();
    // self.saveInputs()

    var input = new PT.Input();
    var type = PT.defaultControls[$(event.currentTarget).attr("rel")];
    var index;
    
    if(type){
      input.input_type(type["input_type"]);
      input.media_type(type["media_type"]);
    }

    if($(event.target).hasClass("drag-insert")){
      index = $(event.target).index();
      $(event.target).remove();
    } else {
      index = self.inputs().length;
    }

    self.inputs.splice(index, 0, input);
    PT.selectedInput(input);
  };

  self.saveInputs = function(){
    var unsaved = self.inputs().filter(function(input) { return input.inEdit() == true ;});
    unsaved.forEach(function(input){input.save(input); });
  };

  self.removeInput = function(){
    if(this.label() !== ""){
      var confirmed = window.confirm("Are you sure you want to delete this question?");
    
      if(confirmed){
        self.inputs.remove(this);
        if(this.id() !== ""){
          $.ajax({
            url: "/surveys/" + PT.survey.id + "/inputs/" + this.id(),
            type: "DELETE",
            contentType: "application/json",
            dataType: "json"
          })
          .done(function(response){
            console.log(response);
          });
        }  
      }
    } else {
      self.inputs.remove(this);
    }
    self.inputs.length === 0 ? PT.selectedInput("") : false;
  };

  self.addStarterQuestion = function(){
    var input = new PT.Input();
    input.label(PT.flash.first_question);
    input.inEdit(true);
    input.input_type("string");
    input.survey_id = PT.survey.id;

    self.inputs.push(input);
    PT.selectedInput(self.inputs()[0]);
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
          self.addStarterQuestion();
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

    $(document).on("click", ".tool-button", PT.survey.addInput);
  });
};

PT.flashMessage = function(message, element){
  $("#message").remove();
  element.after(HandlebarsTemplates["flash_message"]({text: message})).fadeIn();
  $("#message").delay(2000).fadeOut();
};

PT.launchSurvey = function(){
  if(PT.survey.inputs().length > 0){
    window.location.pathname = Routes.launch_survey_path(PT.survey.id);
  } else {
    PT.flashMessage(PT.flash["no_questions"], $("#new-survey-title"));
  }
};
