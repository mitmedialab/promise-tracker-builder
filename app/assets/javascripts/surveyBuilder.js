var PT = PT || {};

/// Input constructor
PT.Input = function(){
  var self = this;

  self.id = ko.observable("");
  self.survey_id = PT.survey.id;
  self.label = ko.observable("");
  self.input_type = ko.observable();
  self.required = ko.observable(false);
  self.options = ko.observableArray([I18n.t("surveys.survey_builder.option_1")]);
  self.sample_length = ko.observable();
  self.sensor_type = ko.observable();
  self.order = "";
  self.inEdit = ko.observable(true);

  self.validate = function(){
    var inputEl = $("#input" + self.id());
    var messages = inputEl.find(".messages");
    messages.empty();

    if(!self.label()) {
      messages.append(I18n.t("defaults.validations.question_blank"));
      inputEl.addClass('invalid');
    } else if(self.input_type() == "select" || self.input_type() == "select1"){
      if (self.options().length == 0){
        messages.append(PT.validations.no_options);
        inputEl.addClass('invalid');
      } else {
      inputEl.removeClass('invalid');
      }
    } else {
      inputEl.removeClass('invalid');
    } 
  };

  self.save = function(self, event){
    $.ajax({
      url: Routes.survey_inputs_path(PT.survey.id),
      type: "POST",
      contentType: "application/json",
      dataType: "json",
      data: ko.toJSON(self)
    })
    .done(function(response) {
      console.log(response);
      self.inEdit(false);
      self.options(response.options);

      if(self.id() === ""){
        self.id(response.id);
      }
      self.validate();
      PT.checkErrors();
    });
  };

  self.map = function(data){
    self.id = ko.observable(data.id);
    self.survey_id = data.survey_id;
    self.label = ko.observable(data.label);
    self.input_type = ko.observable(data.input_type);
    self.required = ko.observable(data.required);
    self.options = ko.observableArray(data.options);
    self.sample_length = ko.observable(data.sample_length);
    self.sensor_type = ko.observable(data.sensor_type);
    self.order = data.order;
    self.inEdit = ko.observable(false);
  }; 

  self.edit = function(){
    PT.survey.saveInputs();
    self.inEdit(true);
    PT.selectedInput(self);
  };

  self.addOption = function(input, event){
    self.options.push("");
    $(event.target).parents().closest(".options").find(".option.edit").last().find("input").focus();
  };

  self.deleteOption = function(option, event){
    self.options.remove(option);
  };

  self.copy = function(input, event) {
    $.ajax({
      url: Routes.clone_input_path(self.id()),
      type: 'POST',
      dataType: 'json'
    })
    .done(function(response) {
      var newInput = new PT.Input();
      newInput.map(response);
      PT.survey.inputs.push(newInput);
      newInput.validate();
    });
  };

  self.applyType = function(){
    if(self.input_type() == "yes_no"){
      self.options([I18n.t("defaults.yes_option"), I18n.t("defaults.no_option")]);
      self.input_type("select1");
    }
  };
};

/// Survey Constructor
PT.SurveyModel = function(){
  var self = this;

  self.id = "";
  self.title = ko.observable();
  self.campaign_id = "";
  self.sensor_type = ko.observable();
  self.threshold = ko.observable();
  self.inputs = ko.observableArray([]);

  self.addInput = function(event){
    self.saveInputs();

    var input = new PT.Input();
    input.input_type = ko.observable("text");

    self.inputs.push(input);
    PT.selectedInput(input);
    if($(".selected").length > 0) {
      $(".selected").find("input")[0].focus();
    }
  };

  self.saveInputs = function(){
    var unsaved = self.inputs().filter(function(input) { return input.inEdit() === true ;});
    unsaved.forEach(function(input){input.save(input); });
  };

  self.removeInput = function(){
    var confirmed = window.confirm(I18n.t("surveys.survey_builder.confirm_input_delete"));
    if(confirmed){
      self.inputs.remove(this);
      if(this.id()){
        $.ajax({
          url: Routes.survey_input_path(PT.survey.id, this.id()),
          type: "DELETE",
          contentType: "application/json",
          dataType: "json"
        })
        .done(function(response){
          console.log(response);
        }); 
      }
    } 

    self.inputs().length < 1 ? PT.selectedInput("") : PT.selectedInput(_.last(PT.survey.inputs()));
  };

  /// Update order of all inputs
  self.saveOrder = function(){
    self.saveInputs();
    
    $.ajax({
      url: Routes.save_order_path(PT.survey.id),
      type: "PUT",
      contentType: "application/json",
      dataType: "json",
      data: ko.toJSON(self)
    })
    .done(function(data){
      window.location.pathname = I18n.currentLocale() + Routes[data.redirect_path](self.campaign_id);
    });

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

PT.getSurvey = function(id){
  $.getJSON(Routes.survey_path(id), null, function(response, textStatus) {
    PT.survey = new PT.SurveyModel();

    PT.survey.id = response.id;
    PT.survey.title(response.title);
    PT.survey.campaign_id = response.campaign_id;
    PT.survey.sensor_type = ko.observable(response.sensor_type);
    PT.survey.threshold = ko.observable(response.threshold);
    PT.survey.positive_threshold = ko.observable(response.positive_threshold);
    PT.survey.populateInputs(response.inputs);
    ko.applyBindings(PT.survey);

    PT.survey.inputs().forEach(function(input){
      input.validate();
    });
    PT.checkErrors();

    $(document).on("click", ".tool-button", PT.survey.addInput);
  });
};

PT.updateTitle = function(){
  PT.survey.title($("#survey-title-input").val());

  $.ajax({
    url: Routes.survey_path(PT.survey.id),
    type: "PUT",
    contentType: "application/json",
    dataType: "json",
    data: ko.toJSON(PT.survey)
  })
  .done(function(response) {
    $("#survey-title-modal").modal('hide');
    $(".campaign-title").html(PT.survey.title());
  })
}

PT.flashMessage = function(message, element){
  $("#message").remove();
  element.after(HandlebarsTemplates["flash_message"]({text: message})).fadeIn();
  $("#message").delay(2000).fadeOut();
};

PT.checkErrors = function(){
  if($("#survey-body").find(".invalid").length > 0){
    $("#error-check").addClass("alert-danger");
    $("#error-check p").html(I18n.t("defaults.validations.has_error"));
  } else {
    $("#error-check").removeClass("alert-danger");
    $("#error-check p").html(I18n.t("defaults.validations.no_errors"));
  }
};
