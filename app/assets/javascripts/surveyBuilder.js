var PT = PT || {};

/// Input type defaults
PT.defaultControls = {
  inputText: {
    label: "Text",
    input_type: "string"
  },

  inputLocation: {
    label: "Location",
    input_type: "location"
  },

  inputImage: {
    label: "Image",
    input_type: "image",
  }
};

/// Input constructor
PT.Input = function(){
  var self = this;

  self.id = ko.observable("");
  self.survey_id = PT.survey.id;
  self.label = ko.observable("");
  self.input_type = ko.observable();
  self.required = ko.observable(false);
  self.options = ko.observableArray([{label: I18n.t("surveys.survey_builder.option_1"), jump_to: null}]);
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

  self.save = function(self){
    _.each(self.options(), function(option){
      option.jump_to == undefined ? option.jump_to = null : false; });

    if(self.label().length > 0){
      $.ajax({
        url: Routes.survey_inputs_path(PT.survey.id),
        type: "POST",
        contentType: "application/json",
        dataType: "json",
        data: ko.toJSON(self)
      })
      .done(function(response) {
        self.inEdit(false);
        self.options(response.options);
        console.log("Input saved with label:" + self.label());

        if(self.id() === ""){
          self.id(response.id);
        }
        self.validate();
        PT.checkErrors();
        PT.unsaved = false;
      });
    } else {
      var confirmed;
      self.id() == "" ? confirmed = true : confirmed = window.confirm(I18n.t("surveys.survey_builder.confirm_blank_input"));
      confirmed ? PT.survey.removeInput(self) : false;
    }
  };

  self.replaceUndefinedWithNull = function(self){

  }

  self.map = function(data){
    self.id = ko.observable(data.id);
    self.survey_id = data.survey_id;
    self.label = ko.observable(data.label);
    self.input_type = ko.observable(data.input_type);
    self.required = ko.observable(data.required);
    self.order = data.order;
    self.inEdit = ko.observable(false);

    if(data.options){
      if(typeof(data.options[0]) == "string"){
        self.options = ko.observableArray(
          data.options.map(function(option) { return {
            label: option,
            jump_to: null
          }; }))
      } else {
        self.options = ko.observableArray(data.options);
      }
    }
  };

  self.edit = function(){
    var open = function(){
      self.inEdit(true);
      PT.selectedInput(self);
    };

    PT.survey.saveInputs(open);
  };

  self.addOption = function(input, event){
    self.options.push({label: "", jump_to: null});
    $(event.target).parents().closest(".options").find(".option.edit").last().find("input").focus();
  };

  self.deleteOption = function(option, event){
    self.options.remove(option);
  };

  self.highlightActiveJumps = function(option, event){
    var el = $(event.target).parent().parent().find(".jump-to-expand");
    if(option.jump_to){
      el.addClass("active");
    } else {
      el.removeClass("active");
    }
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
      self.options([{label: I18n.t("defaults.yes_option"), jump_to: null}, {label: I18n.t("defaults.no_option"), jump_to: null}]);
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
  self.inputs = ko.observableArray([]);

  self.saveInputs = function(callback){
    var save = function(){
      PT.unsaved = self.inputs().filter(function(input) { return input.inEdit() === true ;})[0] || false;
      if(PT.unsaved){
        PT.unsaved.save(PT.unsaved);
        window.setTimeout(save, 200);
      } else {
        callback ? callback() : false;
      }
    };

    save();
  };

  self.addInput = function(event){
    event.stopPropagation();

    var add = function(){
      var input = new PT.Input();
      self.inputs.push(input);
      PT.selectedInput(input);

      var label = $(".selected").find("textarea")[0];
      if(label){
        label.focus();
      }
    };

    self.saveInputs(add);
  };

  self.removeInput = function(input){
    var confirmed = input.label() === "" || window.confirm(I18n.t("surveys.survey_builder.confirm_input_delete"));

    if(confirmed){
      self.inputs.remove(input);
      if(input.id()){
        $.ajax({
          url: Routes.survey_input_path(PT.survey.id, input.id()),
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

  self.getLabelById = function(id){
    return self.inputs().filter(function(input){
      return input.id() == id;
    })[0].label();
  }
};

PT.getSurvey = function(id){
  $.getJSON(Routes.survey_path(id), null, function(response, textStatus) {
    PT.survey = new PT.SurveyModel();

    PT.survey.id = response.id;
    PT.survey.title(response.title);
    PT.survey.campaign_id = response.campaign_id;
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

PT.buildJumpToArray = function(input){
  var options = PT.survey.inputs().map(function(i, index){return {id: i.id(), label: index + 1 + ". " + i.label()}; });
  var currentIndex = _.indexOf(PT.survey.inputs(), input);
  return options.slice(currentIndex + 1);
};
