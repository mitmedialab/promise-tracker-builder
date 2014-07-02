(function() {
  this.HandlebarsTemplates || (this.HandlebarsTemplates = {});
  this.HandlebarsTemplates["editInputField"] = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  


  return "<div class=\"input\">\n  <input type=\"text\" data-bind=\"value: inputLabel\" placeholder=\"Add question text here\">\n  Field required? <input type=\"checkbox\" data-bind=\"value: inputRequired\">\n\n  <div class=\"controls\">\n    <div class=\"btn btn-success save\">Save</div>\n    <div class=\"btn btn-danger delete\">Delete</div>\n  </div>\n</div>\n";
  });
  return this.HandlebarsTemplates["editInputField"];
}).call(this);
