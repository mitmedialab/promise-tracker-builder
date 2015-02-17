Handlebars.registerHelper("formatDate", function(timestamp) {
  return I18n.strftime(new Date(timestamp), "%a %-d %b, %Y");
});

Handlebars.registerHelper("translate", function(string) {
  return I18n.t(string);
});